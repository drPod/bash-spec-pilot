#!/usr/bin/env python3
"""Single-command artifact replay: run every entry in manifest.json for real, with a fresh
receipt name and no swallowed exit code, and write one machine-readable JSON summary.

Usage: python3 replay.py [--out-dir DIR]

Exit status: 0 iff every 'required' entry passed. 'current' entries may be skipped (never
silently passed) without failing the overall replay; 'experimental' entries are informational
only. This never edits a live proof worker's files: the Coq entry is read-only against the
running phase5-vst container and is skipped (not overwritten, not force-passed) if that
container's file has diverged from the repository's.
"""
import argparse
import datetime
import fcntl
import re
import hashlib
import json
import os
import shutil
import signal
import subprocess
import sys
import time
import uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent
LIBC = HERE.parents[1]
LEAN_TOOLCHAIN = 'leanprover/lean4:v4.31.0\n'
BODY_LAKEFILE = ('name = "artifact_replay_calculus_body"\n'
                 'defaultTargets = ["CalculusBody"]\n'
                 'moreLeanArgs = ["-j1", "-s16384", "-DwarningAsError=true", "-DElab.async=false"]\n'
                 '[[lean_lib]]\nname = "CalculusNested"\n'
                 '[[lean_lib]]\nname = "CalculusExport"\n'
                 '[[lean_lib]]\nname = "CalculusBody"\n')
OUTER_LAKEFILE = ('name = "artifact_replay_calculus_outer"\n'
                  'defaultTargets = ["CalculusRelayOuter"]\n'
                  'moreLeanArgs = ["-j1", "-s16384", "-DwarningAsError=true", "-DElab.async=false"]\n'
                  '[[lean_lib]]\nname = "CalculusNested"\n'
                  '[[lean_lib]]\nname = "CalculusExport"\n'
                  '[[lean_lib]]\nname = "CalculusBody"\n'
                  '[[lean_lib]]\nname = "CalculusSimulation"\n'
                  '[[lean_lib]]\nname = "CalculusRelayLoop"\n'
                  '[[lean_lib]]\nname = "CalculusRelayOuter"\n')

SPEC_LAKEFILE = ('name = "artifact_replay_calculus_spec15"\n'
                 'defaultTargets = ["CalculusRelaySpec"]\n'
                 'moreLeanArgs = ["-j1", "-s16384", "-DwarningAsError=true", "-DElab.async=false"]\n'
                 '[[lean_lib]]\nname = "MemoryTransfer"\n'
                 '[[lean_lib]]\nname = "BufferRelay"\n'
                 '[[lean_lib]]\nname = "CalculusNested"\n'
                 '[[lean_lib]]\nname = "CalculusExport"\n'
                 '[[lean_lib]]\nname = "CalculusBody"\n'
                 '[[lean_lib]]\nname = "CalculusSimulation"\n'
                 '[[lean_lib]]\nname = "CalculusRelayLoop"\n'
                 '[[lean_lib]]\nname = "CalculusRelayOuter"\n'
                 '[[lean_lib]]\nname = "CompareMain"\n'
                 '[[lean_lib]]\nname = "CalculusRelaySpec"\n')
SPEC_AXIOMS = ('import CalculusRelaySpec\n'
               '#print axioms CalculusRelaySpec.relay_inner_exact\n'
               '#print axioms CalculusRelaySpec.relay_outer_exact_step\n'
               '#print axioms CalculusRelaySpec.relay_outer_exact\n'
               '#print axioms CalculusRelaySpec.relay_matches_phase3\n')

NESTED_LAKEFILE = ('name = "artifact_replay_nested"\ndefaultTargets = ["CalculusNested"]\n'
                   'moreLeanArgs = ["-j1", "-s16384", "-DwarningAsError=true", "-DElab.async=false"]\n'
                   '[[lean_lib]]\nname = "CalculusNested"\n')
ALLOWED_AXIOMS = {'propext', 'Classical.choice', 'Quot.sound'}
RUN_VST = LIBC / 'phase5/run_vst.py'
RUNS_DIR = Path.home() / 'agent-jobs/astra-research/phase5/runs'


def container_busy(container):
    """Real process check (docker top), not a guess: busy iff anything besides the base
    `sleep infinity` is running."""
    try:
        out = subprocess.check_output(['docker', 'top', container], text=True, timeout=15)
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError):
        return True
    return len(out.strip().splitlines()) > 2


def wait_for_idle(container, max_wait_seconds=50, poll_seconds=5):
    """Bounded poll (default well under the harness's 60s single-wait guidance), real process
    checks each time. Returns True if confirmed idle, False if still busy after the bound --
    callers must not loop this indefinitely."""
    waited = 0
    while waited < max_wait_seconds:
        if not container_busy(container):
            return True
        time.sleep(poll_seconds)
        waited += poll_seconds
    return not container_busy(container)


def coqc_one_file(container, workdir, extra_q_args, filename, seconds, run_name,
                   max_lock_retries=5, lock_retry_sleep=8):
    """One `coqc` call for ONE file, through run_vst.py (so it shares the same global
    compiler_lock and container-idle check as every other compile), with bounded retry ONLY on
    lock contention (a genuine compiler error is returned immediately, never retried/masked).
    This is deliberately per-file, not per-chain: the lock is acquired and released once per
    file so a long multi-file chain never monopolizes it against live sibling workers."""
    for attempt in range(max_lock_retries):
        if container_busy(container):
            wait_for_idle(container, max_wait_seconds=40, poll_seconds=5)
        cp = subprocess.run(['uv', 'run', '--no-project', 'python', str(RUN_VST),
                             '--name', run_name, '--seconds', str(seconds), '--workdir', workdir,
                             '--', 'coqc', *extra_q_args, filename],
                            cwd=str(LIBC), capture_output=True, text=True, timeout=seconds + 30)
        combined = (cp.stdout or '') + (cp.stderr or '')
        if 'BlockingIOError' in combined or 'existing job' in combined:
            time.sleep(lock_retry_sleep)
            continue
        try:
            record = json.loads(cp.stdout.strip().splitlines()[-1]) if cp.stdout.strip() else {}
            code = record.get('exit_status', cp.returncode)
        except (ValueError, IndexError):
            code = cp.returncode
        return dict(exit_status=code, attempts=attempt + 1, receipt_name=run_name,
                    raw=combined[-4000:])
    return dict(exit_status=None, attempts=max_lock_retries, receipt_name=run_name,
               raw='lock contention exceeded bounded retry budget')


def run_vst_retry(container, name, seconds, workdir, command_argv, max_lock_retries=5,
                  lock_retry_sleep=8):
    """Bounded-retry wrapper around a single run_vst.py invocation, for the legacy
    single-shot entries (relay.v AST, AuditUniversal.v, the OCaml container build) -- same
    lock-contention discipline as coqc_one_file, just for a command that isn't a single `coqc
    <file>.v` call. Returns (exit_status_or_None, combined_output)."""
    for attempt in range(max_lock_retries):
        if container_busy(container):
            wait_for_idle(container, max_wait_seconds=40, poll_seconds=5)
        try:
            cp = subprocess.run(['uv', 'run', '--no-project', 'python', str(RUN_VST),
                                 '--name', name, '--seconds', str(seconds), '--workdir', workdir,
                                 '--', *command_argv],
                                cwd=str(LIBC), capture_output=True, text=True, timeout=seconds + 30)
            combined = (cp.stdout or '') + (cp.stderr or '')
        except subprocess.TimeoutExpired:
            return None, 'run_vst.py timed out'
        if 'BlockingIOError' in combined or 'existing job' in combined:
            time.sleep(lock_retry_sleep)
            continue
        return cp.returncode, combined
    return None, 'lock contention exceeded bounded retry budget'


def hash_verify(container, container_dir, file_hashes):
    """file_hashes: {filename: expected_sha256}. Returns (ok, detail_dict)."""
    detail = {}
    for fname, expect in file_hashes.items():
        try:
            out = subprocess.check_output(
                ['docker', 'exec', container, 'sha256sum', f'{container_dir}/{fname}'],
                text=True, timeout=15)
            live = out.split()[0]
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError) as e:
            detail[fname] = dict(expected=expect, actual=None, matches=False, error=str(e))
            continue
        detail[fname] = dict(expected=expect, actual=live, matches=(live == expect))
    return all(v['matches'] for v in detail.values()), detail


def stage_fresh_copy(container, container_src_dir, scratch_dir, filenames):
    """Plain `docker cp`-equivalent (docker exec cp) staging only -- root review explicitly
    allows directory inspection/copy without going through run_vst.py; only compiler
    invocations need the lock."""
    subprocess.run(['docker', 'exec', container, 'mkdir', '-p', scratch_dir],
                   check=True, capture_output=True, text=True, timeout=15)
    for fname in filenames:
        subprocess.run(['docker', 'exec', container, 'cp',
                        f'{container_src_dir}/{fname}', f'{scratch_dir}/{fname}'],
                       check=True, capture_output=True, text=True, timeout=15)


SCRATCH_PATTERN = '/tmp/artifact-replay-'


def verify_real_receipt(receipt_name, expected_filename, expected_q_count=None):
    """Open the ACTUAL independent run_vst.py receipt (~/agent-jobs/.../phase5/runs/<name>.json
    + .log) -- not our own summary.json's self-reported fields, which is what an earlier cache
    validation pass mistakenly trusted (root review: 'find_cached_pass still never opens actual
    run receipt JSON; it checks summary log hashes only'). Verifies, in order: exit_status==0 AND
    timing_exit_status==0 (a receipt can report exit_status=0 while timing_exit_status flags the
    wrapped command actually failed/was killed); command[0] is LITERALLY the coqc binary -- not
    just 'coqc' appearing anywhere in argv, which `["echo", "coqc", "Expected.v"]` would satisfy
    under a naive membership check; the expected file is the LAST argument; the WORKDIR and
    EVERY `-Q` path argument fall under our own scratch-directory convention
    (`/tmp/artifact-replay-*`) -- root's exact follow-up finding: a receipt with `-Q /unrelated`
    in `workdir /wrong/source/tree` was still accepted by the first-arg/last-arg-only check,
    because nothing validated the MIDDLE arguments or the directory a command actually ran in;
    that a fabricated receipt pointing anywhere outside our own scratch space can never pass now,
    since real chain compiles never reference host repo paths or arbitrary directories directly
    in the coqc command line, only their own staged scratch copies; if `expected_q_count` is
    given, the exact number of `-Q dir ''` pairs must match (root: 'bind validation to
    manifest-derived exact argv... per group' -- via `expected_q_arg_count`, not a guess); and
    the receipt's own recorded log_sha256 matches the CURRENT content of its log file (re-hashed
    now, not trusted from before). Returns (ok, reason_or_None)."""
    rp = RUNS_DIR / f'{receipt_name}.json'
    lp = RUNS_DIR / f'{receipt_name}.log'
    if not rp.exists():
        return False, f'receipt JSON missing: {rp}'
    try:
        rec = json.loads(rp.read_text())
    except (json.JSONDecodeError, OSError):
        return False, 'receipt JSON corrupt'
    if rec.get('exit_status') != 0:
        return False, f"receipt exit_status={rec.get('exit_status')!r} != 0"
    if rec.get('timing_exit_status') != 0:
        return False, f"receipt timing_exit_status={rec.get('timing_exit_status')!r} != 0"
    cmd = rec.get('command') or []
    if not cmd or cmd[0] != 'coqc':
        return False, f'receipt command[0] is not literally coqc: {cmd}'
    if not cmd or cmd[-1] != expected_filename:
        return False, f'receipt command does not END with the expected file {expected_filename!r} ' \
                      f'(the actual file compiled must be the last argument): {cmd}'
    workdir = rec.get('workdir') or ''
    if not workdir.startswith(SCRATCH_PATTERN):
        return False, f'receipt workdir is not our own scratch directory: {workdir!r}'
    q_paths = [cmd[i + 1] for i in range(len(cmd)) if cmd[i] == '-Q' and i + 1 < len(cmd)]
    for qp in q_paths:
        if not qp.startswith(SCRATCH_PATTERN):
            return False, f'receipt -Q argument points outside our scratch space: {qp!r} in {cmd}'
    if expected_q_count is not None and len(q_paths) != expected_q_count:
        return False, (f'receipt has {len(q_paths)} -Q path(s), expected exactly '
                       f'{expected_q_count} for this (entry, group, file): {cmd}')
    if not lp.exists():
        return False, f'receipt log missing: {lp}'
    if rec.get('log_sha256') != hashlib.sha256(lp.read_bytes()).hexdigest():
        return False, 'receipt log_sha256 does not match the current log file content'
    return True, None


def expected_q_arg_count(entry_id, group, filename=None):
    """Exact expected number of `-Q dir ''` pairs for this (entry, group[, file]) -- a direct
    transcription of every `q_args_fn` closure body in each replay_* function (kept in sync by
    hand, same discipline as expected_group_files). Returns None if unknown (skips the count
    check rather than guessing)."""
    per_entry = {
        'gnu_vsu_utility_reuse_chain_replay': {'relay': 0, 'utility-reuse': 2},
        'calculus_bytes_oracle_chain_replay': {'relay-dep': 0, 'bytes-oracle': 1},
        'case_studies_full_chain_replay': {'relay-dep': 0, 'utility-reuse-dep': 1,
                                           'case-studies-generated': 2, 'case-studies': 2},
        'relay_full_behavioral_chain_replay': {'relay-base': 0, 'adequacy': 0, 'exit': 0,
                                               'shell-bridge': 1, 'exit-shell': 1},
        'shell_bridge_chain_replay': {'relay': 0, 'shell-bridge': 1},
        'shell_expansion_accepted_replay': {'relay-dep': 0, 'shell-bridge-dep': 1, 'shell-expansion': 2},
        'shell_expansion_compose_chain_replay': {'relay-dep': 0, 'shell-bridge-dep': 1,
                                                 'shell-expansion-dep': 2, 'compose': 3},
    }
    if entry_id == 'universal_full_chain_replay':
        if group == 'universal':
            return 3 if filename == 'UniversalShell.v' else 2
        return {'relay-dep': 0, 'adequacy-dep': 0, 'exit-dep': 0, 'shell-bridge-dep': 1}.get(group)
    return per_entry.get(entry_id, {}).get(group)


def expected_group_files(entry_id, entry):
    """The canonical ordered [(group, filename), ...] a fresh execution of this entry produces,
    derived directly from the entry's own file-set fields -- the SAME field names and GROUP
    LABELS each replay_* function's `steps` list literally uses (kept in sync by hand; each
    mapping below is a direct transcription, not a guess -- see the `group=` literals in each
    replay_* function). Used to validate a cached per_file list has EXACTLY the right (group,
    file) pairs, not just the right COUNT (root's exact finding: a cached result could have the
    right size but be silently missing one file and duplicating another)."""
    e = entry
    if entry_id == 'gnu_vsu_utility_reuse_chain_replay':
        return ([('relay', f) for f in e['relay_files']]
              + [('utility-reuse', f) for f in e['utility_reuse_files']])
    if entry_id == 'shell_bridge_chain_replay':
        return ([('relay', f) for f in e['relay_dep_files']]
              + [('shell-bridge', f) for f in e['shell_bridge_files']])
    if entry_id == 'relay_full_behavioral_chain_replay':
        return ([('relay-base', f) for f in e['relay_base_files']]
              + [('adequacy', f) for f in e['adequacy_files']]
              + [('exit', f) for f in e['exit_files']]
              + [('shell-bridge', f) for f in e['shell_bridge_files']]
              + [('exit-shell', f) for f in e['shell_exit_file']])
    if entry_id == 'universal_full_chain_replay':
        return ([('relay-dep', f) for f in e['relay_dep_files']]
              + [('adequacy-dep', f) for f in e['adequacy_dep_files']]
              + [('exit-dep', f) for f in e['exit_dep_files']]
              + [('shell-bridge-dep', f) for f in e['shell_bridge_dep_files']]
              + [('universal', f) for f in e['universal_files']])
    if entry_id == 'shell_expansion_accepted_replay':
        return ([('relay-dep', f) for f in e['relay_dep_files']]
              + [('shell-bridge-dep', f) for f in e['shell_bridge_dep_files']]
              + [('shell-expansion', f) for f in e['shell_expansion_files']])
    if entry_id == 'shell_expansion_compose_chain_replay':
        return ([('relay-dep', f) for f in e['relay_dep_files']]
              + [('shell-bridge-dep', f) for f in e['shell_bridge_dep_files']]
              + [('shell-expansion-dep', f) for f in e['shell_expansion_dep_files']]
              + [('compose', f) for f in e['compose_files']])
    if entry_id == 'case_studies_full_chain_replay':
        return ([('relay-dep', f) for f in e['relay_dep_files']]
              + [('utility-reuse-dep', f) for f in e['utility_reuse_dep_files']]
              + [('case-studies-generated', f) for f in e['case_studies_generated_files']]
              + [('case-studies', f) for f in e['case_studies_files']])
    if entry_id == 'calculus_bytes_oracle_chain_replay':
        return ([('relay-dep', f) for f in e['relay_dep_files']]
              + [('bytes-oracle', f) for f in e['bytes_oracle_files']])
    return None


def hash_verify_host(repo_dir, file_hashes):
    """Like hash_verify, but reads the REPO checkout directly (host filesystem) instead of a
    container mirror -- used for sources that may be under live, concurrent edit in the repo
    itself (shell-expansion/), where a stale container-side copy would be the wrong thing to
    trust anyway."""
    detail = {}
    for fname, expect in file_hashes.items():
        p = repo_dir / fname
        if not p.exists():
            detail[fname] = dict(expected=expect, actual=None, matches=False, error='missing')
            continue
        actual = sha(p)
        detail[fname] = dict(expected=expect, actual=actual, matches=(actual == expect))
    return all(v['matches'] for v in detail.values()), detail


def stage_from_host(container, repo_dir, scratch_dir, filenames):
    """Real `docker cp <host-file> container:<dest>` -- copies straight from the git-tracked
    repo checkout into a fresh container scratch dir, no dependency on any pre-existing
    container-side mirror. Copy-only, no compiler, so (per root review) this needs no lock."""
    subprocess.run(['docker', 'exec', container, 'mkdir', '-p', scratch_dir],
                   check=True, capture_output=True, text=True, timeout=15)
    for fname in filenames:
        subprocess.run(['docker', 'cp', str(repo_dir / fname), f'{container}:{scratch_dir}/{fname}'],
                       check=True, capture_output=True, text=True, timeout=15)


def cleanup_scratch(container, *scratch_dirs):
    for d in scratch_dirs:
        subprocess.run(['docker', 'exec', container, 'rm', '-rf', d],
                       capture_output=True, timeout=15)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


COMPILER_LOCK = Path.home() / '.cache/bash-spec-pilot/phase3-compiler.lock'
HOST_LEAN_ADDRESS_SPACE = 3 * 1024 ** 3


def _run_real_unlocked(argv, cwd, seconds, log_path, extra_env=None):
    """Called only with the shared lock held; own process group bounds timeout cleanup."""
    t0 = time.monotonic()
    command = list(argv)
    env = dict(os.environ)
    env.update(extra_env or {})
    if Path(command[0]).name in {'lake', 'lean', 'leanc'}:
        # Per-process only: inherited by Lake's Lean children, never global settings.
        env.update(LEAN_NUM_THREADS='1', MIMALLOC_ARENA_RESERVE='65536')
        command = ['prlimit', f'--as={HOST_LEAN_ADDRESS_SPACE}', '--', *command]
    with open(log_path, 'w') as stream:
        proc = subprocess.Popen(command, cwd=cwd, env=env, stdout=stream,
                                stderr=subprocess.STDOUT, start_new_session=True)
        try:
            code = proc.wait(timeout=seconds)
        except subprocess.TimeoutExpired:
            # Kill only the session/process group created above, including children
            # that outlive their launcher. Never signal our own pane or its group.
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            proc.wait()
            stream.write('\nCompiler timeout; owned process group killed.\n')
            code = None
        except BaseException:
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            proc.wait()
            raise
    return code, round(time.monotonic() - t0, 2)


def run_real(argv, cwd, seconds, log_path, max_wait=5, extra_env=None):
    """Every direct host compiler shares the Coq lock; no nested lock acquisition.

    Docker/Coq commands use run_vst.py separately and do not enter this function.
    Preserve the existing (return code or None, elapsed seconds) receipt interface.
    """
    COMPILER_LOCK.parent.mkdir(parents=True, exist_ok=True)
    deadline = time.monotonic() + max_wait
    with open(COMPILER_LOCK, 'a') as handle:
        while True:
            try:
                fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError:
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    Path(log_path).write_text('Compiler lock wait expired; no process launched.\n')
                    return None, 0
                time.sleep(min(0.1, remaining))
        try:
            return _run_real_unlocked(argv, cwd, seconds, log_path, extra_env=extra_env)
        finally:
            fcntl.flock(handle, fcntl.LOCK_UN)


def run_real_locked(argv, cwd, seconds, log_path, max_wait=5):
    """Compatibility entry point; run_real owns the single shared lock."""
    return run_real(argv, cwd, seconds, log_path, max_wait=max_wait)


LEAN_COMPILER_SECONDS = 60
LEAN_LOCK_WAIT = 5
LEAN_STDLIB_ROOTS = {'Init', 'Std', 'Lean', 'Lake'}
IMPORT_LINE_RE = re.compile(r'^\s*import\s+([A-Za-z0-9_.]+)\s*$')


def _strip_lean_comments(text):
    """Strip `--` line comments and `/- ... -/` blocks; keep newlines. Fail closed if unclosed."""
    out = []
    i = 0
    n = len(text)
    while i < n:
        if text.startswith('/-', i):
            end = text.find('-/', i + 2)
            if end < 0:
                raise ValueError('unclosed Lean block comment')
            chunk = text[i:end + 2]
            out.append(''.join('\n' if c == '\n' else ' ' for c in chunk))
            i = end + 2
        elif text.startswith('--', i):
            nl = text.find('\n', i)
            if nl < 0:
                i = n
            else:
                out.append('\n')
                i = nl + 1
        else:
            out.append(text[i])
            i += 1
    return ''.join(out)


def parse_lean_imports(text):
    """Local imports only. Comments stripped first. Fail closed on multiline, multiple, or
    leftover `import` tokens that are not a single `import Module` line."""
    stripped = _strip_lean_comments(text)
    found = []
    for line in stripped.splitlines():
        if 'import' not in line:
            continue
        m = IMPORT_LINE_RE.match(line)
        if not m or line.count('import') != 1:
            raise ValueError('unsupported Lean import syntax: ' + line.strip())
        name = m.group(1)
        if name.split('.')[0] in LEAN_STDLIB_ROOTS:
            continue
        if name not in found:
            found.append(name)
    return found


def lean_compile_order(staged, roots):
    """Topological order of staged *.lean modules. Fail closed on missing deps or cycles."""
    available = {path.stem for path in staged.glob('*.lean')}
    graph = {}
    pending = list(roots)
    seen = set()
    while pending:
        module = pending.pop()
        if module in seen:
            continue
        if module not in available:
            raise ValueError('missing Lean source for module: ' + module)
        seen.add(module)
        imports = parse_lean_imports((staged / (module + '.lean')).read_text())
        graph[module] = []
        for imp in imports:
            if imp not in available:
                raise ValueError('missing Lean dependency: ' + imp + ' (imported by ' + module + ')')
            graph[module].append(imp)
            pending.append(imp)
    indeg = {m: 0 for m in graph}
    for m, deps in graph.items():
        for d in deps:
            indeg[m] += 1
    queue = sorted(m for m, n in indeg.items() if n == 0)
    order = []
    remaining = {m: list(deps) for m, deps in graph.items()}
    while queue:
        m = queue.pop(0)
        order.append(m)
        for n, deps in remaining.items():
            if m in deps:
                deps.remove(m)
                indeg[n] -= 1
                if indeg[n] == 0:
                    queue.append(n)
                    queue.sort()
    if len(order) != len(graph):
        cyclic = sorted(set(graph) - set(order))
        raise ValueError('Lean import cycle among: ' + ','.join(cyclic))
    return order


def _direct_lean_argv(lean, module):
    return [str(lean), '-j1', '-s16384', '-DwarningAsError=true', '-DElab.async=false',
            '-o', module + '.olean', module + '.lean']


def compile_lean_modules_sequential(lean, scratch, modules, receipts, entry_id,
                                    seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT,
                                    extra_env=None):
    """Sequential pinned-Lean invocations; stop on first failure; no Lake."""
    env = {'LEAN_PATH': str(scratch)}
    if extra_env:
        env.update(extra_env)
    per_file = []
    for module in modules:
        output = scratch / (module + '.olean')
        log = receipts / (entry_id + '.' + module + '.log')
        argv = _direct_lean_argv(lean, module)
        try:
            code, elapsed = run_real(argv, scratch, seconds, log, max_wait=lock_wait, extra_env=env)
        except OSError as exc:
            log.write_text('Compiler launch failed: ' + str(exc) + '\n')
            code, elapsed = None, 0
        receipt = dict(
            file=module + '.lean', command=argv, workdir=str(scratch),
            environment={**env, 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'},
            address_space_bytes=HOST_LEAN_ADDRESS_SPACE, exit_status=code,
            elapsed_seconds=elapsed, log=str(log),
            log_sha256=sha(log) if log.exists() else None,
            output=str(output), output_sha256=sha(output) if output.is_file() else None,
            source_sha256=sha(scratch / (module + '.lean')) if (scratch / (module + '.lean')).is_file() else None,
        )
        receipt_path = receipts / (entry_id + '.' + module + '.json')
        receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
        receipt['receipt'] = str(receipt_path)
        per_file.append(receipt)
        if code is None and log.exists() and 'lock wait expired' in log.read_text():
            return dict(ok=False, skipped=True, reason='compiler lock busy',
                        exit_status=None, per_file=per_file, log=str(log))
        if code is None:
            return dict(ok=False, skipped=False, reason='compiler timeout: ' + module,
                        exit_status=None, per_file=per_file, log=str(log))
        if code != 0 or not output.is_file() or output.stat().st_size == 0:
            return dict(ok=False, skipped=False,
                        reason='compiler failure or missing output: ' + module,
                        exit_status=code, per_file=per_file, log=str(log))
    last = per_file[-1]
    return dict(ok=True, skipped=False, reason=None, exit_status=last['exit_status'],
                per_file=per_file, log=last['log'])


def _pinned_leanc_binary():
    leanc = _pinned_lean_binary().parent / 'leanc'
    if not leanc.is_file() or not os.access(leanc, os.X_OK):
        raise ValueError('pinned leanc binary is not installed: ' + str(leanc))
    return leanc


def compile_lean_c_sources_and_link(lean, leanc, scratch, modules, exe_name, receipts, entry_id,
                                    seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT):
    """Sequential pinned Lean C codegen then leanc link. Direct `lean --run` is not an exe."""
    env = {'LEAN_PATH': str(scratch)}
    per_file = []
    c_files = []
    for module in modules:
        c_out = scratch / (module + '.c')
        log = receipts / (entry_id + '.' + module + '.c.log')
        argv = [str(lean), '-j1', '-s16384', '-DwarningAsError=true', '-DElab.async=false',
                '-c', module + '.c', module + '.lean']
        try:
            code, elapsed = run_real(argv, scratch, seconds, log, max_wait=lock_wait, extra_env=env)
        except OSError as exc:
            log.write_text('Compiler launch failed: ' + str(exc) + '\n')
            code, elapsed = None, 0
        receipt = dict(
            file=module + '.c', command=argv, workdir=str(scratch),
            environment={**env, 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'},
            address_space_bytes=HOST_LEAN_ADDRESS_SPACE, exit_status=code,
            elapsed_seconds=elapsed, log=str(log),
            log_sha256=sha(log) if log.exists() else None,
            output=str(c_out), output_sha256=sha(c_out) if c_out.is_file() else None,
            source_sha256=sha(scratch / (module + '.lean')),
        )
        receipt_path = receipts / (entry_id + '.' + module + '.c.json')
        receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
        receipt['receipt'] = str(receipt_path)
        per_file.append(receipt)
        if code is None and log.exists() and 'lock wait expired' in log.read_text():
            return dict(ok=False, skipped=True, reason='compiler lock busy',
                        exit_status=None, per_file=per_file, log=str(log), executable=None)
        if code is None or code != 0 or not c_out.is_file() or c_out.stat().st_size == 0:
            return dict(ok=False, skipped=False, reason='C codegen failure: ' + module,
                        exit_status=code, per_file=per_file, log=str(log), executable=None)
        c_files.append(module + '.c')
    exe = scratch / exe_name
    log = receipts / (entry_id + '.link.log')
    argv = [str(leanc), '-o', exe_name, *c_files]
    try:
        code, elapsed = run_real(argv, scratch, seconds, log, max_wait=lock_wait, extra_env=env)
    except OSError as exc:
        log.write_text('leanc launch failed: ' + str(exc) + '\n')
        code, elapsed = None, 0
    receipt = dict(
        file=exe_name, command=argv, workdir=str(scratch),
        environment={**env, 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'},
        address_space_bytes=HOST_LEAN_ADDRESS_SPACE, exit_status=code,
        elapsed_seconds=elapsed, log=str(log),
        log_sha256=sha(log) if log.exists() else None,
        output=str(exe), output_sha256=sha(exe) if exe.is_file() else None,
    )
    receipt_path = receipts / (entry_id + '.link.json')
    receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
    receipt['receipt'] = str(receipt_path)
    per_file.append(receipt)
    if code is None and log.exists() and 'lock wait expired' in log.read_text():
        return dict(ok=False, skipped=True, reason='compiler lock busy',
                    exit_status=None, per_file=per_file, log=str(log), executable=None)
    if code != 0 or not exe.is_file() or not os.access(exe, os.X_OK):
        return dict(ok=False, skipped=False, reason='leanc link failed or missing executable',
                    exit_status=code, per_file=per_file, log=str(log), executable=None)
    return dict(ok=True, skipped=False, reason=None, exit_status=code,
                per_file=per_file, log=str(log), executable=str(exe))


def audit_theorems_ok(text, expected, check_compiled):
    """Require terminal-0 audit, nonempty output, exact unique expected names, whitelist, no sorryAx."""
    if not check_compiled or not check_compiled.get('ok') or check_compiled.get('exit_status') != 0:
        return False, {}
    if not (text or '').strip():
        return False, {}
    if 'sorryAx' in text:
        names, results = _parse_axiom_prints(text)
        return False, results
    names, results = _parse_axiom_prints(text)
    if names != list(expected) or len(names) != len(set(names)):
        return False, results
    if any(results.get(t, {}).get('allowed') is not True for t in expected):
        return False, results
    return True, results



def fresh_scratch(tag):
    d = Path.home() / '.cache/bash-spec-pilot/phase5-artifact-replay' / f'{tag}-{uuid.uuid4().hex[:10]}'
    d.mkdir(parents=True)
    return d


def replay_lean_phase3_project(entry, receipts):
    """Fresh flatten of phase3 + sibling sources (MemoryTransfer/BufferRelay/...). Sequential
    pinned Lean oleans then C codegen + leanc link of pointer-trace (TraceMain). Lakefile is
    staged for identity, not executed. Direct lean --run is not a built executable."""
    scratch = fresh_scratch('lean-phase3')
    proj = scratch / 'proj'
    proj.mkdir()
    for rel in entry['extra_sources'] + [f"{entry['source_dir']}/lakefile.toml",
                                          f"{entry['source_dir']}/lean-toolchain"]:
        shutil.copy2(LIBC / rel, proj / Path(rel).name)
    for f in (LIBC / entry['source_dir']).glob('*.lean'):
        shutil.copy2(f, proj / f.name)
    log = receipts / f"{entry['id']}.log"
    try:
        lean = _pinned_lean_binary()
        roots = sorted(path.stem for path in proj.glob('*.lean'))
        order = lean_compile_order(proj, roots)
        compiled = compile_lean_modules_sequential(
            lean, proj, order, receipts, entry['id'],
            seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT)
        linked = None
        if compiled.get('ok'):
            leanc = _pinned_leanc_binary()
            linked = compile_lean_c_sources_and_link(
                lean, leanc, proj, order, 'pointer-trace', receipts, entry['id'] + '.exe',
                seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT)
    except (ValueError, OSError) as exc:
        Path(log).write_text(str(exc) + '\n')
        return dict(exit_status=None, elapsed_seconds=0, log=str(log), scratch=str(scratch),
                    passed=False, reason=str(exc), per_file=[])
    per_file = list(compiled.get('per_file') or [])
    if linked:
        per_file.extend(linked.get('per_file') or [])
    code = compiled['exit_status'] if not linked else linked['exit_status']
    secs = sum(p.get('elapsed_seconds') or 0 for p in per_file)
    Path(log).write_text('\n'.join(p['log'] for p in per_file) + '\n')
    if compiled.get('skipped') or (linked and linked.get('skipped')):
        return dict(skipped=True, reason=(compiled.get('reason') if compiled.get('skipped') else linked['reason']),
                    passed=None, exit_status=None, elapsed_seconds=secs, log=str(log), scratch=str(scratch),
                    per_file=per_file)
    exe = (linked or {}).get('executable')
    ok = bool(compiled.get('ok') and linked and linked.get('ok') and exe and Path(exe).is_file()
              and os.access(exe, os.X_OK) and code == entry['expected_exit'])
    return dict(exit_status=code, elapsed_seconds=round(secs, 2), log=str(log), scratch=str(scratch),
               per_file=per_file, executable=exe, passed=ok)


def replay_lean_calculus_nested_real(entry, receipts):
    # artifact-finish-12: prefer the immutable archived evaluation-freeze copy over the live
    # repo path once one is recorded -- the live file may now be under authorized ongoing
    # development unrelated to the frozen evaluation (see archive/README.md).
    src = LIBC / entry['archive_source'] if entry.get('archive_source') else LIBC / entry['source_file']
    actual_sha = sha(src)
    identity_ok = actual_sha == entry['source_sha256']
    scratch = fresh_scratch('lean-nested-real')
    (scratch / 'lean-toolchain').write_text(LEAN_TOOLCHAIN)
    (scratch / 'lakefile.toml').write_text(NESTED_LAKEFILE)
    shutil.copy2(src, scratch / 'CalculusNested.lean')
    log = receipts / f"{entry['id']}.build.log"
    try:
        lean = _pinned_lean_binary()
        order = lean_compile_order(scratch, ['CalculusNested'])
        compiled = compile_lean_modules_sequential(
            lean, scratch, order, receipts, entry['id'] + '.build',
            seconds=LEAN_COMPILER_SECONDS)
    except (ValueError, OSError) as exc:
        Path(log).write_text(str(exc) + '\n')
        return dict(exit_status=None, elapsed_seconds=0, log=str(log), scratch=str(scratch),
                    source_identity_ok=identity_ok, source_sha256_actual=actual_sha,
                    passed=False, reason=str(exc), per_file=[])
    code = compiled['exit_status']
    secs = sum(p.get('elapsed_seconds') or 0 for p in compiled['per_file'])
    Path(log).write_text((compiled.get('reason') or '') + '\n')
    if compiled.get('skipped'):
        return dict(skipped=True, reason=compiled['reason'], passed=None,
                    file_identity=None, exit_status=None, elapsed_seconds=secs, log=str(log),
                    source_identity_ok=identity_ok, source_sha256_actual=actual_sha)
    if not compiled['ok']:
        return dict(exit_status=code, elapsed_seconds=round(secs, 2), log=str(log), scratch=str(scratch),
                    source_identity_ok=identity_ok, source_sha256_actual=actual_sha,
                    axiom_results={}, passed=False, reason=compiled['reason'])
    axiom_results = {}
    check_compiled = None
    ccode = None
    if code == 0:
        check_src = 'import CalculusNested\n' + '\n'.join(f'#print axioms {t}' for t in entry['theorems'])
        (scratch / 'Check.lean').write_text(check_src + '\n')
        clog = receipts / f"{entry['id']}.check.log"
        check_compiled = compile_lean_modules_sequential(
            lean, scratch, ['Check'], receipts, entry['id'] + '.check',
            seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT)
        ccode = check_compiled['exit_status']
        clog.write_text(Path(check_compiled['per_file'][0]['log']).read_text() if check_compiled['per_file'] else '')
        out = clog.read_text()
        theorems_ok, axiom_results = audit_theorems_ok(out, entry['theorems'], check_compiled)
    else:
        theorems_ok = False
    per_file = list(compiled.get('per_file') or [])
    if check_compiled:
        per_file.extend(check_compiled.get('per_file') or [])
    return dict(exit_status=code, audit_exit_status=ccode, elapsed_seconds=secs, log=str(log),
               scratch=str(scratch), source_identity_ok=identity_ok, source_sha256_actual=actual_sha,
               axiom_results=axiom_results, per_file=per_file,
               passed=(identity_ok and theorems_ok))


def replay_c_relay_compile(entry, receipts):
    scratch = fresh_scratch('c-relay')
    mismatches = {}
    for rel, expect in entry['files'].items():
        src = LIBC / rel
        actual = sha(src)
        mismatches[rel] = dict(expected=expect, actual=actual, matches=(actual == expect))
        shutil.copy2(src, scratch / Path(rel).name)
    identity_ok = all(v['matches'] for v in mismatches.values())
    log = receipts / f"{entry['id']}.log"
    code, secs = run_real(['gcc', '-std=c11', '-Wall', '-c', 'relay_main.c', '-o', 'relay_main.o'],
                          scratch, 60, log)
    return dict(exit_status=code, elapsed_seconds=secs, log=str(log), scratch=str(scratch),
               file_identity=mismatches, passed=(identity_ok and code == entry['expected_exit']))


def replay_coq_relay_ast(entry, receipts):
    container = entry['container']
    try:
        out = subprocess.check_output(
            ['docker', 'exec', container, 'sha256sum',
             f"{entry['workdir']}/relay.v"], text=True, timeout=15)
        live_sha = out.split()[0]
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError) as e:
        return dict(skipped=True, reason=f'could not read container file: {e}', passed=None)
    if live_sha != entry['source_sha256']:
        return dict(skipped=True, reason='container relay.v has diverged from the repository '
                    '(a sibling proof worker may be mid-edit); not overwritten, not force-passed',
                    live_sha256=live_sha, expected_sha256=entry['source_sha256'], passed=None)
    name = f"artifact-replay-{uuid.uuid4().hex[:10]}"
    log = receipts / f"{entry['id']}.log"
    t0 = time.monotonic()
    code, combined = run_vst_retry(container, name, entry['seconds'], entry['workdir'], ['coqc', 'relay.v'])
    log.write_text(combined)
    return dict(exit_status=code, elapsed_seconds=round(time.monotonic() - t0, 2), log=str(log),
               log_sha256=hashlib.sha256(combined.encode()).hexdigest(),
               live_sha256_matched=True, receipt_name=name, passed=(code == entry['expected_exit']))


def run_named_chain(entry, receipts, steps, check_only=False):
    """Shared driver for every multi-file fresh-Coq-chain entry. `steps` is an ordered list of
    dicts: {group, container_src_dir, scratch_dir, files: {fname: sha256}, q_args_fn(fname)}.
    Hash-verifies every file in every step against the repository BEFORE staging anything
    (skip, not force-pass, on divergence); stages fresh copies via plain `docker cp` (no lock
    needed for that, per root review); then compiles file-by-file, EACH through its own
    run_vst.py call (own lock acquire/release -- never one lock held for the whole chain),
    aborting the chain at the first genuine compiler failure (lock contention is retried
    in-place inside coqc_one_file, not treated as a chain failure). Always cleans up its
    scratch dirs, even on failure/exception. `check_only=True`: just re-verify current live
    source identity (cheap, no staging/compiling) -- used to validate a cached pass is still
    trustworthy against the ACTUAL current source, per root review's cache-integrity finding."""
    container = entry['container']
    all_mismatches = {}
    for step in steps:
        if step.get('source') == 'host':
            ok, detail = hash_verify_host(step['repo_dir'], step['files'])
        else:
            ok, detail = hash_verify(container, step['container_src_dir'], step['files'])
        all_mismatches.update({f"{step['group']}/{k}": v for k, v in detail.items()})
        if not ok:
            return dict(skipped=True, reason=f"{step['group']} has diverged from the repository "
                        "(a sibling worker may be mid-edit); not overwritten, not force-passed",
                        file_identity=all_mismatches, passed=None)
    if check_only:
        return dict(passed=True, file_identity=all_mismatches, check_only=True)
    scratch_dirs = [step['scratch_dir'] for step in steps]
    per_file = []
    t0 = time.monotonic()
    try:
        for step in steps:
            if step.get('source') == 'host':
                stage_from_host(container, step['repo_dir'], step['scratch_dir'], list(step['files']))
            else:
                stage_fresh_copy(container, step['container_src_dir'], step['scratch_dir'], list(step['files']))
        for step in steps:
            for fname in step['files']:
                run_name = f"artifact-replay-{uuid.uuid4().hex[:8]}"
                seconds = step.get('seconds', 180)
                r = coqc_one_file(container, step['scratch_dir'], step['q_args_fn'](fname),
                                  fname, seconds, run_name)
                raw = r.pop('raw')
                log_path = receipts / f"{entry['id']}-{step['group']}-{fname}.log"
                log_path.write_text(raw)
                r.update(group=step['group'], file=fname, log=str(log_path),
                         log_sha256=hashlib.sha256(raw.encode()).hexdigest())
                per_file.append(r)
                if r['exit_status'] != 0:
                    break
            else:
                continue
            break
    finally:
        cleanup_scratch(container, *scratch_dirs)
    all_ok = bool(per_file) and all(f['exit_status'] == 0 for f in per_file)
    total_expected = sum(len(s['files']) for s in steps)
    return dict(exit_status=(0 if all_ok and len(per_file) == total_expected else 1),
               elapsed_seconds=round(time.monotonic() - t0, 2),
               file_identity_checked=len(all_mismatches), file_identity=all_mismatches,
               lock_protected='per-file',
               files_attempted=len(per_file), files_total=total_expected, per_file=per_file,
               passed=(all_ok and len(per_file) == total_expected))


def replay_gnu_vsu_chain(entry, receipts, check_only=False):
    """Fresh, dependency-ordered, no-stale-.vo recompile of the actual GNU utility-reuse
    body+VSU+AllVSU chain (24 files: 6 relay dependencies -- relay/Protocol/Reach/Conservation/
    Specs/Body -- then the 18 utility-reuse files in the exact order already verified to work
    individually in linking4-replay-01..18, all exit 0). Added after root review pointed out
    that AST-level entries alone do not replay any accepted GNU5-body+4-VSU/AllVSU-link
    evidence. Per-file lock discipline (see run_named_chain): each of the 24 `coqc` calls gets
    its own run_vst.py lock acquire/release, never one hold for the whole chain."""
    relay_scratch = f"/tmp/artifact-replay-gnuvsu-relay-{uuid.uuid4().hex[:8]}"
    ur_scratch = f"/tmp/artifact-replay-gnuvsu-ur-{uuid.uuid4().hex[:8]}"
    steps = [
        dict(group='relay', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['relay_files'], q_args_fn=lambda f: []),
        dict(group='utility-reuse', container_src_dir=entry['container_utility_reuse_dir'],
            scratch_dir=ur_scratch, files=entry['utility_reuse_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, '', '-Q', ur_scratch, '']),
    ]
    r = run_named_chain(entry, receipts, steps, check_only=check_only)
    r['files_compiled_in_order'] = list(entry['relay_files']) + list(entry['utility_reuse_files'])
    return r


def replay_case_studies_differential(entry, receipts, max_lock_retries=4, lock_retry_sleep=8):
    """Shell out to case-studies' own already-reviewed single-command replay script rather than
    re-implementing its gcc/harness logic here; it already handles fresh unique-per-invocation
    receipt names against the same shared compiler lock this manifest uses elsewhere. This
    wrapper (not the external script, which is case-studies' own and not owned by phase5/
    artifact/) adds bounded retry: the external script makes several individual run_vst.py
    calls with no retry of its own, so a sibling's compile landing between two of those calls
    can BlockingIOError it out. Retrying the WHOLE script (idempotent: unique runids per
    invocation, no receipt-name collisions) on that specific signature is the only lock-safe
    option available without modifying a file this entry doesn't own."""
    log = receipts / f"{entry['id']}.log"
    t0 = time.monotonic()
    combined = ''
    code = None
    for attempt in range(max_lock_retries):
        if container_busy(entry.get('container', 'phase5-vst')):
            wait_for_idle(entry.get('container', 'phase5-vst'), max_wait_seconds=40, poll_seconds=5)
        try:
            cp = subprocess.run(entry['command'], cwd=str(LIBC.parents[1]), capture_output=True,
                                text=True, timeout=entry['seconds'])
            combined = (cp.stdout or '') + (cp.stderr or '')
            code = cp.returncode
        except subprocess.TimeoutExpired:
            code = None
            combined = 'timed out'
            break
        if 'BlockingIOError' in combined and code != 0:
            time.sleep(lock_retry_sleep)
            continue
        break
    log.write_text(combined)
    return dict(exit_status=code, elapsed_seconds=round(time.monotonic() - t0, 2), log=str(log),
               log_sha256=hashlib.sha256(combined.encode()).hexdigest(), attempts=attempt + 1,
               passed=(code == entry['expected_exit']))


def replay_coq_universal_ast(entry, receipts):
    """Same in-place, read-only, hash-verified pattern as replay_coq_relay_ast, applied to the
    new universal-termination Coq files (UniversalMain.v/UniversalExit.v/AuditUniversal.v,
    untracked in git under relay/adequacy/universal/). The container's compiled universal4/
    directory already has cached .vo/.vok for the dependency chain (Terminate.v etc. built
    earlier in the same session) so a real `coqc` of AuditUniversal.v in place is fast; this is
    NOT a fresh-copy rebuild of the whole Dry/Safety/Terminate dependency chain (that remains
    the same documented gap as the relay body proofs -- see known_gaps)."""
    container = entry['container']
    mismatches = {}
    for rel, expect in entry['files'].items():
        try:
            out = subprocess.check_output(
                ['docker', 'exec', container, 'sha256sum', f"{entry['workdir']}/{rel}"],
                text=True, timeout=15)
            live_sha = out.split()[0]
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError) as e:
            return dict(skipped=True, reason=f'could not read container file {rel}: {e}', passed=None)
        mismatches[rel] = dict(expected=expect, actual=live_sha, matches=(live_sha == expect))
    if not all(v['matches'] for v in mismatches.values()):
        return dict(skipped=True, reason='container universal4/ has diverged from the repository '
                    '(a sibling worker may be mid-edit); not overwritten, not force-passed',
                    file_identity=mismatches, passed=None)
    name = f"artifact-replay-{uuid.uuid4().hex[:10]}"
    log = receipts / f"{entry['id']}.log"
    t0 = time.monotonic()
    code, combined = run_vst_retry(container, name, entry['seconds'], entry['workdir'],
                                   ['coqc', *entry.get('coqc_extra_args', []), entry['recompile_file']])
    log.write_text(combined)
    return dict(exit_status=code, elapsed_seconds=round(time.monotonic() - t0, 2), log=str(log),
               log_sha256=hashlib.sha256(combined.encode()).hexdigest(),
               file_identity=mismatches, receipt_name=name, passed=(code == entry['expected_exit']))


def replay_calculus_bytes_oracle_chain(entry, receipts, check_only=False):
    """Fresh recompile of calculus-bytes' Coq oracle (BytesOracle.v + BytesOracleAudit.v)
    against relay's minimal real transitive dependency closure (Protocol/Reach/Conservation/
    Progress/Determinism/ReachExamples/Evaluator -- verified via grep, not assumed). This is
    the kernel-checked tie between calculus-bytes' empirical OCaml comparison and
    RelayReach.outcome that integration/PROOF-CHAIN.md's Coq-final chain relies on."""
    relay_scratch = f"/tmp/artifact-replay-bo-relay-{uuid.uuid4().hex[:8]}"
    bo_scratch = f"/tmp/artifact-replay-bo-{uuid.uuid4().hex[:8]}"
    steps = [
        dict(group='relay-dep', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['relay_dep_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='bytes-oracle', source='host', repo_dir=LIBC / 'phase5/calculus-bytes/coq',
            scratch_dir=bo_scratch, files=entry['bytes_oracle_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, ''], seconds=entry['seconds_per_file']),
    ]
    return run_named_chain(entry, receipts, steps, check_only=check_only)


def replay_calculus_bytes_corpus(entry, receipts, check_only=False):
    """Fresh build of cb_main.exe (same patched pinned tree as ocaml_state_based_pinned_container)
    THEN real execution of the FULL v2 comparison corpus (primary positive + typed + EXTRA_POSITIVE
    + all 7 mutants, matching calculus-bytes' own results/v2/compare_summary_v2.json's 2086
    positive records), compared via calculus-bytes' own compare_bytes.main() (imported and
    called directly with CB_V2=1 and its INTERP/summary paths redirected to this replay's own
    fresh output -- never touches the live repo's results/compare_summary.json). Every
    subprocess call (1 build + 25 runs = 26) goes through its own run_vst.py lock acquire/
    release, never one long hold."""
    container = entry['container']
    all_files = dict(entry['corpus_files'])
    all_files.update(entry.get('fixture_files', {}))
    ok, detail = hash_verify_host(LIBC / 'phase5/calculus-bytes', all_files)
    if check_only:
        return dict(passed=ok, file_identity=detail, check_only=True)
    if not ok:
        return dict(skipped=True, reason='calculus-bytes corpus files diverged from the '
                    'repository; not force-passed', file_identity=detail, passed=None)
    src_dir = entry['container_source_dir']
    scratch = f"/tmp/artifact-replay-cbcorpus-{uuid.uuid4().hex[:8]}"
    t0 = time.monotonic()
    per_step = []

    def do(step_name, run_name, seconds, workdir, argv):
        code, combined = run_vst_retry(container, run_name, seconds, workdir, argv)
        log_path = receipts / f"{entry['id']}-{step_name}.log"
        log_path.write_text(combined)
        per_step.append(dict(step=step_name, exit_status=code, receipt_name=run_name,
                             log=str(log_path), log_sha256=hashlib.sha256(combined.encode()).hexdigest()))
        return code

    outputs = {}
    try:
        subprocess.run(['docker', 'exec', container, 'cp', '-r', src_dir, scratch],
                       check=True, capture_output=True, text=True, timeout=30)
        subprocess.run(['docker', 'exec', container, 'rm', '-rf', f'{scratch}/_build'],
                       check=True, capture_output=True, text=True, timeout=15)
        build_cmd = (f'cd {scratch} && dune build {entry.get("dune_profile_args", "")} '
                    f'{entry.get("dune_target", "")} --display short')
        if do('build', f"artifact-replay-{uuid.uuid4().hex[:8]}", entry['build_seconds'],
              '/tmp', ['bash', '-lc', build_cmd]) != 0:
            raise RuntimeError('cb_main.exe build failed')
        for relpath in all_files:
            dest_subdir = str(Path(relpath).parent)
            subprocess.run(['docker', 'exec', container, 'mkdir', '-p', f'{scratch}/{dest_subdir}'],
                           check=True, capture_output=True, text=True, timeout=15)
            subprocess.run(['docker', 'cp', str(LIBC / 'phase5/calculus-bytes' / relpath),
                            f'{container}:{scratch}/{relpath}'], check=True, capture_output=True,
                           text=True, timeout=15)
        exe = './_build/default/bash-verifier/calculus_bytes/cb_main.exe'

        def run_one(step_name, filename, out_name, ename, casefile='results/cases_curated.tsv',
                    accept_exit=(0,)):
            rn = f"artifact-replay-{uuid.uuid4().hex[:8]}"
            if do(step_name, rn, entry['run_seconds'], scratch,
                  [exe, 'run', filename, ename, casefile]) not in accept_exit:
                raise RuntimeError(f'cb_main.exe run failed: {step_name}')
            outputs[out_name] = (RUNS_DIR / f'{rn}.log').read_text()

        for ename in entry['entries_curated']:
            run_one(f'run-curated-{ename}', 'fixtures/byte_relay_exec.sc', f'curated_{ename}.jsonl', ename)
        for ename in entry['entries_phase3']:
            run_one(f'run-phase3-{ename}', 'fixtures/byte_relay_exec.sc', f'phase3_{ename}.jsonl',
                    ename, 'results/cases_phase3_standard.tsv')
        for ename in entry.get('typed_entries', []):
            run_one(f'run-typed-{ename}', 'fixtures/byte_relay_exec_typed.sc',
                    f'curated_typed_{ename}.jsonl', ename)
        for ename in entry.get('extra_positive_entries', []):
            run_one(f'run-scassert-{ename}', 'fixtures/neg_short_circuit_effect.sc',
                    f'curated_scassert_{ename}.jsonl', ename)
        for m in entry.get('mutants', []):
            for ename in entry.get('mutant_entries', []):
                # exit 4 is cb_main.exe's documented signal for "lowering rejected the program"
                # (check_exit_status.py's own docstring) -- a valid, expected outcome for a
                # mutant like mut_bad_byte (out-of-range literal, rejected statically before any
                # case even runs), not a real failure. compare_bytes.py's own mutant-handling
                # logic already treats a rejected-at-lowering record as a detected mutation.
                run_one(f'run-{m}-{ename}', f'fixtures/{m}.sc', f'{m}_{ename}.jsonl', ename,
                       accept_exit=(0, 4))
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, RuntimeError) as e:
        subprocess.run(['docker', 'exec', container, 'rm', '-rf', scratch], capture_output=True, timeout=15)
        return dict(exit_status=1, elapsed_seconds=round(time.monotonic() - t0, 2),
                   per_step=per_step, error=str(e), passed=False)
    subprocess.run(['docker', 'exec', container, 'rm', '-rf', scratch], capture_output=True, timeout=15)

    # Real jsonl outputs, written to a fresh interp/ dir; hand off to calculus-bytes' own
    # compare_bytes.main() (imported fresh, not reimplemented) via its documented env-var
    # overrides -- CB_V2 enables EXTRA_POSITIVE (module-level gate, must be set before import),
    # CB_INTERP_DIR points it at THIS run's fresh output, CB_SUMMARY redirects its write target
    # away from the live repo's results/compare_summary.json (never touched).
    interp_dir = receipts / f"{entry['id']}-interp"
    interp_dir.mkdir(exist_ok=True)
    for out_name, text in outputs.items():
        (interp_dir / out_name).write_text(text)
    summary_path = receipts / f"{entry['id']}-compare_summary.json"
    old_env = dict(os.environ)
    try:
        os.environ['CB_V2'] = '1'
        os.environ['CB_INTERP_DIR'] = str(interp_dir)
        os.environ['CB_SUMMARY'] = str(summary_path)
        import importlib.util
        cb_dir = LIBC / 'phase5/calculus-bytes'
        spec = importlib.util.spec_from_file_location(f'compare_bytes_fresh_{uuid.uuid4().hex[:8]}',
                                                       cb_dir / 'compare_bytes.py')
        cb = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cb)
        rc = cb.main()
    finally:
        os.environ.clear()
        os.environ.update(old_env)
    cb_summary = json.loads(summary_path.read_text()) if summary_path.exists() else {}
    positive_records = sum(p.get('records', 0) for p in cb_summary.get('positive', []))
    positive_agree = sum(p.get('agree', 0) for p in cb_summary.get('positive', []))
    return dict(exit_status=rc, elapsed_seconds=round(time.monotonic() - t0, 2), per_step=per_step,
               positive_records=positive_records, positive_agree=positive_agree,
               positive_files=len(cb_summary.get('positive', [])),
               mutants_detected=cb_summary.get('all_positive_agree_and_all_mutants_detected'),
               mutant_detail=[dict(mutant=x['mutant'], entry=x['entry'], records=x['records'],
                                   differing=x['differing']) for x in cb_summary.get('mutants', [])],
               file_identity=detail, passed=(rc == 0))


def replay_ocaml_state_based_container(entry, receipts):
    """Corrects the sibling `ocaml_state_based_pinned` entry's host-only 'missing_environment'
    conclusion: an OCaml 4.13.1+flambda / dune 3.21.1 opam switch and a copy of the pinned
    counc009/state_based bash-verifier tree DO exist inside the (idle, shared) phase5-vst
    container under calculus-resume-3/, left there by an already-EXITED sibling worker. This
    entry makes a FRESH in-container copy (never builds in place, never touches the sibling's
    original _build/ or vendor/ caches) and runs a real `dune build` there. Honest limitation
    (recorded, not concealed): the in-container copy has no .git, so the exact pinned commit
    (counc009/state_based@190dd8491b258d8a0ee29f79629908540236b332) is corroborated only by the
    file-path/README cross-reference in calculus-bytes/README.md, not independently re-verified
    against the real upstream git history by this replay. IMPORTANT (fixed after root review):
    the copy, cache-drop and build ALL go through run_vst.py as a single wrapped command --
    never a raw `docker exec` for anything that touches CPU/toolchain state -- so this is
    subject to the same shared compiler_lock and container-idle check as every coqc/gcc call
    elsewhere in this file. An earlier version of this function called `docker exec ... dune
    build` directly, bypassing the lock; that evidence was rejected by root review (a sibling
    worker had a live coqc running in the same container at the time) and is NOT reused here."""
    container = entry['container']
    src_dir = entry['container_source_dir']
    scratch = f"/tmp/artifact-replay-ocaml-{uuid.uuid4().hex[:10]}"
    build_cmd = ('cp -r ' + src_dir + ' ' + scratch
                + ' && rm -rf ' + scratch + '/_build'
                + ' && cd ' + scratch
                + ' && dune build ' + entry.get('dune_profile_args', '') + ' '
                + entry.get('dune_target', '') + ' --display short'
                + ' ; code=$?'
                + ' ; rm -rf ' + scratch
                + ' ; exit $code')
    name = f"artifact-replay-{uuid.uuid4().hex[:10]}"
    log = receipts / f"{entry['id']}.log"
    t0 = time.monotonic()
    code, combined = run_vst_retry(container, name, entry['seconds'], '/tmp', ['bash', '-lc', build_cmd])
    log.write_text(combined)
    return dict(exit_status=code, elapsed_seconds=round(time.monotonic() - t0, 2), log=str(log),
               log_sha256=hashlib.sha256(combined.encode()).hexdigest(),
               fresh_incontainer_copy=True, source_copied_from=src_dir, receipt_name=name,
               lock_protected=True, passed=(code == entry['expected_exit']))


def replay_shell_bridge_chain(entry, receipts, check_only=False):
    """Fresh recompile of shell-bridge's own chain (4 relay deps + 7 shell-bridge files, the
    documented Shell/Parse/Fixtures/Bridge/RandomFixtures/Lex/ShellAudit order from the real
    shell-bridge-final-* receipts). shell-bridge/ is frozen (confirmed: the only live sibling
    that could touch phase5/shell-bridge or phase5/shell-expansion owns shell-expansion only)."""
    relay_scratch = f"/tmp/artifact-replay-sb-relay-{uuid.uuid4().hex[:8]}"
    sb_scratch = f"/tmp/artifact-replay-sb-{uuid.uuid4().hex[:8]}"
    steps = [
        dict(group='relay', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['relay_dep_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='shell-bridge', container_src_dir=entry['container_shell_bridge_dir'],
            scratch_dir=sb_scratch, files=entry['shell_bridge_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, ''], seconds=entry['seconds_per_file']),
    ]
    return run_named_chain(entry, receipts, steps, check_only=check_only)


def replay_relay_full_chain(entry, receipts, check_only=False):
    """Fresh recompile of relay's own full behavioral+adequacy+exit/termination chain (29 files)
    plus a fresh shell-bridge copy for ShellExit.v's dependency (7 more). Real chain, real
    per-file locks -- the entry root review specifically asked for, not an in-place AST check."""
    relay_scratch = f"/tmp/artifact-replay-relayfull-{uuid.uuid4().hex[:8]}"
    sb_scratch = f"/tmp/artifact-replay-relayfull-sb-{uuid.uuid4().hex[:8]}"
    steps = [
        dict(group='relay-base', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['relay_base_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='adequacy', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['adequacy_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='exit', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['exit_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='shell-bridge', container_src_dir=entry['container_shell_bridge_dir'],
            scratch_dir=sb_scratch, files=entry['shell_bridge_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, ''], seconds=entry['seconds_per_file']),
        dict(group='exit-shell', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['shell_exit_file'],
            q_args_fn=lambda f: ['-Q', sb_scratch, ''], seconds=entry['seconds_per_file']),
    ]
    return run_named_chain(entry, receipts, steps, check_only=check_only)


def replay_shell_expansion_accepted(entry, receipts, check_only=False):
    """Fresh recompile of shell-expansion's 5 core files (Pipeline/Redirect/Bridge2/
    ParseExpansion/ShellExpansionAudit), sourced directly from the HOST repo checkout (not a
    container mirror) since shell-expansion/ is under live, active edit by a sibling worker
    (shell-parser-semantics-8) -- this entry always reflects the true current repo state and
    SKIPS honestly (does not force-pass) if that state doesn't hash-match what was recorded when
    this entry was last updated, or simply fails to compile because it's mid-edit. Explicitly
    does NOT include shell-expansion/extended/Compose.v (the new pipe/redirect work still being
    authored) -- that is a separate 'pending' manifest entry, never silently merged in here."""
    relay_scratch = f"/tmp/artifact-replay-se-relay-{uuid.uuid4().hex[:8]}"
    sb_scratch = f"/tmp/artifact-replay-se-sb-{uuid.uuid4().hex[:8]}"
    se_scratch = f"/tmp/artifact-replay-se-{uuid.uuid4().hex[:8]}"
    steps = [
        dict(group='relay-dep', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['relay_dep_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='shell-bridge-dep', container_src_dir=entry['container_shell_bridge_dir'],
            scratch_dir=sb_scratch, files=entry['shell_bridge_dep_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, ''], seconds=entry['seconds_per_file']),
        dict(group='shell-expansion', source='host', repo_dir=LIBC / 'phase5/shell-expansion',
            scratch_dir=se_scratch, files=entry['shell_expansion_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, '', '-Q', sb_scratch, ''],
            seconds=entry['seconds_per_file']),
    ]
    return run_named_chain(entry, receipts, steps, check_only=check_only)


def replay_shell_expansion_compose_chain(entry, receipts, check_only=False):
    """Fresh recompile of shell-expansion/extended's Compose.v + ComposeAudit.v, same relay/
    shell-bridge dependency set as replay_shell_expansion_accepted. Host-staged since this
    directory may still see edits from the shell-expansion lineage."""
    relay_scratch = f"/tmp/artifact-replay-cmp-relay-{uuid.uuid4().hex[:8]}"
    sb_scratch = f"/tmp/artifact-replay-cmp-sb-{uuid.uuid4().hex[:8]}"
    se_scratch = f"/tmp/artifact-replay-cmp-se-{uuid.uuid4().hex[:8]}"
    cmp_scratch = f"/tmp/artifact-replay-cmp-{uuid.uuid4().hex[:8]}"
    steps = [
        dict(group='relay-dep', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['relay_dep_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='shell-bridge-dep', container_src_dir=entry['container_shell_bridge_dir'],
            scratch_dir=sb_scratch, files=entry['shell_bridge_dep_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, ''], seconds=entry['seconds_per_file']),
        dict(group='shell-expansion-dep', source='host', repo_dir=LIBC / 'phase5/shell-expansion',
            scratch_dir=se_scratch, files=entry['shell_expansion_dep_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, '', '-Q', sb_scratch, ''],
            seconds=entry['seconds_per_file']),
        dict(group='compose', source='host', repo_dir=LIBC / 'phase5/shell-expansion/extended',
            scratch_dir=cmp_scratch, files=entry['compose_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, '', '-Q', sb_scratch, '', '-Q', se_scratch, ''],
            seconds=entry['seconds_per_file']),
    ]
    return run_named_chain(entry, receipts, steps, check_only=check_only)


def replay_case_wrapper_transfer_chain(entry, receipts):
    """Immutable full closure, per-TU wrapper audits, no cached compiler results."""
    arch = LIBC / entry['archive_dir']
    scratch = {g: f"/tmp/artifact-replay-case44-{g}-{uuid.uuid4().hex[:8]}"
               for g in ('relay', 'iow', 'case')}
    steps = []
    for group in entry['source_groups']:
        name = group['group']
        dest = scratch['case' if name == 'generated' else name]
        q = [] if name == 'relay' else ['-Q', scratch['relay'], '']
        if name in ('generated', 'case'):
            q += ['-Q', scratch['iow'], '']
        steps.append(dict(group=name, source='host', repo_dir=arch / name,
                          scratch_dir=dest, files=group['files'],
                          q_args_fn=lambda f, q=q: q,
                          seconds=entry['seconds_per_file']))
    result = run_named_chain(entry, receipts, steps)
    audits = {}
    for item in result.get('per_file', []):
        ok, reason = verify_real_receipt(item['receipt_name'], item['file'])
        item['real_receipt_verified'] = ok
        item['real_receipt_error'] = reason
        rp = RUNS_DIR / (item['receipt_name'] + '.json')
        lp = RUNS_DIR / (item['receipt_name'] + '.log')
        item['compiler_receipt'] = str(rp)
        item['compiler_log'] = str(lp)
        item['compiler_log_sha256'] = sha(lp) if lp.exists() else None
        if not ok:
            result['passed'] = False
        expected = entry['audit_lemmas'].get(item['file'])
        if expected and lp.exists():
            output = lp.read_text()
            # The trailing Check commands print theorem types after the final
            # assumption block; they are not additional axioms.
            assumption_output = re.split(
                r'^' + re.escape(next(iter(expected))) + r'\s*$',
                output, maxsplit=1, flags=re.M)[0]
            blocks = assumption_output.split('Axioms:')[1:]
            for (lemma, allowed), block in zip(expected.items(), blocks):
                actual = re.findall(r'^([A-Za-z_][\w.]*)\s*:', block, re.M)
                audits[lemma] = dict(axioms=actual, expected=allowed,
                    passed=(len(blocks) == len(expected) and actual == allowed
                            and re.search(r'^' + re.escape(lemma) + r'\s*$', output, re.M) is not None))
    result['assumption_audits'] = audits
    result['all_four_assumptions_verified'] = (len(audits) == 4 and
        all(a['passed'] for a in audits.values()))
    result['passed'] = bool(result.get('passed') and result['all_four_assumptions_verified'])
    result['cache_enabled'] = False
    result['staged_from'] = str(arch)
    return result


def replay_case_studies_full_chain(entry, receipts, check_only=False):
    """Fresh recompile of BOTH accepted case-studies body proofs (head_bytes AND wc_lines,
    case-proofs-9 finished the latter -- ROOT-WC-VERIFICATION.json) plus CaseAudit.v: relay's 6
    base files + utility-reuse's IOWorld/IOSpecs + the 2 generated Clight fragments +
    CaseWorld/CaseSpecs/HeadBytesBody/WcLinesBody/CaseAudit. case-studies/ is host-staged
    (source='host') since that directory may still see edits -- always re-verifies against the
    CURRENT repo checkout, skips honestly on divergence."""
    relay_scratch = f"/tmp/artifact-replay-hb-relay-{uuid.uuid4().hex[:8]}"
    ur_scratch = f"/tmp/artifact-replay-hb-ur-{uuid.uuid4().hex[:8]}"
    cs_scratch = f"/tmp/artifact-replay-hb-cs-{uuid.uuid4().hex[:8]}"
    steps = [
        dict(group='relay-dep', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['relay_dep_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='utility-reuse-dep', container_src_dir=entry['container_utility_reuse_dir'],
            scratch_dir=ur_scratch, files=entry['utility_reuse_dep_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, ''], seconds=entry['seconds_per_file']),
        dict(group='case-studies-generated', source='host',
            repo_dir=LIBC / 'phase5/case-studies/generated', scratch_dir=cs_scratch,
            files=entry['case_studies_generated_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, '', '-Q', ur_scratch, ''],
            seconds=entry['seconds_per_file']),
        dict(group='case-studies', source='host', repo_dir=LIBC / 'phase5/case-studies/coq',
            scratch_dir=cs_scratch, files=entry['case_studies_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, '', '-Q', ur_scratch, ''],
            seconds=entry['seconds_per_file']),
    ]
    return run_named_chain(entry, receipts, steps, check_only=check_only)


def replay_universal_full_chain(entry, receipts, check_only=False):
    """Fresh recompile of universal-relay-4's FULL chain: its real transitive dependency closure
    (21 relay/adequacy/exit files + 3 shell-bridge files, computed from actual Require graphs)
    then the 7 universal files themselves, using the exact -Q pattern from the real accepted
    receipts (universal-exit-coqc-4, universal-main-coqc-*, universal-replay-shell-1)."""
    relay_scratch = f"/tmp/artifact-replay-univ-relay-{uuid.uuid4().hex[:8]}"
    sb_scratch = f"/tmp/artifact-replay-univ-sb-{uuid.uuid4().hex[:8]}"
    uni_scratch = f"/tmp/artifact-replay-univ-{uuid.uuid4().hex[:8]}"
    steps = [
        dict(group='relay-dep', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['relay_dep_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='adequacy-dep', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['adequacy_dep_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='exit-dep', container_src_dir=entry['container_relay_dir'],
            scratch_dir=relay_scratch, files=entry['exit_dep_files'], q_args_fn=lambda f: [],
            seconds=entry['seconds_per_file']),
        dict(group='shell-bridge-dep', container_src_dir=entry['container_shell_bridge_dir'],
            scratch_dir=sb_scratch, files=entry['shell_bridge_dep_files'],
            q_args_fn=lambda f: ['-Q', relay_scratch, ''], seconds=entry['seconds_per_file']),
        dict(group='universal', container_src_dir=entry['container_universal_dir'],
            scratch_dir=uni_scratch, files=entry['universal_files'],
            q_args_fn=lambda f: (['-Q', relay_scratch, '', '-Q', uni_scratch, '']
                                 + (['-Q', sb_scratch, ''] if f == 'UniversalShell.v' else [])),
            seconds=entry['seconds_per_file']),
    ]
    return run_named_chain(entry, receipts, steps, check_only=check_only)


def jsonl_lines(text):
    """Extract JSON object lines from a run_vst log (ignore timing/wrapper noise)."""
    out = []
    for line in text.splitlines():
        s = line.strip()
        if s.startswith('{') and s.endswith('}'):
            out.append(s)
    return '\n'.join(out) + ('\n' if out else '')


def replay_calculus_bytes_check_v2(entry, receipts, check_only=False):
    """Fresh patched cb_main.exe from calculus-resume-3, then EVERY input original
    check_v2.py requires: one `run` per EXPECT (fixture, fn) record plus one `lower`
    of the v2/neg fixtures. Host check_v2.main() is invoked with V2 redirected to
    this replay's private directory -- never writes calculus-bytes/results/v2/."""
    import importlib.util
    cb_dir = LIBC / 'phase5/calculus-bytes'
    spec = importlib.util.spec_from_file_location(
        f'check_v2_fresh_{uuid.uuid4().hex[:8]}', cb_dir / 'check_v2.py')
    cv = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(cv)
    expect_n = len(cv.EXPECT)
    neg_n = len(cv.NEGATIVES_MUST_REJECT)
    if expect_n != entry['expected_function_records'] or neg_n != entry['expected_lowering_negatives']:
        return dict(passed=False, error=f'check_v2 counts drifted: EXPECT={expect_n} '
                    f'NEGATIVES={neg_n} vs manifest {entry["expected_function_records"]}+'
                    f'{entry["expected_lowering_negatives"]}')
    if len(set(cv.EXPECT)) != expect_n:
        return dict(passed=False, error='duplicate EXPECT keys')
    if len(set(cv.NEGATIVES_MUST_REJECT)) != neg_n:
        return dict(passed=False, error='duplicate NEGATIVES_MUST_REJECT names')
    host_files = dict(entry['fixture_files'])
    host_files.update(entry.get('neg_files', {}))
    host_files.update(entry.get('support_files', {}))
    ok, detail = hash_verify_host(cb_dir, host_files)
    if check_only:
        return dict(passed=ok, file_identity=detail, check_only=True)
    if not ok:
        return dict(skipped=True, reason='check_v2 fixtures diverged from the repository; '
                    'not force-passed', file_identity=detail, passed=None)
    container = entry['container']
    src_dir = entry['container_source_dir']
    interp_ok, interp_detail = hash_verify(
        container, f'{src_dir}/bash-verifier/lib/calculus', entry['patched_calculus_files'])
    buil_ok, buil_detail = hash_verify(
        container, f'{src_dir}/bash-verifier/calculus_bytes', entry['patched_adapter_files'])
    detail.update({f'container/{k}': v for k, v in interp_detail.items()})
    detail.update({f'container/{k}': v for k, v in buil_detail.items()})
    if not (interp_ok and buil_ok):
        return dict(skipped=True, reason='calculus-resume-3 patched sources diverged; '
                    'not force-passed', file_identity=detail, passed=None)
    scratch = f"/tmp/artifact-replay-checkv2-{uuid.uuid4().hex[:8]}"
    t0 = time.monotonic()
    per_step = []
    v2_dir = receipts / f"{entry['id']}-v2"
    v2_dir.mkdir(parents=True)

    def do(step_name, run_name, seconds, workdir, argv, accept_exit):
        code, combined = run_vst_retry(container, run_name, seconds, workdir, argv)
        log_path = receipts / f"{entry['id']}-{step_name}.log"
        log_path.write_text(combined)
        per_step.append(dict(step=step_name, exit_status=code, receipt_name=run_name,
                             expected_exit=list(accept_exit),
                             log=str(log_path),
                             log_sha256=hashlib.sha256(combined.encode()).hexdigest()))
        if code not in accept_exit:
            raise RuntimeError(f'{step_name} exit {code} not in {accept_exit}')
        # Interpreter stdout lives in run_vst's .log, not in run_vst.py's receipt JSON stdout.
        exe_log = (RUNS_DIR / f'{run_name}.log').read_text() if (RUNS_DIR / f'{run_name}.log').exists() else ''
        return code, exe_log

    try:
        subprocess.run(['docker', 'exec', container, 'cp', '-r', src_dir, scratch],
                       check=True, capture_output=True, text=True, timeout=30)
        subprocess.run(['docker', 'exec', container, 'rm', '-rf', f'{scratch}/_build'],
                       check=True, capture_output=True, text=True, timeout=15)
        build_cmd = (f'cd {scratch} && dune build {entry.get("dune_profile_args", "")} '
                     f'{entry.get("dune_target", "")} --display short')
        do('build', f"artifact-replay-{uuid.uuid4().hex[:8]}", entry['build_seconds'],
           '/tmp', ['bash', '-lc', build_cmd], (0,))
        for relpath in host_files:
            dest_subdir = str(Path(relpath).parent)
            subprocess.run(['docker', 'exec', container, 'mkdir', '-p', f'{scratch}/{dest_subdir}'],
                           check=True, capture_output=True, text=True, timeout=15)
            subprocess.run(['docker', 'cp', str(cb_dir / relpath),
                            f'{container}:{scratch}/{relpath}'],
                           check=True, capture_output=True, text=True, timeout=15)
        exe = './_build/default/bash-verifier/calculus_bytes/cb_main.exe'
        seen_run = []
        for (fixture, fn) in sorted(cv.EXPECT):
            step = f'run-{fixture}-{fn}'
            rn = f"artifact-replay-{uuid.uuid4().hex[:8]}"
            code, combined = do(step, rn, entry['run_seconds'], scratch,
                                [exe, 'run', f'fixtures/v2/{fixture}.sc', fn,
                                 'cases/cases_unit.tsv'],
                                tuple(entry.get('run_accept_exit', [0])))
            body = jsonl_lines(combined)
            outp = v2_dir / f'{fixture}__{fn}.jsonl'
            if outp.exists():
                raise RuntimeError(f'duplicate output path {outp.name}')
            outp.write_text(body)
            seen_run.append(f'{fixture}__{fn}')
        if len(seen_run) != expect_n or len(set(seen_run)) != expect_n:
            raise RuntimeError(f'run record count {len(seen_run)} unique {len(set(seen_run))} != {expect_n}')
        neg_paths = [f'fixtures/v2/neg/{n}.sc' for n in cv.NEGATIVES_MUST_REJECT]
        rn = f"artifact-replay-{uuid.uuid4().hex[:8]}"
        code, combined = do('lower-negatives', rn, entry['run_seconds'], scratch,
                            [exe, 'lower', *neg_paths],
                            tuple(entry.get('lower_accept_exit', [0, 4])))
        body = jsonl_lines(combined)
        (v2_dir / 'lower_negatives.jsonl').write_text(body)
        stems = []
        for line in body.splitlines():
            if not line.strip():
                continue
            d = json.loads(line)
            stems.append(Path(d['file']).stem)
        if len(stems) != len(set(stems)):
            raise RuntimeError(f'duplicate lower_negatives stems: {stems}')
        unexpected = sorted(set(stems) - set(cv.NEGATIVES_MUST_REJECT))
        missing = sorted(set(cv.NEGATIVES_MUST_REJECT) - set(stems))
        if unexpected or missing:
            raise RuntimeError(f'lower_negatives unexpected={unexpected} missing={missing}')
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, RuntimeError, json.JSONDecodeError) as e:
        subprocess.run(['docker', 'exec', container, 'rm', '-rf', scratch],
                       capture_output=True, timeout=15)
        return dict(exit_status=1, elapsed_seconds=round(time.monotonic() - t0, 2),
                    per_step=per_step, error=str(e), file_identity=detail, passed=False)
    subprocess.run(['docker', 'exec', container, 'rm', '-rf', scratch],
                   capture_output=True, timeout=15)

    old_v2 = cv.V2
    try:
        cv.V2 = v2_dir
        rc = cv.main()
    finally:
        cv.V2 = old_v2
    summary_path = v2_dir / 'check_v2_summary.json'
    summary = json.loads(summary_path.read_text()) if summary_path.exists() else {}
    checked = summary.get('checked')
    problems = summary.get('problems') or []
    # Never claim 63/0 unless the original checker said so on FRESH files.
    passed = (rc == 0 and checked == (expect_n + neg_n) and problems == [])
    return dict(exit_status=rc, elapsed_seconds=round(time.monotonic() - t0, 2),
                per_step=per_step, file_identity=detail,
                check_v2_checked=checked, check_v2_problems=problems,
                check_v2_summary=str(summary_path),
                v2_dir=str(v2_dir),
                function_records=expect_n, lowering_negatives=neg_n,
                script_sha256=entry['support_files']['check_v2.py'],
                passed=passed)




def replay_lean_calculus_body(entry, receipts):
    """Fresh isolated project from immutable archive/calculus-body13.
    Sequential pinned Lean (Lakefile staged, not executed). Shared lock.
    #eval receipts are finite tokenize identity, not a theorem tokenizer.
    """
    arch = LIBC / entry['archive_dir']
    files = entry['source_files']
    identity = {}
    for fname, expect in files.items():
        src = arch / fname
        actual = sha(src)
        identity[fname] = dict(expected=expect, actual=actual, matches=(actual == expect))
    identity_ok = all(v['matches'] for v in identity.values())
    eval_frozen = LIBC / 'phase5/artifact/archive/CalculusNested.evaluation-frozen.lean'
    eval_hash = sha(eval_frozen)
    eval_ok = eval_hash == entry['evaluation_frozen_sha256']
    tsv = arch / entry['tsv_file']
    tsv_hash = sha(tsv)
    tsv_ok = tsv_hash == entry['tsv_sha256']
    scratch = fresh_scratch('lean-calculus-body')
    (scratch / 'lean-toolchain').write_text((arch / 'lean-toolchain').read_text())
    (scratch / 'lakefile.toml').write_text(BODY_LAKEFILE)
    for fname in files:
        shutil.copy2(arch / fname, scratch / fname)
    blog = receipts / f"{entry['id']}.build.log"
    try:
        lean = _pinned_lean_binary()
        order = lean_compile_order(scratch, ['CalculusBody'])
        compiled = compile_lean_modules_sequential(
            lean, scratch, order, receipts, entry['id'] + '.build',
            seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT)
    except (ValueError, OSError) as exc:
        Path(blog).write_text(str(exc) + '\n')
        return dict(exit_status=None, elapsed_seconds=0, log=str(blog), scratch=str(scratch),
                    source_identity_ok=identity_ok, file_identity=identity, passed=False, reason=str(exc))
    secs = sum(p.get('elapsed_seconds') or 0 for p in compiled['per_file'])
    Path(blog).write_text((compiled.get('reason') or compiled['log']) + '\n')
    if compiled.get('skipped'):
        return dict(skipped=True, reason='compiler lock busy',
                    passed=None, file_identity=identity,
                    exit_status=None, elapsed_seconds=secs, log=str(blog))
    code = compiled['exit_status']
    if not compiled['ok']:
        return dict(skipped=False, reason=compiled['reason'],
                    passed=False, file_identity=identity,
                    exit_status=code, elapsed_seconds=round(secs, 2), log=str(blog),
                    source_identity_ok=identity_ok)
    axiom_results = {}
    eval_ok_runtime = False
    sorry_ax = False
    ccode = None
    if code == 0:
        clog = receipts / f"{entry['id']}.receipts.log"
        check_compiled = compile_lean_modules_sequential(
            lean, scratch, ['CalculusBodyReceipts'], receipts, entry['id'] + '.receipts',
            seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT)
        ccode = check_compiled['exit_status']
        src_log = Path(check_compiled['per_file'][0]['log']) if check_compiled['per_file'] else clog
        if src_log.exists() and src_log != clog:
            clog.write_text(src_log.read_text())
        out = clog.read_text() if clog.exists() else ''
        named = entry['theorems']
        theorems_ok, axiom_results = audit_theorems_ok(out, named, check_compiled)
        sorry_ax = 'sorryAx' in out or 'sorryAx' in blog.read_text()
        eval_ok_runtime = out.count('(true, true)') >= 2
        theorems_ok = theorems_ok and eval_ok_runtime and not sorry_ax
    else:
        theorems_ok = False
        sorry_ax = False
        eval_ok_runtime = False
        named = entry['theorems']
        check_compiled = None
    per_file = list(compiled.get('per_file') or [])
    if check_compiled:
        per_file.extend(check_compiled.get('per_file') or [])
    return dict(exit_status=code, audit_exit_status=ccode, elapsed_seconds=secs,
                log=str(blog), scratch=str(scratch),
                source_identity_ok=identity_ok, file_identity=identity,
                evaluation_frozen_untouched=eval_ok, evaluation_frozen_sha256=eval_hash,
                tsv_identity_ok=tsv_ok, tsv_sha256_actual=tsv_hash,
                axiom_results=axiom_results, sorryAx=sorry_ax,
                eval_text_token_ok=eval_ok_runtime, per_file=per_file,
                build_log_sha256=sha(blog) if blog.exists() else None,
                receipts_log_sha256=sha(receipts / f"{entry['id']}.receipts.log")
                if (receipts / f"{entry['id']}.receipts.log").exists() else None,
                passed=(identity_ok and eval_ok and tsv_ok and theorems_ok))



def replay_lean_calculus_outer(entry, receipts):
    """Fresh isolated project from immutable archive/calculus-outer14.
    Sequential pinned Lean (Lakefile staged, not executed). 17-theorem axiom audit.
    Scope: runEntry fuel 2*|input|+108 status {0,1,2}; not general lowering.
    """
    arch = LIBC / entry['archive_dir']
    files = entry['source_files']
    identity = {}
    for fname, expect in files.items():
        src = arch / fname
        actual = sha(src)
        identity[fname] = dict(expected=expect, actual=actual, matches=(actual == expect))
    identity_ok = all(v['matches'] for v in identity.values())
    eval_frozen = LIBC / 'phase5/artifact/archive/CalculusNested.evaluation-frozen.lean'
    eval_hash = sha(eval_frozen)
    eval_ok = eval_hash == entry['evaluation_frozen_sha256']
    scratch = fresh_scratch('lean-calculus-outer')
    (scratch / 'lean-toolchain').write_text((arch / 'lean-toolchain').read_text())
    (scratch / 'lakefile.toml').write_text(OUTER_LAKEFILE)
    for fname in files:
        shutil.copy2(arch / fname, scratch / fname)
    blog = receipts / f"{entry['id']}.build.log"
    try:
        lean = _pinned_lean_binary()
        order = lean_compile_order(scratch, ['CalculusRelayOuter'])
        compiled = compile_lean_modules_sequential(
            lean, scratch, order, receipts, entry['id'] + '.build',
            seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT)
    except (ValueError, OSError) as exc:
        Path(blog).write_text(str(exc) + '\n')
        return dict(exit_status=None, elapsed_seconds=0, log=str(blog), scratch=str(scratch),
                    source_identity_ok=identity_ok, file_identity=identity, passed=False, reason=str(exc))
    secs = sum(p.get('elapsed_seconds') or 0 for p in compiled['per_file'])
    Path(blog).write_text((compiled.get('reason') or compiled['log']) + '\n')
    if compiled.get('skipped'):
        return dict(skipped=True, reason='compiler lock busy',
                    passed=None, file_identity=identity,
                    exit_status=None, elapsed_seconds=secs, log=str(blog))
    code = compiled['exit_status']
    if not compiled['ok']:
        return dict(skipped=False, reason=compiled['reason'],
                    passed=False, file_identity=identity,
                    exit_status=code, elapsed_seconds=round(secs, 2), log=str(blog),
                    source_identity_ok=identity_ok)
    axiom_results = {}
    eval_ok_runtime = False
    sorry_ax = False
    ccode = None
    if code == 0:
        clog = receipts / f"{entry['id']}.axioms.log"
        check_compiled = compile_lean_modules_sequential(
            lean, scratch, ['CalculusRelayLoopAxioms'], receipts, entry['id'] + '.axioms',
            seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT)
        ccode = check_compiled['exit_status']
        src_log = Path(check_compiled['per_file'][0]['log']) if check_compiled['per_file'] else clog
        if src_log.exists() and src_log != clog:
            clog.write_text(src_log.read_text())
        out = clog.read_text() if clog.exists() else ''
        named = entry['theorems']
        theorems_ok, axiom_results = audit_theorems_ok(out, named, check_compiled)
        sorry_ax = 'sorryAx' in out or 'sorryAx' in blog.read_text()
        eval_ok_runtime = '(true, true)' in out
        theorems_ok = theorems_ok and eval_ok_runtime and not sorry_ax
    else:
        theorems_ok = False
        sorry_ax = False
        eval_ok_runtime = False
        named = entry['theorems']
        check_compiled = None
    per_file = list(compiled.get('per_file') or [])
    if check_compiled:
        per_file.extend(check_compiled.get('per_file') or [])
    return dict(exit_status=code, audit_exit_status=ccode, elapsed_seconds=secs,
                log=str(blog), scratch=str(scratch),
                source_identity_ok=identity_ok, file_identity=identity,
                evaluation_frozen_untouched=eval_ok, evaluation_frozen_sha256=eval_hash,
                axiom_results=axiom_results, sorryAx=sorry_ax,
                eval_text_token_ok=eval_ok_runtime, per_file=per_file,
                theorems_found=sorted(axiom_results),
                build_log_sha256=sha(blog) if blog.exists() else None,
                axioms_log_sha256=sha(receipts / f"{entry['id']}.axioms.log")
                if (receipts / f"{entry['id']}.axioms.log").exists() else None,
                passed=(identity_ok and eval_ok and theorems_ok),
                scope=entry.get('scope'))


def replay_utility_juicy_dry_chain(entry, receipts, check_only=False):
    """Stage 13 accepted juicy-dry sources + hash-checked relay/IOW deps from the
    immutable archive (NOT live utility-reuse/adequacy). Fresh scratch, no stale .vo.
    Print Assumptions via archived Audit13Specs.v. Scope: iow_juicy_dry_post /
    iow_juicy_dry_specs / mem_evolve only.
    """
    arch = LIBC / entry['archive_dir']
    src_dir = arch / 'sources'
    relay_arch = arch / 'deps-relay'
    iow_arch = arch / 'deps-iow'
    dry_arch = arch / 'deps-dry'
    ok_src, detail_src = hash_verify_host(src_dir, entry['juicy_dry_files'])
    ok_rel, detail_rel = hash_verify_host(relay_arch, entry['relay_dep_files'])
    ok_iow, detail_iow = hash_verify_host(iow_arch, entry['iow_dep_files'])
    ok_dry, detail_dry = hash_verify_host(dry_arch, entry['dry_lemma_files'])
    live_rel, live_rel_d = hash_verify_host(LIBC / 'phase5/relay', entry['relay_dep_files'])
    live_iow, live_iow_d = hash_verify_host(LIBC / 'phase5/utility-reuse/coq', entry['iow_dep_files'])
    live_dry, live_dry_d = hash_verify_host(LIBC / 'phase5/relay/adequacy', entry['dry_lemma_files'])
    identity = {}
    for prefix, d in (('archive-src', detail_src), ('archive-relay', detail_rel),
                      ('archive-iow', detail_iow), ('archive-dry', detail_dry),
                      ('live-relay', live_rel_d),
                      ('live-iow', live_iow_d), ('live-dry', live_dry_d)):
        for k, v in d.items():
            identity[f'{prefix}/{k}'] = v
    if not (ok_src and ok_rel and ok_iow and ok_dry and live_rel and live_iow and live_dry):
        return dict(skipped=True, reason='source identity fail-closed (archive or live dep hash mismatch)',
                    file_identity=identity, passed=None)
    if check_only:
        return dict(passed=True, file_identity=identity, check_only=True)
    relay_scratch = f"/tmp/artifact-replay-jd13-relay-{uuid.uuid4().hex[:8]}"
    iow_scratch = f"/tmp/artifact-replay-jd13-iow-{uuid.uuid4().hex[:8]}"
    dry_scratch = f"/tmp/artifact-replay-jd13-dry-{uuid.uuid4().hex[:8]}"
    jd_scratch = f"/tmp/artifact-replay-jd13-{uuid.uuid4().hex[:8]}"
    steps = [
        dict(group='relay-dep', source='host', repo_dir=relay_arch,
             scratch_dir=relay_scratch, files=entry['relay_dep_files'],
             q_args_fn=lambda f: [], seconds=entry.get('seconds_per_file', 180)),
        dict(group='iow-dep', source='host', repo_dir=iow_arch,
             scratch_dir=iow_scratch, files=entry['iow_dep_files'],
             q_args_fn=lambda f: ['-Q', relay_scratch, ''],
             seconds=entry.get('seconds_per_file', 180)),
        dict(group='dry-lemma', source='host', repo_dir=dry_arch,
             scratch_dir=dry_scratch, files=entry['dry_lemma_files'],
             q_args_fn=lambda f: [], seconds=entry.get('seconds_per_file', 180)),
        dict(group='juicy-dry', source='host', repo_dir=src_dir,
             scratch_dir=jd_scratch, files=entry['juicy_dry_files'],
             q_args_fn=lambda f: ['-Q', relay_scratch, '', '-Q', iow_scratch, '',
                                 '-Q', dry_scratch, '', '-Q', jd_scratch, ''],
             seconds=entry.get('seconds_per_file', 180)),
    ]
    r = run_named_chain(entry, receipts, steps, check_only=False)
    r['file_identity'] = identity
    r['staged_from'] = str(arch)
    r['scope'] = entry.get('scope')
    r['not_claimed'] = ['world_bridge', 'write_PRE', 'full_juicy_transport']
    return r


def replay_lean_calculus_spec15(entry, receipts):
    """Fresh isolated project from immutable archive/calculus-spec15.
    Sequential pinned Lean (Lakefile staged, not executed). Exact-relay phase3
    correspondence only. Tokenizer omitted. Entry-specific axioms file generated here.
    """
    arch = LIBC / entry['archive_dir']
    files = entry['source_files']
    identity = {}
    for fname, expect in files.items():
        src = arch / fname
        actual = sha(src)
        identity[fname] = dict(expected=expect, actual=actual, matches=(actual == expect))
    identity_ok = all(v['matches'] for v in identity.values())
    eval_frozen = LIBC / 'phase5/artifact/archive/CalculusNested.evaluation-frozen.lean'
    eval_hash = sha(eval_frozen)
    eval_ok = eval_hash == entry['evaluation_frozen_sha256']
    outer14 = LIBC / 'phase5/artifact/archive/calculus-outer14/CalculusRelayOuter.lean'
    outer14_hash = sha(outer14)
    outer14_untouched = outer14_hash == entry.get('outer14_sha256')
    scratch = fresh_scratch('lean-calculus-spec15')
    (scratch / 'lean-toolchain').write_text((arch / 'lean-toolchain').read_text())
    (scratch / 'lakefile.toml').write_text(SPEC_LAKEFILE)
    for fname in files:
        shutil.copy2(arch / fname, scratch / fname)
    (scratch / 'CalculusRelaySpecAxioms.lean').write_text(SPEC_AXIOMS)
    blog = receipts / f"{entry['id']}.build.log"
    try:
        lean = _pinned_lean_binary()
        order = lean_compile_order(scratch, ['CalculusRelaySpec'])
        compiled = compile_lean_modules_sequential(
            lean, scratch, order, receipts, entry['id'] + '.build',
            seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT)
    except (ValueError, OSError) as exc:
        Path(blog).write_text(str(exc) + '\n')
        return dict(exit_status=None, elapsed_seconds=0, log=str(blog), scratch=str(scratch),
                    source_identity_ok=identity_ok, file_identity=identity, passed=False, reason=str(exc))
    secs = sum(p.get('elapsed_seconds') or 0 for p in compiled['per_file'])
    Path(blog).write_text((compiled.get('reason') or compiled['log']) + '\n')
    if compiled.get('skipped'):
        return dict(skipped=True, reason='compiler lock busy',
                    passed=None, file_identity=identity,
                    exit_status=None, elapsed_seconds=secs, log=str(blog))
    code = compiled['exit_status']
    if not compiled['ok']:
        return dict(skipped=False, reason=compiled['reason'],
                    passed=False, file_identity=identity,
                    exit_status=code, elapsed_seconds=round(secs, 2), log=str(blog),
                    source_identity_ok=identity_ok)
    axiom_results = {}
    sorry_ax = False
    ccode = None
    if code == 0:
        clog = receipts / f"{entry['id']}.axioms.log"
        check_compiled = compile_lean_modules_sequential(
            lean, scratch, ['CalculusRelaySpecAxioms'], receipts, entry['id'] + '.axioms',
            seconds=LEAN_COMPILER_SECONDS, lock_wait=LEAN_LOCK_WAIT)
        ccode = check_compiled['exit_status']
        src_log = Path(check_compiled['per_file'][0]['log']) if check_compiled['per_file'] else clog
        if src_log.exists() and src_log != clog:
            clog.write_text(src_log.read_text())
        out = clog.read_text() if clog.exists() else ''
        named = entry['theorems']
        theorems_ok, axiom_results = audit_theorems_ok(out, named, check_compiled)
        sorry_ax = 'sorryAx' in out or 'sorryAx' in blog.read_text()
        theorems_ok = theorems_ok and not sorry_ax
    else:
        theorems_ok = False
        sorry_ax = False
        named = entry['theorems']
        check_compiled = None
    per_file = list(compiled.get('per_file') or [])
    if check_compiled:
        per_file.extend(check_compiled.get('per_file') or [])
    return dict(exit_status=code, audit_exit_status=ccode, elapsed_seconds=secs,
                log=str(blog), scratch=str(scratch),
                source_identity_ok=identity_ok, file_identity=identity,
                evaluation_frozen_untouched=eval_ok, evaluation_frozen_sha256=eval_hash,
                outer14_untouched=outer14_untouched, outer14_sha256=outer14_hash,
                axiom_results=axiom_results, sorryAx=sorry_ax, per_file=per_file,
                theorems_found=sorted(axiom_results),
                build_log_sha256=sha(blog) if blog.exists() else None,
                axioms_log_sha256=sha(receipts / f"{entry['id']}.axioms.log")
                if (receipts / f"{entry['id']}.axioms.log").exists() else None,
                passed=(identity_ok and eval_ok and outer14_untouched and theorems_ok),
                scope=entry.get('scope'),
                tokenizer_included=False)


def replay_utility_pre_drypost_chain(entry, receipts, check_only=False):
    """Stage utility-14 PRE+dryPOST sources + 4 accepted audits from immutable
    archive/utility-pre14 (review31 snapshot), with archived relay/IOW/errno-world
    deps. Not live utility-reuse/adequacy. Scope: PRE transport + dry POST chaining.
    """
    arch = LIBC / entry['archive_dir']
    src_dir = arch / 'sources'
    aud_dir = arch / 'audits'
    relay_arch = arch / 'deps-relay'
    iow_arch = arch / 'deps-iow'
    dry_arch = arch / 'deps-dry'
    ok_src, detail_src = hash_verify_host(src_dir, entry['utility_pre_files'])
    ok_aud, detail_aud = hash_verify_host(aud_dir, entry['audit_files'])
    ok_rel, detail_rel = hash_verify_host(relay_arch, entry['relay_dep_files'])
    ok_iow, detail_iow = hash_verify_host(iow_arch, entry['iow_dep_files'])
    ok_dry, detail_dry = hash_verify_host(dry_arch, entry['dry_lemma_files'])
    live_rel, live_rel_d = hash_verify_host(LIBC / 'phase5/relay', entry['relay_dep_files'])
    live_iow, live_iow_d = hash_verify_host(LIBC / 'phase5/utility-reuse/coq', entry['iow_dep_files'])
    live_dry, live_dry_d = hash_verify_host(LIBC / 'phase5/relay/adequacy', entry['dry_lemma_files'])
    identity = {}
    for prefix, d in (('archive-src', detail_src), ('archive-audit', detail_aud),
                      ('archive-relay', detail_rel), ('archive-iow', detail_iow),
                      ('archive-dry', detail_dry), ('live-relay', live_rel_d),
                      ('live-iow', live_iow_d), ('live-dry', live_dry_d)):
        for k, v in d.items():
            identity[f'{prefix}/{k}'] = v
    if not (ok_src and ok_aud and ok_rel and ok_iow and ok_dry and live_rel and live_iow and live_dry):
        return dict(skipped=True, reason='source identity fail-closed (archive or live dep hash mismatch)',
                    file_identity=identity, passed=None)
    if check_only:
        return dict(passed=True, file_identity=identity, check_only=True)
    relay_scratch = f"/tmp/artifact-replay-up14-relay-{uuid.uuid4().hex[:8]}"
    iow_scratch = f"/tmp/artifact-replay-up14-iow-{uuid.uuid4().hex[:8]}"
    dry_scratch = f"/tmp/artifact-replay-up14-dry-{uuid.uuid4().hex[:8]}"
    src_scratch = f"/tmp/artifact-replay-up14-{uuid.uuid4().hex[:8]}"
    aud_scratch = src_scratch  # audits Require Import Embed*; same -Q
    q_src = lambda f: ['-Q', relay_scratch, '', '-Q', iow_scratch, '',
                       '-Q', dry_scratch, '', '-Q', src_scratch, '']
    steps = [
        dict(group='relay-dep', source='host', repo_dir=relay_arch,
             scratch_dir=relay_scratch, files=entry['relay_dep_files'],
             q_args_fn=lambda f: [], seconds=entry.get('seconds_per_file', 180)),
        dict(group='iow-dep', source='host', repo_dir=iow_arch,
             scratch_dir=iow_scratch, files=entry['iow_dep_files'],
             q_args_fn=lambda f: ['-Q', relay_scratch, ''],
             seconds=entry.get('seconds_per_file', 180)),
        dict(group='dry-lemma', source='host', repo_dir=dry_arch,
             scratch_dir=dry_scratch, files=entry['dry_lemma_files'],
             q_args_fn=lambda f: [], seconds=entry.get('seconds_per_file', 180)),
        dict(group='utility-pre', source='host', repo_dir=src_dir,
             scratch_dir=src_scratch, files=entry['utility_pre_files'],
             q_args_fn=q_src, seconds=entry.get('seconds_per_file', 280)),
        dict(group='utility-pre-audit', source='host', repo_dir=aud_dir,
             scratch_dir=aud_scratch, files=entry['audit_files'],
             q_args_fn=q_src, seconds=entry.get('seconds_per_file', 280)),
    ]
    r = run_named_chain(entry, receipts, steps, check_only=False)
    r['file_identity'] = identity
    r['staged_from'] = str(arch)
    r['scope'] = entry.get('scope')
    r['not_claimed'] = ['relay_juicy_post_transport', 'whole_linked_program', 'funspec_sub',
                        'iow_juicy_post_reconstruction']
    r['missing_immutable_audits'] = entry.get('missing_immutable_audits')
    return r




STATEFUL55_MODULES = ('MemoryTransfer', 'BufferRelay', 'ShellObservation', 'LeanFinal', 'ScheduleConsumption', 'StatefulFinal', 'LeanFinalAudit', 'StatefulFinalAudit')
STATEFUL55_THEOREMS = ('StatefulFinal.advanceUnread_reads_structural', 'StatefulFinal.advanceUnread_writes_structural', 'StatefulFinal.redirect_then_direct_uses_residual', 'StatefulFinal.redirect_then_mark_success', 'StatefulFinal.empty_path_andThen_preserves', 'StatefulFinal.consumed_two_directs', 'StatefulFinal.reset_two_directs', 'StatefulFinal.reset_and_consumed_differ', 'StatefulFinal.general_redirect_then_direct', 'StatefulFinal.stepPrim_empty_path', 'StatefulFinal.read_error_then_recovers', 'StatefulFinal.reset_repeats_error', 'ScheduleConsumption.executeI_proj', 'ScheduleConsumption.executeI_reads_drop', 'ScheduleConsumption.executeI_writes_drop', 'ScheduleConsumption.runDetailed_reads_drop', 'ScheduleConsumption.runDetailed_writes_drop', 'StatefulFinal.abc_readCalls')


def replay_lean_stateful55(entry, receipts):
    """Eight pinned local modules, fresh direct Lean outputs, strictly sequential."""
    result = dict(passed=False, per_file=[], axiom_results={})
    expected_files = {m + '.lean' for m in STATEFUL55_MODULES} | {'lean-toolchain', 'lakefile.toml'}
    try:
        hashes = entry['source_files']
        if (not isinstance(hashes, dict) or set(hashes) != expected_files
                or any(not isinstance(h, str) or not re.fullmatch(r'[0-9a-f]{64}', h)
                       for h in hashes.values())
                or entry.get('modules') != list(STATEFUL55_MODULES)
                or entry.get('theorems') != list(STATEFUL55_THEOREMS)
                or entry.get('archive_dir') != 'phase5/artifact/archive/stateful55'):
            raise ValueError('malformed stateful55 snapshot specification')
        arch = LIBC / entry['archive_dir']
        ok, identity = hash_verify_host(arch, hashes)
        result['file_identity'] = identity
        if not ok:
            raise ValueError('stateful55 archive identity mismatch or missing file')
        if (arch / 'lean-toolchain').read_text() != LEAN_TOOLCHAIN:
            raise ValueError('unexpected pinned Lean toolchain')
        audit_names = re.findall(r'^#print axioms (\S+)',
                                (arch / 'StatefulFinalAudit.lean').read_text(), re.M)
        if audit_names != list(STATEFUL55_THEOREMS):
            raise ValueError('archive audit does not name the exact 18 declarations')
        # Never invoke elan or Lake: a missing installed toolchain fails without downloads.
        toolchain = LEAN_TOOLCHAIN.strip().replace('/', '--').replace(':', '---')
        lean = Path(os.environ.get('ELAN_HOME', str(Path.home() / '.elan'))) / 'toolchains' / toolchain / 'bin/lean'
        if not lean.is_file() or not os.access(lean, os.X_OK):
            raise ValueError('pinned Lean binary is not installed: ' + str(lean))
        scratch = fresh_scratch('stateful55')
        for filename in hashes:
            shutil.copy2(arch / filename, scratch / filename)
        staged_ok, staged_identity = hash_verify_host(scratch, hashes)
        result.update(scratch=str(scratch), staged_identity=staged_identity,
                      compiler=str(lean), compiler_sha256=sha(lean))
        if not staged_ok:
            raise ValueError('staged stateful55 snapshot identity mismatch')
    except (KeyError, TypeError, ValueError, OSError) as exc:
        result['reason'] = str(exc)
        return result
    env = {'LEAN_PATH': str(scratch)}
    for module in STATEFUL55_MODULES:
        output = scratch / (module + '.olean')
        log = receipts / (entry['id'] + '.' + module + '.log')
        argv = [str(lean), '-j1', '-s16384', '-DwarningAsError=true', '-DElab.async=false',
                '-o', str(output), module + '.lean']
        try:
            code, elapsed = run_real(argv, scratch, entry.get('seconds_per_file', 180),
                                     log, extra_env=env)
        except OSError as exc:
            log.write_text('Compiler launch failed: ' + str(exc) + '\n')
            code, elapsed = None, 0
        receipt = dict(file=module + '.lean', command=argv, workdir=str(scratch),
                       environment={**env, 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'},
                       address_space_bytes=HOST_LEAN_ADDRESS_SPACE, exit_status=code,
                       elapsed_seconds=elapsed, log=str(log), log_sha256=sha(log),
                       output=str(output), output_sha256=sha(output) if output.is_file() else None,
                       source_sha256=sha(scratch / (module + '.lean')))
        receipt_path = receipts / (entry['id'] + '.' + module + '.json')
        receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
        result['per_file'].append({**receipt, 'receipt': str(receipt_path)})
        if code != 0 or not output.is_file() or output.stat().st_size == 0:
            result['reason'] = 'compiler failure or missing output: ' + module
            return result
    text = Path(result['per_file'][-1]['log']).read_text()
    matches = re.findall(r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)", text)
    names = [name for name, _ in matches]
    for name, raw in matches:
        axioms = sorted(a.strip() for a in raw.split(',') if a.strip())
        result['axiom_results'][name] = dict(axioms=axioms, allowed=set(axioms) <= ALLOWED_AXIOMS)
    result['passed'] = (len(names) == 18 and set(names) == set(STATEFUL55_THEOREMS)
                        and all(a['allowed'] for a in result['axiom_results'].values()))
    if not result['passed']:
        result['reason'] = 'missing/duplicate/unexpected audit declaration or forbidden axiom'
    result['exit_status'] = result['per_file'][-1]['exit_status']
    return result



TYPED77_MODULES = (
    'MemoryTransfer', 'BufferRelay', 'CalculusNested', 'CalculusExport', 'CalculusBody',
    'CalculusSimulation', 'CalculusRelayLoop', 'CalculusRelayOuter', 'CompareMain',
    'CalculusRelaySpec', 'ScheduleConsumption', 'CalculusRelaySchedules', 'CalculusRelayShared',
    'CalculusTyping', 'CalculusLowering', 'CalculusTypeCheck', 'CalculusTypingAxioms',
    'SpecAstExport', 'SpecAstExportAxioms', 'CalculusRelaySchedulesAxioms',
)
TYPED77_AUDIT = {
    'CalculusRelaySchedulesAxioms': [
        'CalculusRelaySchedules.relay_outer_schedules_step',
        'CalculusRelaySchedules.relay_outer_schedules',
        'CalculusRelaySchedules.relay_matches_phase3_schedules',
        'CalculusRelaySchedules.OuterExactSchedules.residuals_drop',
    ],
    'CalculusRelayShared': [
        'related_prologue',
        'relay_body_shared',
        'relay_action_shared',
        'relay_entry_shared',
    ],
    'CalculusTypingAxioms': [
        'CalculusTyping.Sub_sound',
        'CalculusTyping.funcDef_sound',
        'CalculusTyping.ETy_sound',
        'CalculusTyping.STy_extends',
        'CalculusTyping.preservation',
        'CalculusLowering.lowering_checked',
        'CalculusTypeCheck.subB_sound',
        'CalculusTypeCheck.inferE_sound',
        'CalculusTypeCheck.checkS_sound',
        'CalculusTypeCheck.writeBlock_typed',
        'CalculusTypeCheck.relayCaught_typed',
        'CalculusTypeCheck.relayActs_typed',
        'CalculusTypeCheck.writeBlock_preserves',
    ],
    'SpecAstExportAxioms': [
        'CalculusLowering.exportedSpec_eq_hand',
        'CalculusLowering.exported_lowers',
        'CalculusLowering.lowering_checked',
    ],
}
TYPED77_THEOREMS = (
    tuple(TYPED77_AUDIT['CalculusRelaySchedulesAxioms'])
    + tuple(TYPED77_AUDIT['CalculusRelayShared'])
    + tuple(TYPED77_AUDIT['CalculusTypingAxioms'])
    + tuple(TYPED77_AUDIT['SpecAstExportAxioms'])
)
AXIOM_PRINT_RE = re.compile(
    r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)")


def _pinned_lean_binary():
    toolchain = LEAN_TOOLCHAIN.strip().replace('/', '--').replace(':', '---')
    lean = Path(os.environ.get('ELAN_HOME', str(Path.home() / '.elan'))) / 'toolchains' / toolchain / 'bin/lean'
    if not lean.is_file() or not os.access(lean, os.X_OK):
        raise ValueError('pinned Lean binary is not installed: ' + str(lean))
    return lean


def _parse_axiom_prints(text):
    matches = AXIOM_PRINT_RE.findall(text)
    names = [name for name, _ in matches]
    results = {}
    for name, raw in matches:
        axioms = sorted(a.strip() for a in raw.split(',') if a.strip())
        results[name] = dict(axioms=axioms, allowed=set(axioms) <= ALLOWED_AXIOMS)
    return names, results


def replay_lean_typed_shared77(entry, receipts):
    """Nineteen-module accepted closure plus schedules axiom wrapper; sequential direct Lean."""
    result = dict(passed=False, per_file=[], axiom_results={}, axiom_results_by_file={})
    expected_files = {m + '.lean' for m in TYPED77_MODULES} | {'lean-toolchain', 'lakefile.toml'}
    export_files = {'export/byte_relay_exec.ast.sexp', 'export/sexp_to_lean.py'}
    try:
        hashes = entry['source_files']
        export_hashes = entry['export_files']
        if (not isinstance(hashes, dict) or set(hashes) != expected_files
                or set(export_hashes) != export_files
                or any(not isinstance(h, str) or not re.fullmatch(r'[0-9a-f]{64}', h)
                       for h in list(hashes.values()) + list(export_hashes.values()))
                or entry.get('modules') != list(TYPED77_MODULES)
                or entry.get('theorems') != list(TYPED77_THEOREMS)
                or entry.get('archive_dir') != 'phase5/artifact/archive/calculus-typed-shared77'):
            raise ValueError('malformed typed-shared77 snapshot specification')
        arch = LIBC / entry['archive_dir']
        ok, identity = hash_verify_host(arch, hashes)
        ok_ex, identity_ex = hash_verify_host(arch, export_hashes)
        result['file_identity'] = identity
        result['export_identity'] = identity_ex
        if not ok or not ok_ex:
            raise ValueError('typed-shared77 archive identity mismatch or missing file')
        if (arch / 'lean-toolchain').read_text() != LEAN_TOOLCHAIN:
            raise ValueError('unexpected pinned Lean toolchain')
        for module, expected in TYPED77_AUDIT.items():
            names = re.findall(r'^#print axioms (\S+)', (arch / (module + '.lean')).read_text(), re.M)
            if names != expected:
                raise ValueError('archive audit mismatch: ' + module)
        lean = _pinned_lean_binary()
        generator = arch / 'export/sexp_to_lean.py'
        raw = arch / 'export/byte_relay_exec.ast.sexp'
        regenerated = arch / 'export' / 'SpecAstExport.regenerated.lean'
        # Deterministic Python generator only; not an OCaml parser/printer rebuild.
        scratch = fresh_scratch('typed77')
        regen_out = scratch / 'SpecAstExport.regenerated.lean'
        code, elapsed = run_real(['python3', str(generator), str(raw), str(regen_out)],
                                 scratch, 30, receipts / (entry['id'] + '.export-regen.log'),
                                 max_wait=entry.get('lock_wait_seconds', 5))
        if code != 0 or not regen_out.is_file():
            raise ValueError('export generator regeneration failed')
        if sha(regen_out) != hashes['SpecAstExport.lean']:
            raise ValueError('regenerated SpecAstExport does not match archived source')
        result['export_regeneration'] = dict(
            exit_status=code, elapsed_seconds=elapsed, sha256=sha(regen_out),
            claimed_ocaml_parser_rebuild=False)
        for filename in hashes:
            shutil.copy2(arch / filename, scratch / filename)
        staged_ok, staged_identity = hash_verify_host(scratch, hashes)
        result.update(scratch=str(scratch), staged_identity=staged_identity,
                      compiler=str(lean), compiler_sha256=sha(lean))
        if not staged_ok:
            raise ValueError('staged typed-shared77 snapshot identity mismatch')
    except (KeyError, TypeError, ValueError, OSError) as exc:
        result['reason'] = str(exc)
        return result
    env = {'LEAN_PATH': str(scratch)}
    lock_wait = entry.get('lock_wait_seconds', 5)
    seconds = entry.get('seconds_per_file', 60)
    for module in TYPED77_MODULES:
        output = scratch / (module + '.olean')
        log = receipts / (entry['id'] + '.' + module + '.log')
        argv = [str(lean), '-j1', '-s16384', '-DwarningAsError=true', '-DElab.async=false',
                '-o', str(output), module + '.lean']
        try:
            code, elapsed = run_real(argv, scratch, seconds, log, max_wait=lock_wait, extra_env=env)
        except OSError as exc:
            log.write_text('Compiler launch failed: ' + str(exc) + '\n')
            code, elapsed = None, 0
        if code is None and log.exists() and 'lock wait expired' in log.read_text():
            result['reason'] = 'compiler lock busy'
            result['skipped'] = True
            receipt = dict(file=module + '.lean', command=argv, workdir=str(scratch),
                           environment={**env, 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'},
                           address_space_bytes=HOST_LEAN_ADDRESS_SPACE, exit_status=code,
                           elapsed_seconds=elapsed, log=str(log), log_sha256=sha(log),
                           output=str(output), output_sha256=None, source_sha256=sha(scratch / (module + '.lean')))
            result['per_file'].append(receipt)
            return result
        receipt = dict(file=module + '.lean', command=argv, workdir=str(scratch),
                       environment={**env, 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'},
                       address_space_bytes=HOST_LEAN_ADDRESS_SPACE, exit_status=code,
                       elapsed_seconds=elapsed, log=str(log), log_sha256=sha(log),
                       output=str(output), output_sha256=sha(output) if output.is_file() else None,
                       source_sha256=sha(scratch / (module + '.lean')))
        receipt_path = receipts / (entry['id'] + '.' + module + '.json')
        receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
        result['per_file'].append({**receipt, 'receipt': str(receipt_path)})
        if code != 0 or not output.is_file() or output.stat().st_size == 0:
            result['reason'] = 'compiler failure or missing output: ' + module
            return result
        if module in TYPED77_AUDIT:
            names, parsed = _parse_axiom_prints(log.read_text())
            expected = TYPED77_AUDIT[module]
            qualified = [n if n.startswith(module + '.') or '.' in n else module + '.' + n for n in expected]
            result['axiom_results_by_file'][module] = dict(names=names, expected=expected, qualified=qualified, parsed=parsed)
            for name, info in parsed.items():
                key = module + ':' + name
                result['axiom_results'][key] = info
            ok_names = names == expected or names == qualified
            if not ok_names or any(not parsed[n]['allowed'] for n in names):
                result['reason'] = 'missing/duplicate/unexpected audit declaration or forbidden axiom: ' + module
                return result
    expected_count = sum(len(v) for v in TYPED77_AUDIT.values())
    result['passed'] = (len(result['axiom_results']) == expected_count
                        and set(result['axiom_results_by_file']) == set(TYPED77_AUDIT)
                        and all(a['allowed'] for a in result['axiom_results'].values()))
    if not result['passed']:
        result['reason'] = 'audit key order/count mismatch'
    result['exit_status'] = result['per_file'][-1]['exit_status']
    result['scope'] = entry.get('scope')
    result['not_claimed'] = entry.get('not_claimed')
    return result


QUERY95_MODULES = (
    'MemoryTransfer', 'BufferRelay', 'CalculusNested', 'CalculusExport', 'CalculusBody',
    'CalculusSimulation', 'CalculusRelayLoop', 'CalculusRelayOuter', 'CompareMain',
    'CalculusRelaySpec', 'ScheduleConsumption', 'CalculusRelaySchedules', 'CalculusRelayShared',
    'ShellObservation', 'CalculusLowering', 'CalculusCommands', 'CalculusQuery',
    'CalculusQueryExportLink', 'CalculusGuards', 'CalculusGuardsAxioms', 'CalculusGuardsRead',
    'CalculusGuardsRelay', 'CalculusGuardsRelayAxioms', 'CalculusTryCatch', 'CalculusTryCatchAxioms',
)
QUERY95_AUDIT = {
    'CalculusCommands': [
        'mark_body', 'mark_action', 'runCmd_iff_exec', 'Budget.relay_step', 'encode_run',
        'encode_sound', 'encoded_query_sound', 'relayAndMark_query', 'relayOrMark_read_error',
        'relayOrMark_read_error_nested', 'relayAndMark_nested',
    ],
    'CalculusQuery': [
        'compile_eval', 'prologue_run', 'program_run', 'script_query_run', 'script_query_universal',
        'relayAndMark_markedOrFailed', 'relay_alone_not_marked', 'relayOrMark_statusZero',
        'relayAndMark_markedOrFailed_nested', 'relayOrMark_statusZero_nested', 'export_mark_body',
        'markSpec_of_commands', 'markSpec_of_export', 'encode_run_spec', 'script_query_universal_spec',
        'relayAndMark_markedOrFailed_export', 'relayOrMark_statusZero_export',
    ],
    'CalculusQueryExportLink': [
        'mark_body_identity',
    ],
    'CalculusGuardsAxioms': [
        'CalculusGuards.range_guard_int', 'CalculusGuards.range_guard_some',
        'CalculusGuards.range_guard_fail', 'CalculusGuards.rangeList_guard_some',
        'CalculusGuards.assign_range_cases', 'CalculusGuards.assert_guard',
        'CalculusGuards.assert_guard_continue', 'CalculusGuards.assert_le_continue',
        'CalculusGuards.writeBlockBody_eq_prefix', 'CalculusGuards.write_block_guard_gate',
        'CalculusGuards.write_block_guarded',
    ],
    'CalculusGuardsRelayAxioms': [
        'CalculusGuardsRelay.InnerInvW.ofInv', 'CalculusGuardsRelay.InnerInv.ofW',
        'CalculusGuardsRelay.relay_inner_call_failure', 'CalculusGuardsRelay.relay_inner_call_raise',
        'CalculusGuardsRelay.relay_inner_step_guarded',
        'CalculusGuardsRelay.relay_inner_loop_run_guarded',
        'CalculusGuardsRead.rbK_nonneg_iff', 'CalculusGuardsRead.rbK_le_rangeMax',
        'CalculusGuardsRead.read_block_guard_fail', 'CalculusGuardsRead.read_block_guard_gate',
        'CalculusRelayLoop.relay_inner_step_inv', 'CalculusRelayLoop.relay_inner_loop_run',
        'CalculusRelayOuter.read_block_body_ret', 'CalculusGuards.write_block_guard_gate',
    ],
    'CalculusTryCatchAxioms': [
        'CalculusTryCatch.funcDef_excTag', 'CalculusTryCatch.relay_caught_of_ret',
        'CalculusTryCatch.relay_caught_of_readError', 'CalculusTryCatch.relay_caught_of_other',
        'CalculusTryCatch.relay_caught_of_failure',
    ],
}
QUERY95_THEOREMS = (
    tuple(QUERY95_AUDIT['CalculusCommands'])
    + tuple(QUERY95_AUDIT['CalculusQuery'])
    + tuple(QUERY95_AUDIT['CalculusQueryExportLink'])
    + tuple(QUERY95_AUDIT['CalculusGuardsAxioms'])
    + tuple(QUERY95_AUDIT['CalculusGuardsRelayAxioms'])
    + tuple(QUERY95_AUDIT['CalculusTryCatchAxioms'])
)


def replay_lean_query_guards95(entry, receipts):
    """Commands87 + Guards82/89 + Query92 closure; sequential direct Lean."""
    result = dict(passed=False, per_file=[], axiom_results={}, axiom_results_by_file={})
    expected_files = {m + '.lean' for m in QUERY95_MODULES} | {'lean-toolchain', 'lakefile.toml'}
    try:
        hashes = entry['source_files']
        if (not isinstance(hashes, dict) or set(hashes) != expected_files
                or any(not isinstance(h, str) or not re.fullmatch(r'[0-9a-f]{64}', h)
                       for h in hashes.values())
                or entry.get('modules') != list(QUERY95_MODULES)
                or entry.get('theorems') != list(QUERY95_THEOREMS)
                or entry.get('archive_dir') != 'phase5/artifact/archive/calculus-query-guards95'):
            raise ValueError('malformed query-guards95 snapshot specification')
        arch = LIBC / entry['archive_dir']
        ok, identity = hash_verify_host(arch, hashes)
        result['file_identity'] = identity
        if not ok:
            raise ValueError('query-guards95 archive identity mismatch or missing file')
        if (arch / 'lean-toolchain').read_text() != LEAN_TOOLCHAIN:
            raise ValueError('unexpected pinned Lean toolchain')
        for module, expected in QUERY95_AUDIT.items():
            names = re.findall(r'^#print axioms (\S+)', (arch / (module + '.lean')).read_text(), re.M)
            if names != expected:
                raise ValueError('archive audit mismatch: ' + module)
        stale = (arch / 'CalculusQuery.lean').read_bytes()
        if b'5a994b4b' not in stale:
            raise ValueError('CalculusQuery stale hash comment 5a994b4b missing')
        if hashes.get('CalculusLowering.lean') != '45a2bae49592eef5eb0979c5de633b284a0ee07a31e0930dc10539c9af3197c3':
            raise ValueError('CalculusLowering identity is not actual 45a2bae4')
        if hashes.get('CalculusQuery.lean') != '0162c7938bac5e1cd73c56dc1f12c6f813978c7ea6234f5f9dcce2b9e0906c59':
            raise ValueError('CalculusQuery identity mismatch')
        if hashes.get('CalculusCommands.lean') != '16efc2851af54840989030f876a062a26216b51fb85464e8a21a5fa83721f681':
            raise ValueError('CalculusCommands identity mismatch')
        if hashes.get('CalculusQueryExportLink.lean') != '1f3265be91db5c9a692435cf1345b9eecf1919164deba235fa83805a20dbd7b1':
            raise ValueError('CalculusQueryExportLink identity mismatch')
        lean = _pinned_lean_binary()
        scratch = fresh_scratch('query95')
        for filename in hashes:
            shutil.copy2(arch / filename, scratch / filename)
        staged_ok, staged_identity = hash_verify_host(scratch, hashes)
        result.update(scratch=str(scratch), staged_identity=staged_identity,
                      compiler=str(lean), compiler_sha256=sha(lean))
        if not staged_ok:
            raise ValueError('staged query-guards95 snapshot identity mismatch')
    except (KeyError, TypeError, ValueError, OSError) as exc:
        result['reason'] = str(exc)
        return result
    env = {'LEAN_PATH': str(scratch)}
    lock_wait = entry.get('lock_wait_seconds', 5)
    seconds = entry.get('seconds_per_file', 60)
    for module in QUERY95_MODULES:
        output = scratch / (module + '.olean')
        log = receipts / (entry['id'] + '.' + module + '.log')
        argv = [str(lean), '-j1', '-s16384', '-DwarningAsError=true', '-DElab.async=false',
                '-o', str(output), module + '.lean']
        try:
            code, elapsed = run_real(argv, scratch, seconds, log, max_wait=lock_wait, extra_env=env)
        except OSError as exc:
            log.write_text('Compiler launch failed: ' + str(exc) + '\n')
            code, elapsed = None, 0
        if code is None and log.exists() and 'lock wait expired' in log.read_text():
            result['reason'] = 'compiler lock busy'
            result['skipped'] = True
            receipt = dict(file=module + '.lean', command=argv, workdir=str(scratch),
                           environment={**env, 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'},
                           address_space_bytes=HOST_LEAN_ADDRESS_SPACE, exit_status=code,
                           elapsed_seconds=elapsed, log=str(log), log_sha256=sha(log),
                           output=str(output), output_sha256=None,
                           source_sha256=sha(scratch / (module + '.lean')))
            result['per_file'].append(receipt)
            return result
        receipt = dict(file=module + '.lean', command=argv, workdir=str(scratch),
                       environment={**env, 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'},
                       address_space_bytes=HOST_LEAN_ADDRESS_SPACE, exit_status=code,
                       elapsed_seconds=elapsed, log=str(log), log_sha256=sha(log),
                       output=str(output), output_sha256=sha(output) if output.is_file() else None,
                       source_sha256=sha(scratch / (module + '.lean')))
        receipt_path = receipts / (entry['id'] + '.' + module + '.json')
        receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
        result['per_file'].append({**receipt, 'receipt': str(receipt_path)})
        if code != 0 or not output.is_file() or output.stat().st_size == 0:
            result['reason'] = 'compiler failure or missing output: ' + module
            return result
        if module in QUERY95_AUDIT:
            names, parsed = _parse_axiom_prints(log.read_text())
            expected = QUERY95_AUDIT[module]
            qualified = [n if n.startswith(module + '.') else module + '.' + n for n in expected]
            result['axiom_results_by_file'][module] = dict(names=names, expected=expected,
                                                           qualified=qualified, parsed=parsed)
            for name, info in parsed.items():
                key = module + ':' + name
                result['axiom_results'][key] = info
            ok_names = names == expected or names == qualified
            if not ok_names or any(not parsed[n]['allowed'] for n in names):
                result['reason'] = 'missing/duplicate/unexpected audit declaration or forbidden axiom: ' + module
                return result
    expected_count = sum(len(v) for v in QUERY95_AUDIT.values())
    result['passed'] = (len(result['axiom_results']) == expected_count
                        and set(result['axiom_results_by_file']) == set(QUERY95_AUDIT)
                        and all(a['allowed'] for a in result['axiom_results'].values()))
    if not result['passed']:
        result['reason'] = 'audit key order/count mismatch'
    result['exit_status'] = result['per_file'][-1]['exit_status']
    result['scope'] = entry.get('scope')
    result['not_claimed'] = entry.get('not_claimed')
    result['query_ast_vs_predicate'] = (
        'Accepted Query92 is a bounded query AST compiled to Nested; '
        'Commands87 encoded_query_sound is generic predicate transfer, not that AST.')
    return result



TOKENIZE134_MODULES = (
    'CalculusNested', 'CalculusExport', 'CalculusBody', 'CalculusSimulation',
    'CalculusRelayLoop', 'CalculusRelayOuter', 'CalculusTokenize', 'CalculusTokenizeFull',
    'CalculusTextLiteralAxioms', 'CalculusTokenizeChars', 'CalculusTokenizeCharsJoin',
    'CalculusTokenizeCharsSuf', 'CalculusTokenizeCharsIdent', 'CalculusTokenizeCharsAst',
    'CalculusTokenizeReadChars', 'CalculusTokenizeReadCharsJoin', 'CalculusTokenizeReadCharsSuf',
    'CalculusTokenizeReadCharsIdent', 'CalculusTokenizeReadCharsAst',
    'CalculusTokenizeRelayChars', 'CalculusTokenizeRelayCharsJoin', 'CalculusTokenizeRelayCharsSuf',
    'CalculusTokenizeRelayCharsIdent', 'CalculusTokenizeRelayCharsAst',
    'CalculusTokenizeChunks', 'CalculusTokenizeSixAudit', 'CalculusTokenizeTotal',
    'CalculusTokenizeCopyEq', 'CalculusTokenizeCopyAudit', 'CompareTotalMain', 'ExportTotalMain',
)
TOKENIZE134_EXTRA_FILES = ('CompareMain.lean', 'saved-pair-manifest.json', 'negative_checks.py')
TOKENIZE134_AUDIT = {
    'CalculusTextLiteralAxioms': [
        'CalculusTokenizeFull.writeBlockText_ofList',
        'CalculusTokenizeFull.writeBlockText_toList',
        'CalculusTokenizeFull.writeBlockText_length',
        'CalculusTokenizeFull.relayText_ofList',
        'CalculusTokenizeFull.relayText_toList',
        'CalculusTokenizeFull.relayText_length',
        'CalculusTokenizeFull.readBlockText_ofList',
        'CalculusTokenizeFull.readBlockText_toList',
        'CalculusTokenizeFull.readBlockText_length',
    ],
    'CalculusTokenizeCharsAst': [
        'CalculusTokenizeCharsIdent.writeBlock_text_tokens',
        'writeBlock_text_ast',
    ],
    'CalculusTokenizeRelayCharsAst': [
        'CalculusTokenizeRelayCharsIdent.relay_text_tokens',
        'relay_text_ast',
    ],
    'CalculusTokenizeReadCharsAst': [
        'CalculusTokenizeReadCharsIdent.readBlock_text_tokens',
        'readBlock_text_ast',
    ],
    'CalculusTokenizeSixAudit': [
        'CalculusTokenizeCharsIdent.writeBlock_text_tokens',
        'CalculusTokenizeCharsAst.writeBlock_text_ast',
        'CalculusTokenizeRelayCharsIdent.relay_text_tokens',
        'CalculusTokenizeRelayCharsAst.relay_text_ast',
        'CalculusTokenizeReadCharsIdent.readBlock_text_tokens',
        'CalculusTokenizeReadCharsAst.readBlock_text_ast',
    ],
    'CalculusTokenizeCopyAudit': [
        'CalculusTokenizeCopyEq.tokenizeTotal_eq',
        'CalculusTokenizeCopyEq.parseText_eq',
    ],
}
TOKENIZE134_THEOREMS = tuple(n for m in (
    'CalculusTextLiteralAxioms', 'CalculusTokenizeCharsAst', 'CalculusTokenizeRelayCharsAst',
    'CalculusTokenizeReadCharsAst', 'CalculusTokenizeSixAudit', 'CalculusTokenizeCopyAudit',
) for n in TOKENIZE134_AUDIT[m])
TOKENIZE134_GENERIC = '5193c04525e369777dc5fbab5ae7234e199680e958e7896974ce4f6951b4f8d3'
TOKENIZE134_COMPAREMAIN = '6b9177464411f05dc42bff1bab5151d4ca22103d27450990b0492b85605f8d00'
TOKENIZE134_CHUNKS = 'ef2baca1b689da91aac6406fca61f0465e062739248cb185994dfa06dff5526b'
TOKENIZE134_COMPARE_BIN = 'ac158a53969e4524afbcd0250298ba4eecaf350d51f6434eb8bbd22f768d2386'
TOKENIZE134_EXPORT_BIN = 'b64bd0efa2e04d5e2b6ffb9aaab3a83cb6677580734136ee91f90e20dfbd136a'
TOKENIZE134_COMPARE_RELAY = 'fa1e771eaab454fdf919ca07809515669c273dbbf5ca1dd35867b4d233861acf'
TOKENIZE134_DATA_DIR = 'data'
TOKENIZE134_DATA_FILES = {
    "calculus-correspondence/compare_relay.py": "fa1e771eaab454fdf919ca07809515669c273dbbf5ca1dd35867b4d233861acf",
    "calculus-correspondence/results/compare_lean_finite_big_attr.jsonl": "73eccb695ec5af7fc65c293d06c38177af92c9b28761e116e143ffc6fb074130",
    "calculus-correspondence/results/compare_ocaml_finite_big_attr.jsonl": "db4624b2457f1b91c93de3eb26bb5e221a1e9afff04a62c8e8727d6f9bb17fbb",
    "calculus-correspondence/results/compare_lean_finite_carrier_max.jsonl": "cbf9a4c44d906b422bfb7eb4b0bfa6df6689af8919d72c837715219534d499c3",
    "calculus-correspondence/results/compare_ocaml_finite_carrier_max.jsonl": "f3dcbbc83c32f6170219338bbae4364fd78568f4fe819c7c9a4d8ebe76a4188d",
    "calculus-correspondence/results/compare_lean_finite_char_lit.jsonl": "81882ee0191e7c983f7a399ea914c8fb312fd869c0d7eff8f3f4cc796b3d746d",
    "calculus-correspondence/results/compare_ocaml_finite_char_lit.jsonl": "fa573f6d996c59873044a0733d34818d92340d21fefae573fefeedd90b34aa3a",
    "calculus-correspondence/results/compare_lean_finite_div_trunc.jsonl": "963e8ceb475d293df6785c254ed6acf99cfc0fd10a7aa67a0273fb5dd2fe40d9",
    "calculus-correspondence/results/compare_ocaml_finite_div_trunc.jsonl": "09bc6a76ace5bf6a1c4d601925e2f1a88e0198f1073793a72ed7faf88f6d8b4e",
    "calculus-correspondence/results/compare_lean_finite_div_zero.jsonl": "488407c76e71b279979902fd9b65be2a267420d7a86c4f28857b1f0a55ff9b24",
    "calculus-correspondence/results/compare_ocaml_finite_div_zero.jsonl": "fec5c772d9865afae03ba85810381c4762c34ef31b4dc4ba468439ec44b7cc66",
    "calculus-correspondence/results/compare_lean_finite_mod_sign.jsonl": "3158d3e9a831d173ac7d6c54d936381b9b4a8f0486069cc3205bb4758bc8c6b8",
    "calculus-correspondence/results/compare_ocaml_finite_mod_sign.jsonl": "c8eef999d4b99d4e73c8cdb99507a446c9fc097a591dc6b3dc8aad305f0c3452",
    "calculus-correspondence/results/compare_lean_finite_overflow_add.jsonl": "989b9850d640b245bf31fcc06242c26d3f383000f7af542d382b69dda9db4295",
    "calculus-correspondence/results/compare_ocaml_finite_overflow_add.jsonl": "13b20a7332ccaa1c527a743e70023a475b9e706b9aa00db077fdc1dce354712e",
    "calculus-correspondence/results/compare_lean_finite_overflow_mul.jsonl": "f7c06472e791df6eb8a8cde903e2a72d5a847b1eb3f4a0e53dbf1b4d80891efc",
    "calculus-correspondence/results/compare_ocaml_finite_overflow_mul.jsonl": "4f21ba2a6aa7f448a2cc1eee33acf5bd5688ca6141e37e9b38109cb84f3ac220",
    "calculus-correspondence/results/compare_lean_finite_overflow_neg.jsonl": "b02e2ac06d33e975004bf6d71bbf83dd40cbc3a3ca555bde9edb1b5b29f8bb49",
    "calculus-correspondence/results/compare_ocaml_finite_overflow_neg.jsonl": "c58ddb5bd36fd7fc14f636c1e23432061e36b7ffaa9ad024cb706d9035ff0122",
    "calculus-correspondence/results/compare_lean_finite_overflow_sub.jsonl": "18402e36f811413347f2f50aa02bbe30b05d5bb5ee7d206791d2f2c8b7439742",
    "calculus-correspondence/results/compare_ocaml_finite_overflow_sub.jsonl": "09ecc5dbcf3be9a980fba42452a7ebb5f103f7dcd1461d7dd6760944b2a795d2",
    "calculus-correspondence/results/compare_lean_finite_ret_u8_ok.jsonl": "e9c2fd13c9e12a2f5d75da863529b622b1b293a92bd08a1f03e6334a5c34c6f6",
    "calculus-correspondence/results/compare_ocaml_finite_ret_u8_ok.jsonl": "9368f133f6278eabb4c8dd760aa07ff89a0530a386686259610a56d61d629a17",
    "calculus-correspondence/results/compare_lean_finite_ret_u8_trap.jsonl": "5b2623ddc77cf3920502289bffc8b099abe74cf04cf883dbfd0b4c48fcb64261",
    "calculus-correspondence/results/compare_ocaml_finite_ret_u8_trap.jsonl": "441b2ddc8f6bb494a95df7e5718dd0552e532415052c60899e400db4e162116e",
    "calculus-correspondence/results/compare_lean_finite_typed_literal_widths.jsonl": "525a95431d6f36bfb8f7b9dcd001f82eabe8b0f11eb5605ef06d107c1ae07e64",
    "calculus-correspondence/results/compare_ocaml_finite_typed_literal_widths.jsonl": "baabcdffa828586ab9d4e372fcc1272d7d5e741f5969f36036439db3908ab51d",
    "calculus-correspondence/results/compare_lean_finite_u64_negative_trap.jsonl": "3c4f0211a7ed934068a70736f7679d244f990eb911104d88ad991502c3f7e2ab",
    "calculus-correspondence/results/compare_ocaml_finite_u64_negative_trap.jsonl": "75aac80463e8e4c85df02601ca643082836d6ce27cd98d42a80eef1b03b98072",
    "calculus-correspondence/results/compare_lean_finite_u8_local_annot.jsonl": "3a25b1ef8c3258d728f0a1a5b1c430d5546a19c210f4bbb322459ab9dfa2c28c",
    "calculus-correspondence/results/compare_ocaml_finite_u8_local_annot.jsonl": "1fe4aa64677a0cf1cd4c5a8f033f29cc68f31c1929798da79d8dd1ddd0e0228e",
    "calculus-correspondence/results/compare_lean_finite_u8_local_annot_trap.jsonl": "9aaf1213267e436093b54dfecebe624dcaadb115e673b3d3d4bf4745a9727ff1",
    "calculus-correspondence/results/compare_ocaml_finite_u8_local_annot_trap.jsonl": "2e9a8aca546656c2de593117bfbd335766c390842c33ef0d9fdb7ca8d964ab3c",
    "calculus-correspondence/results/compare_lean_finite_u8_ok.jsonl": "740c1f162c82a31fb4252bdfbc20b61445efc08ae2cfbd81eda7aa3fa45255f2",
    "calculus-correspondence/results/compare_ocaml_finite_u8_ok.jsonl": "3e0888e212fe973c4954e88c34a0add417fc9bde75770571f7fca0d9363e4b33",
    "calculus-correspondence/results/compare_lean_finite_u8_overflow_runtime.jsonl": "1d6639a29db802a433306989ee7fc39cf8ec9016a7eda79ead7e3b8ee6b0aabd",
    "calculus-correspondence/results/compare_ocaml_finite_u8_overflow_runtime.jsonl": "66c92681a08e8e3c669cc469cd1709b8cdca1476338b7e6843591913050411a6",
    "calculus-correspondence/results/compare_lean_finite_u8_param_ok.jsonl": "433d7e8542edfc634d07aa7015c282303358678000d6f86d889824ae1a2a57e9",
    "calculus-correspondence/results/compare_ocaml_finite_u8_param_ok.jsonl": "00bb0f51da580c2c7a523690c52b39902aefbd4a3c8173455910043951b0568b",
    "calculus-correspondence/results/compare_lean_finite_u8_param_trap.jsonl": "9076fb9534339aa0544add3534c28685e0bf6e408260e5fc013ea560172ee70f",
    "calculus-correspondence/results/compare_ocaml_finite_u8_param_trap.jsonl": "4623f5e42165440a13d3d177511a621a22e564e919d0437e7c6b97b31db9a99e",
    "calculus-correspondence/results/compare_lean_nested_cleared_then_read.jsonl": "31a11406080dd3e3a01a60bdfab3cfed22d625d581c9cbabc880ecf2d4ef8ebf",
    "calculus-correspondence/results/compare_ocaml_nested_cleared_then_read.jsonl": "f728620aa134b52270161fbe91e745e7ad1044d4f796b748d9fb48f9143eb8a4",
    "calculus-correspondence/results/compare_lean_nested_deep3.jsonl": "0838b5e76865acc464204a00039de9fd23aaa6e52f0abee7aaf3793b8cc5fe53",
    "calculus-correspondence/results/compare_ocaml_nested_deep3.jsonl": "7696d983780a32b64613ef9ac8ca6c8d4de47429f51a5264c06d7b8c5c992ed7",
    "calculus-correspondence/results/compare_lean_nested_deep_clear.jsonl": "24d9c788fd447949ae8bccbd4ca7b12d1cac06ec9d9580dead6fa39e25f42f06",
    "calculus-correspondence/results/compare_ocaml_nested_deep_clear.jsonl": "008aeb955cee33c5221adce6e225843897bca40c68422cd9f5fe0a43028c4a26",
    "calculus-correspondence/results/compare_lean_nested_deep_set.jsonl": "417a5b072c5e4d2ded94a83fbc8bc79abf47903e8adac6ff5cf7346315ab4ffd",
    "calculus-correspondence/results/compare_ocaml_nested_deep_set.jsonl": "88c41a87739f6e631e6651c9b900942800e714b5cfc3a235ad815f7f7e46a161",
    "calculus-correspondence/results/compare_lean_nested_deep_touch_keeps.jsonl": "4c99428d78168b6595850a1c9ae279232dc3cd9818713b6bf6ecf60b4ed74970",
    "calculus-correspondence/results/compare_ocaml_nested_deep_touch_keeps.jsonl": "177eb6ec9fe229013fa7dad8bd99f2b86329880594b58b3ce3f0461f671b8198",
    "calculus-correspondence/results/compare_lean_nested_missing_parent.jsonl": "3c8bc7b6142a0a3bb52fc4f3768dba32accefd30ccd32485816557540a16652d",
    "calculus-correspondence/results/compare_ocaml_nested_missing_parent.jsonl": "d0b7be406d1008f5a0d1caeb5d0cdbb0661fc35f799b1c6a325501d5039b0b49",
    "calculus-correspondence/results/compare_lean_nested_wrong_order_probe.jsonl": "2bf33100e8154681e90ae4755be703bb6545b51a406c801634b6b5e2b69734f5",
    "calculus-correspondence/results/compare_ocaml_nested_wrong_order_probe.jsonl": "9130200cff559ea5408aa064ec5670d864ea9ef75b0d3ecd3062b1682c5c4add",
    "calculus-correspondence/results/compare_lean_relay.jsonl": "1cd912a2776d66d883b659acddd9b53e8d8440caf670786a9af7de598c4e279b",
    "calculus-correspondence/results/compare_ocaml_relay.jsonl": "4519b67b453a304ee36caebc3c1accca44924c170944f93d6a1087e99e72d172",
    "calculus-correspondence/results/compare_lean_relay_and_mark.jsonl": "0154d8030eb28e22abb755f453c2353aaca20c2f5bba0f6fe147653150c3d5e9",
    "calculus-correspondence/results/compare_ocaml_relay_and_mark.jsonl": "81e0a229c3d3160a8e79bf475a240b4ca2f9af5ecef490dbcb31a9268e41eae3",
    "calculus-correspondence/results/compare_lean_relay_caught.jsonl": "203153ddde1b88e9640b26baed3a35b92c51ed399c8cf8979a0cb9f35e4ff742",
    "calculus-correspondence/results/compare_ocaml_relay_caught.jsonl": "d132ccf85d9beaf579ca3a1799cd5c915d745f8f9f2a9dd14f857b7b91c990d3",
    "calculus-correspondence/results/compare_lean_relay_or_mark.jsonl": "b7db7dc3a32b60d2432daf2442ed047b4c76d486dabca31aec6478314adaf91e",
    "calculus-correspondence/results/compare_ocaml_relay_or_mark.jsonl": "ce0923e16e194ab97b020d94f7a3a3a6a32756a3ba51c862c45b5a062a733497",
    "calculus-correspondence/results/compare_lean_relay_phase3.jsonl": "dea267a9007038453bf95beecae601553efa1a6924c3c13de9a6700b7baddcbc",
    "calculus-correspondence/results/compare_ocaml_relay_phase3.jsonl": "656d39d7bf4e48dc4354e2ef4f24664c15f04e12cc8caada993b6d81b85ca051",
    "calculus-correspondence/results/compare_lean_relay_seq_relay.jsonl": "87897955202550b68627537f321552cf84dabb48611c4135dcf3dfef715cff7b",
    "calculus-correspondence/results/compare_ocaml_relay_seq_relay.jsonl": "7ea6766f87490fdfde1239afdac7224b7ddfc139050d731013851620a6d8f780",
    "calculus-correspondence/results/export_input__finite_ints.tsv": "79ad4205d07724f314121a9ce0ff46774ddb7ed58a4793cc039f48911e31ad31",
    "calculus-correspondence/results/export_input__nested_state.tsv": "b15fd29d3981bc88d3c04e2eeb0e8a5a84d129a449b448662d3f3aa6e8a0db41",
    "calculus-correspondence/results/export_input__byte_relay_exec.tsv": "5b3af9eae37aebcb02765294bcd7718262085f0665979f5e48c91d121c25a281",
    "calculus-bytes/results/cases_curated.tsv": "4e31cde5b5d5bb3dff5aac1a96ae32bca2417529dbff3534770d9828106c6227",
    "calculus-bytes/results/cases_phase3_standard.tsv": "89ff31f48ab549587d23069c16e6b9dcc6e618b44e3aeda635d35350a3b673b1"
}


def _tokenize134_entry_of(name):
    if name.startswith('finite_'):
        return name[len('finite_'):], 'export_input__finite_ints.tsv', 'cases_curated.tsv'
    if name.startswith('nested_'):
        return name[len('nested_'):], 'export_input__nested_state.tsv', 'cases_curated.tsv'
    if name == 'relay_phase3':
        return 'relay', 'export_input__byte_relay_exec.tsv', 'cases_phase3_standard.tsv'
    return name, 'export_input__byte_relay_exec.tsv', 'cases_curated.tsv'


def _tokenize134_load_compare(helper_path):
    """Load archived compare_relay from a unique module name so live compare_relay is never used."""
    import importlib.util
    helper_path = Path(helper_path).resolve()
    name = 'compare_relay_tokenizer134_' + uuid.uuid4().hex
    spec = importlib.util.spec_from_file_location(name, helper_path)
    if spec is None or spec.loader is None:
        raise ValueError('cannot load archived compare_relay')
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    if 'compare_relay' in sys.modules and sys.modules['compare_relay'] is mod:
        raise ValueError('archived comparator must not bind sys.modules[compare_relay]')
    return mod.compare, name


def _tokenize134_check_data_spec(entry):
    data = entry.get('data_files')
    bins = entry.get('expected_binaries')
    if not isinstance(data, dict) or len(data) != 72:
        raise ValueError('tokenizer134 data_files must pin exactly 72 archived inputs')
    if any(not isinstance(h, str) or not re.fullmatch(r'[0-9a-f]{64}', h) for h in data.values()):
        raise ValueError('malformed tokenizer134 data_files hashes')
    required = {
        'calculus-correspondence/compare_relay.py': TOKENIZE134_COMPARE_RELAY,
        'calculus-correspondence/results/export_input__finite_ints.tsv':
            '79ad4205d07724f314121a9ce0ff46774ddb7ed58a4793cc039f48911e31ad31',
        'calculus-correspondence/results/export_input__nested_state.tsv':
            'b15fd29d3981bc88d3c04e2eeb0e8a5a84d129a449b448662d3f3aa6e8a0db41',
        'calculus-correspondence/results/export_input__byte_relay_exec.tsv':
            '5b3af9eae37aebcb02765294bcd7718262085f0665979f5e48c91d121c25a281',
        'calculus-bytes/results/cases_curated.tsv':
            '4e31cde5b5d5bb3dff5aac1a96ae32bca2417529dbff3534770d9828106c6227',
        'calculus-bytes/results/cases_phase3_standard.tsv':
            '89ff31f48ab549587d23069c16e6b9dcc6e618b44e3aeda635d35350a3b673b1',
    }
    for k, h in required.items():
        if data.get(k) != h:
            raise ValueError('tokenizer134 archived data pin mismatch: ' + k)
    lean_n = sum(1 for k in data if '/compare_lean_' in k and k.endswith('.jsonl'))
    ocaml_n = sum(1 for k in data if '/compare_ocaml_' in k and k.endswith('.jsonl'))
    if lean_n != 33 or ocaml_n != 33:
        raise ValueError('tokenizer134 data_files must pin 33 lean + 33 ocaml jsonl')
    if data != TOKENIZE134_DATA_FILES:
        raise ValueError('tokenizer134 data_files must match frozen 72-file pin set')
    if (not isinstance(bins, dict)
            or bins.get('compare-run') != TOKENIZE134_COMPARE_BIN
            or bins.get('export-run') != TOKENIZE134_EXPORT_BIN):
        raise ValueError('tokenizer134 expected_binaries must pin ac158a53/b64bd0ef')
    return data


def replay_lean_tokenizer134(entry, receipts):
    """Tokenizer117 + CLI133: sequential Lean audits, driver link, explicit 33 pairs, 12 negatives."""
    result = dict(passed=False, per_file=[], axiom_results={}, axiom_results_by_file={})
    expected_files = ({m + '.lean' for m in TOKENIZE134_MODULES}
                      | set(TOKENIZE134_EXTRA_FILES) | {'lean-toolchain', 'lakefile.toml'})
    try:
        hashes = entry['source_files']
        if (not isinstance(hashes, dict) or set(hashes) != expected_files
                or any(not isinstance(h, str) or not re.fullmatch(r'[0-9a-f]{64}', h)
                       for h in hashes.values())
                or entry.get('modules') != list(TOKENIZE134_MODULES)
                or entry.get('theorems') != list(TOKENIZE134_THEOREMS)
                or entry.get('archive_dir') != 'phase5/artifact/archive/calculus-tokenizer134'):
            raise ValueError('malformed tokenizer134 snapshot specification')
        if hashes.get('CalculusTokenize.lean') != TOKENIZE134_GENERIC:
            raise ValueError('generic CalculusTokenize identity is not accepted 5193c045')
        if hashes.get('CompareMain.lean') != TOKENIZE134_COMPAREMAIN:
            raise ValueError('older CompareMain identity changed')
        if hashes.get('CalculusTokenizeChunks.lean') != TOKENIZE134_CHUNKS:
            raise ValueError('corrected Chunks identity is not root133 ef2baca1')
        data_hashes = _tokenize134_check_data_spec(entry)
        arch = LIBC / entry['archive_dir']
        ok, identity = hash_verify_host(arch, hashes)
        result['file_identity'] = identity
        if not ok:
            raise ValueError('tokenizer134 archive identity mismatch or missing file')
        data_root = arch / TOKENIZE134_DATA_DIR
        dok, didentity = hash_verify_host(data_root, data_hashes)
        result['data_identity'] = didentity
        if not dok:
            raise ValueError('tokenizer134 archived data identity mismatch or missing file')
        if (arch / 'lean-toolchain').read_text() != LEAN_TOOLCHAIN:
            raise ValueError('unexpected pinned Lean toolchain')
        for module, expected in TOKENIZE134_AUDIT.items():
            names = re.findall(r'^#print axioms (\S+)', (arch / (module + '.lean')).read_text(), re.M)
            if names != expected:
                raise ValueError('archive audit mismatch: ' + module)
        pair_names = json.loads((arch / 'saved-pair-manifest.json').read_text())
        if not isinstance(pair_names, list) or len(pair_names) != 33 or len(set(pair_names)) != 33:
            raise ValueError('explicit pair manifest must be 33 unique names')
        if any('*' in n or n.endswith('.jsonl') for n in pair_names):
            raise ValueError('wildcard pair selection is rejected')
        lean = _pinned_lean_binary()
        scratch = fresh_scratch('tokenizer134')
        for filename in hashes:
            shutil.copy2(arch / filename, scratch / filename)
        staged_ok, staged_identity = hash_verify_host(scratch, hashes)
        result.update(scratch=str(scratch), staged_identity=staged_identity,
                      compiler=str(lean), compiler_sha256=sha(lean))
        if not staged_ok:
            raise ValueError('staged tokenizer134 snapshot identity mismatch')
        order = lean_compile_order(scratch, [
            'CalculusTokenizeCopyAudit', 'CalculusTokenizeSixAudit', 'CalculusTextLiteralAxioms',
            'CalculusTokenizeChunks', 'CompareTotalMain', 'ExportTotalMain'])
        if order != list(TOKENIZE134_MODULES):
            raise ValueError('compile order mismatch: ' + ','.join(order))
    except (KeyError, TypeError, ValueError, OSError, json.JSONDecodeError) as exc:
        result['reason'] = str(exc)
        return result
    compiled = compile_lean_modules_sequential(
        lean, scratch, list(TOKENIZE134_MODULES), receipts, entry['id'],
        seconds=entry.get('seconds_per_file', 60),
        lock_wait=entry.get('lock_wait_seconds', 5))
    result['per_file'] = compiled.get('per_file', [])
    if compiled.get('skipped'):
        result['skipped'] = True
        result['reason'] = compiled.get('reason')
        return result
    if not compiled.get('ok'):
        result['reason'] = compiled.get('reason')
        return result
    for rec in result['per_file']:
        module = Path(rec['file']).stem
        if module not in TOKENIZE134_AUDIT:
            continue
        log = Path(rec['log'])
        names, parsed = _parse_axiom_prints(log.read_text() if log.is_file() else '')
        expected = TOKENIZE134_AUDIT[module]
        qualified = [n if n.startswith(module + '.') or '.' in n else module + '.' + n for n in expected]
        result['axiom_results_by_file'][module] = dict(
            names=names, expected=expected, qualified=qualified, parsed=parsed)
        for name, info in parsed.items():
            result['axiom_results'][module + ':' + name] = info
        ok_names = names == expected or names == qualified
        if not ok_names or any(not parsed[n]['allowed'] for n in names):
            result['reason'] = 'missing/duplicate/unexpected audit declaration or forbidden axiom: ' + module
            return result
    expected_count = sum(len(v) for v in TOKENIZE134_AUDIT.values())
    if (len(result['axiom_results']) != expected_count
            or set(result['axiom_results_by_file']) != set(TOKENIZE134_AUDIT)
            or not all(a['allowed'] for a in result['axiom_results'].values())):
        result['reason'] = 'audit key order/count mismatch'
        return result
    leanc = _pinned_leanc_binary()
    compare_link = compile_lean_c_sources_and_link(
        lean, leanc, scratch,
        ['CalculusNested', 'CalculusExport', 'CalculusTokenizeTotal', 'CompareTotalMain'],
        'compare-run', receipts, entry['id'] + '.compare',
        seconds=entry.get('seconds_per_file', 60),
        lock_wait=entry.get('lock_wait_seconds', 5))
    result['compare_link'] = {k: compare_link.get(k) for k in ('ok', 'reason', 'executable', 'skipped')}
    result['per_file'].extend(compare_link.get('per_file') or [])
    if compare_link.get('skipped'):
        result['skipped'] = True
        result['reason'] = compare_link.get('reason')
        return result
    if not compare_link.get('ok'):
        result['reason'] = compare_link.get('reason')
        return result
    export_link = compile_lean_c_sources_and_link(
        lean, leanc, scratch,
        ['CalculusNested', 'CalculusExport', 'CalculusTokenizeTotal', 'ExportTotalMain'],
        'export-run', receipts, entry['id'] + '.export',
        seconds=entry.get('seconds_per_file', 60),
        lock_wait=entry.get('lock_wait_seconds', 5))
    result['export_link'] = {k: export_link.get(k) for k in ('ok', 'reason', 'executable', 'skipped')}
    result['per_file'].extend(export_link.get('per_file') or [])
    if export_link.get('skipped'):
        result['skipped'] = True
        result['reason'] = export_link.get('reason')
        return result
    if not export_link.get('ok'):
        result['reason'] = export_link.get('reason')
        return result
    compare_bin = Path(compare_link['executable'])
    export_bin = Path(export_link['executable'])
    result['binaries'] = dict(compare_run=sha(compare_bin), export_run=sha(export_bin))
    if (result['binaries']['compare_run'] != TOKENIZE134_COMPARE_BIN
            or result['binaries']['export_run'] != TOKENIZE134_EXPORT_BIN):
        result['reason'] = 'linked binary hash mismatch vs root130/133 pins ac158a53/b64bd0ef'
        return result
    data_root = LIBC / entry['archive_dir'] / TOKENIZE134_DATA_DIR
    corr = data_root / 'calculus-correspondence'
    cases_dir = data_root / 'calculus-bytes/results'
    res = corr / 'results'
    helper = corr / 'compare_relay.py'
    if sha(helper) != TOKENIZE134_COMPARE_RELAY:
        result['reason'] = 'archived compare_relay.py hash mismatch'
        return result
    compare, helper_mod = _tokenize134_load_compare(helper)
    result['helper_module'] = helper_mod
    result['helper_sha256'] = sha(helper)
    pair_dir = receipts / 'tokenizer134-pairs'
    pair_dir.mkdir()
    pair_recs = []
    matched = 0
    all_ok = True
    for name in pair_names:
        entry_name, export, cases = _tokenize134_entry_of(name)
        export_path = res / export
        cases_path = cases_dir / cases
        saved_lean = res / f'compare_lean_{name}.jsonl'
        saved_ocaml = res / f'compare_ocaml_{name}.jsonl'
        new_lean = pair_dir / f'compare_lean_{name}.jsonl'
        with open(cases_path) as fin, open(new_lean, 'w') as fout:
            proc = subprocess.run(
                [str(compare_bin), entry_name, str(export_path)],
                stdin=fin, stdout=fout, stderr=subprocess.PIPE, text=True, timeout=60)
        identical = sha(new_lean) == sha(saved_lean)
        ok_cmp, rep = compare(name, str(new_lean), str(saved_ocaml), quiet=True)
        rec = dict(name=name, entry=entry_name, compare_run_rc=proc.returncode,
                   identical_saved_lean=identical, strict_ok_vs_saved_ocaml=ok_cmp,
                   matched=rep['matched'], compared=rep['compared'],
                   cases_sha256=sha(cases_path), export_sha256=sha(export_path),
                   reference_lean_sha256=sha(saved_lean),
                   reference_ocaml_sha256=sha(saved_ocaml),
                   helper_sha256=sha(helper), output_sha256=sha(new_lean))
        pair_recs.append(rec)
        matched += rep['matched']
        if not (ok_cmp and identical and proc.returncode == 0):
            all_ok = False
    result['saved_pairs'] = dict(count=len(pair_names), matched=matched, all_ok=all_ok, pairs=pair_recs)
    if not all_ok or matched != 1593 or len(pair_names) != 33:
        result['reason'] = 'saved-pair replay failed (need 33 pairs / 1593 matches, explicit manifest)'
        return result
    neg_out = receipts / 'tokenizer134-negatives'
    neg_script = scratch / 'negative_checks.py'
    proc = subprocess.run(
        ['python3', str(neg_script), str(scratch), str(neg_out)],
        capture_output=True, text=True, timeout=60)
    checks_path = neg_out / 'checks.json'
    if proc.returncode != 0 or not checks_path.is_file():
        result['reason'] = 'negative_checks.py failed'
        result['negative_stdout'] = (proc.stdout or '')[-2000:]
        result['negative_stderr'] = (proc.stderr or '')[-2000:]
        return result
    checks = json.loads(checks_path.read_text())
    passed_n = sum(1 for c in checks if c.get('passed'))
    result['negative_checks'] = dict(count=len(checks), passed=passed_n)
    if len(checks) != 12 or passed_n != 12:
        result['reason'] = 'expected 12 strong negative controls from root129'
        return result
    result['passed'] = True
    result['exit_status'] = 0
    result['scope'] = entry.get('scope')
    result['not_claimed'] = entry.get('not_claimed')
    return result



RAISING153_MODULES = (
    'CalculusNested', 'CalculusExport', 'CalculusBody', 'CalculusSimulation',
    'CalculusRelayLoop', 'CalculusRelayOuter', 'MemoryTransfer', 'BufferRelay',
    'CompareMain', 'CalculusRelaySpec', 'ScheduleConsumption', 'CalculusRelaySchedules',
    'CalculusLowering', 'CalculusTryCatch', 'CalculusRelayRaising',
    'CalculusRelayRaisingAxioms',
)
RAISING153_THEOREMS = (
    'CalculusRelayRaising.relayRaisingBody_eq',
    'CalculusRelayRaising.raising_prologue',
    'CalculusRelayRaising.raising_outerInv_prologue',
    'CalculusRelayRaising.raising_runEntry',
    'CalculusRelayRaising.raising_body_shape',
    'CalculusRelayRaising.raising_caught_shape',
    'CalculusRelayRaising.raising_caught_runEntry',
    'CalculusRelayRaising.raising_caught_readError_one',
    'CalculusRelayRaising.raising_outer_loop_terminates',
    'CalculusRelayRaising.raising_caught_eof_zero',
    'CalculusRelayRaising.raising_relay_zero_read_same_post',
    'CalculusRelayRaising.raising_eof_rbK',
    'CalculusRelayRaising.raising_relay_neg_read_same_post',
    'CalculusRelayRaising.raising_caught_of_neg_read_same_s',
    'CalculusRelayRaising.raising_relay_inner_step_same_post',
    'CalculusRelayRaising.raising_relay_inner_step_inv_same_post_envs',
    'CalculusRelayRaising.raising_relay_inner_loop_run_same_post_envs',
    'CalculusRelayRaising.raising_relay_inner_loop_run_same_post',
    'CalculusRelayRaising.raising_relay_outer_step_same_post_envs',
    'CalculusRelayRaising.raising_relay_outer_loop_run_same_post_envs',
    'CalculusRelayRaising.raising_relay_outer_loop_run_same_post',
    'CalculusRelayRaising.raising_relay_body_same_post',
    'CalculusRelayRaising.raising_relay_runEntry_same_post',
    'CalculusRelayRaising.raising_caught_body_same_post',
    'CalculusRelayRaising.raising_caught_runEntry_same_post',
    'CalculusRelayRaising.runEntry_fuel_mono_le',
    'CalculusRelayRaising.raising_matches_phase3_schedules',
    'CalculusRelayRaising.raising_caught_matches_phase3_schedules',
)
RAISING153_FILES = {
    'BufferRelay.lean': 'b07e64e4499e38f0ab0f0879a1ad54fcf1d4b1cfe5c723cad111d4eef6538877',
    'CalculusBody.lean': '481d8d61041e2893697c03c2cc5db7cc92d1f7c8389041164d4b43ff3c3aa5c6',
    'CalculusExport.lean': 'd11ba63f0bd8f465bf60f489c3b5daab9bf4f46bc4c3f051361e8aae4083a763',
    'CalculusLowering.lean': '45a2bae49592eef5eb0979c5de633b284a0ee07a31e0930dc10539c9af3197c3',
    'CalculusNested.lean': 'e2a7cffb206b3669da4bb56961b22d6d676063feeebade3212be822ee1fd651d',
    'CalculusRelayLoop.lean': 'c5ece9e93b95002116de63b2fd2736971bf08ad0625f6c049fa7abe10c604f09',
    'CalculusRelayOuter.lean': 'c49b20a885f1a5dfa52997e68fbfc885d90b5f3f7d2c7598c1d992d6200bc1eb',
    'CalculusRelayRaising.lean': 'e2c19eaaad6f4260f04d097ccdadad8367017c36de9a11672d0374862d6dda52',
    'CalculusRelayRaisingAxioms.lean': '338c679201e0834024c44cb2fedca0d273e47dd483184107bccf56f12710f8ac',
    'CalculusRelaySchedules.lean': 'af7e21e14e9cbbbb0ccd257f47e8b102614ad9faf778b857fe8b9aa8fe3baac4',
    'CalculusRelaySpec.lean': '860e66d82bc39ec8b1dbbf25f088c228a92c70ddf4780538dec379b07b8d35ca',
    'CalculusSimulation.lean': '37ed70b30c5347ebe33ee5b9cb5cb233b296f83a828ab1b5f7a9eaba1362bc80',
    'CalculusTryCatch.lean': 'a163717c41c9c898a515b8af30972dbb97b975539b86ffd6927873668579bd8a',
    'CompareMain.lean': '6b9177464411f05dc42bff1bab5151d4ca22103d27450990b0492b85605f8d00',
    'MemoryTransfer.lean': '9f80ebc6b33b81960aada7a3967ad0455d9b086d679b55439454302dca6d1d71',
    'ScheduleConsumption.lean': '952e3e7307457b929da8a16ec0b4fdc881b27c5a96bc0fd562b9bf3fd4e96235',
    'lean-toolchain': 'efac0b94923b2d8b6840cd35be9177ad0fc5ab2332f4f4311c98712cee92fdee',
}
_RAISING153_THM_RE = re.compile(r'^theorem (\S+)', re.M)
_RAISING153_SORRY_RE = re.compile(r'\bsorry\b')


def _raising153_theorem_block(src, name):
    m = re.search(r'^theorem ' + re.escape(name) + r'\b', src, re.M)
    if not m:
        raise ValueError('missing theorem ' + name)
    rest = src[m.start():]
    nxt = re.search(r'\n(?:theorem|def|end )', rest[1:])
    return rest if nxt is None else rest[: nxt.start() + 1]


def _raising153_validate_actual_theorems(src):
    names = _RAISING153_THM_RE.findall(src)
    short = [n.split('.')[-1] for n in RAISING153_THEOREMS]
    missing = [n for n in short if n not in names]
    if missing:
        return dict(ok=False, reason='missing theorem defs: ' + ','.join(missing))
    seven = _raising153_theorem_block(src, 'raising_matches_phase3_schedules')
    caught = _raising153_theorem_block(src, 'raising_caught_matches_phase3_schedules')
    same = _raising153_theorem_block(src, 'raising_relay_runEntry_same_post')
    csame = _raising153_theorem_block(src, 'raising_caught_runEntry_same_post')
    need_seven = [
        'initialState', 'BufferRelay.run', 'BufferRelay.runDetailed',
        'ScheduleConsumption.executeI', 'OuterExactSchedules', '.status',
        'readCalls', 'writeCalls', '.output', '.pending', '.remaining',
    ]
    for needle in need_seven:
        if needle not in seven or needle not in caught:
            return dict(ok=False, reason='seven-field statement missing ' + needle)
    if 'ReadError' not in seven:
        return dict(ok=False, reason='raising seven-field missing ReadError mapping')
    if 'st : St' not in same or 'lookup st.attrs' not in same:
        return dict(ok=False, reason='runEntry same-post is not general St')
    if 'st : St' not in csame or 'lookup st.attrs' not in csame:
        return dict(ok=False, reason='caught same-post is not general St')
    if 'Related' in seven or 'Related' in caught:
        return dict(ok=False, reason='unexpected Related in seven-field theorems')
    return dict(ok=True, theorem_count=len(names), audited=len(RAISING153_THEOREMS))


def replay_lean_calculus_raising153(entry, receipts):
    """Isolated raising153 adapter: raw Lean argv through run_real (3GiB cap), lock-only retry."""
    result = dict(passed=False, per_file=[], axiom_results={}, axiom_results_by_file={},
                  lock_only_retries={})
    expected_files = set(RAISING153_FILES)
    try:
        hashes = entry['source_files']
        if (not isinstance(hashes, dict) or hashes != RAISING153_FILES
                or set(hashes) != expected_files
                or entry.get('modules') != list(RAISING153_MODULES)
                or entry.get('theorems') != list(RAISING153_THEOREMS)
                or entry.get('archive_dir') != 'phase5/artifact/archive/calculus-raising153'):
            raise ValueError('malformed raising153 snapshot specification')
        arch = LIBC / entry['archive_dir']
        ok, identity = hash_verify_host(arch, hashes)
        result['file_identity'] = identity
        if not ok:
            raise ValueError('raising153 archive identity mismatch or missing file')
        if (arch / 'lean-toolchain').read_text() != LEAN_TOOLCHAIN:
            raise ValueError('unexpected pinned Lean toolchain')
        prints = re.findall(r'^#print axioms (\S+)',
                            (arch / 'CalculusRelayRaisingAxioms.lean').read_text(), re.M)
        if prints != list(RAISING153_THEOREMS) or len(prints) != 28:
            raise ValueError('archive audit mismatch: CalculusRelayRaisingAxioms')
        thm = _raising153_validate_actual_theorems((arch / 'CalculusRelayRaising.lean').read_text())
        result['theorem_validation'] = thm
        if not thm.get('ok'):
            raise ValueError(thm.get('reason', 'theorem validation failed'))
        for lean_file in sorted(arch.glob('*.lean')):
            body = lean_file.read_text()
            stripped = re.sub(r'/-.*?-/', '', body, flags=re.S)
            stripped = re.sub(r'--.*', '', stripped)
            if _RAISING153_SORRY_RE.search(stripped):
                raise ValueError('sorry present: ' + lean_file.name)
        lean = _pinned_lean_binary()
        scratch = fresh_scratch('raising153')
        for filename in hashes:
            shutil.copy2(arch / filename, scratch / filename)
        staged_ok, staged_identity = hash_verify_host(scratch, hashes)
        result.update(scratch=str(scratch), staged_identity=staged_identity,
                      compiler=str(lean), compiler_sha256=sha(lean))
        if not staged_ok:
            raise ValueError('staged raising153 snapshot identity mismatch')
    except (KeyError, TypeError, ValueError, OSError) as exc:
        result['reason'] = str(exc)
        return result
    env = {'LEAN_PATH': str(scratch), 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'}
    lock_wait = entry.get('lock_wait_seconds', 5)
    seconds = entry.get('seconds_per_file', 60)
    for module in RAISING153_MODULES:
        output = scratch / (module + '.olean')
        log = receipts / (entry['id'] + '.' + module + '.log')
        argv = [str(lean), '-j1', '-s16384', '-DwarningAsError=true', '-DElab.async=false',
                '-o', str(output), module + '.lean']
        lock_attempts = []
        code = None
        elapsed = None
        for lock_attempt in range(60):
            try:
                code, elapsed = run_real(argv, scratch, seconds, log, max_wait=lock_wait, extra_env=env)
            except OSError as exc:
                log.write_text('Compiler launch failed: ' + str(exc) + '\n')
                code, elapsed = None, 0
            if not (code is None and log.exists() and 'lock wait expired' in log.read_text()):
                break
            wait_log = log.with_name(log.name + '.lock-' + str(lock_attempt))
            shutil.copy2(log, wait_log)
            lock_attempts.append(dict(attempt=lock_attempt, log=str(wait_log), log_sha256=sha(wait_log)))
        if lock_attempts:
            result['lock_only_retries'][module] = lock_attempts
        if code is None and log.exists() and 'lock wait expired' in log.read_text():
            result['skipped'] = True
            result['reason'] = 'compiler lock busy'
            receipt = dict(
                file=module + '.lean', command=argv, workdir=str(scratch),
                environment=dict(env), address_space_bytes=HOST_LEAN_ADDRESS_SPACE,
                exit_status=code, elapsed_seconds=elapsed, log=str(log),
                log_sha256=sha(log) if log.exists() else None,
                output=str(output), output_sha256=None,
                source_sha256=sha(scratch / (module + '.lean')))
            receipt_path = receipts / (entry['id'] + '.' + module + '.json')
            receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
            result['per_file'].append({**receipt, 'receipt': str(receipt_path)})
            return result
        receipt = dict(
            file=module + '.lean', command=argv, workdir=str(scratch),
            environment=dict(env), address_space_bytes=HOST_LEAN_ADDRESS_SPACE,
            exit_status=code, elapsed_seconds=elapsed, log=str(log),
            log_sha256=sha(log) if log.exists() else None,
            output=str(output), output_sha256=sha(output) if output.is_file() else None,
            source_sha256=sha(scratch / (module + '.lean')))
        receipt_path = receipts / (entry['id'] + '.' + module + '.json')
        receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
        result['per_file'].append({**receipt, 'receipt': str(receipt_path)})
        if code != 0 or not output.is_file() or output.stat().st_size == 0:
            result['reason'] = 'compiler failure or missing output: ' + module
            return result
        if module == 'CalculusRelayRaisingAxioms':
            log_text = log.read_text() if log.exists() else ''
            if not log_text.strip():
                result['reason'] = 'empty axiom log (no heuristic pass): ' + module
                return result
            names, parsed = _parse_axiom_prints(log_text)
            result['axiom_results_by_file'][module] = dict(
                names=names, expected=list(RAISING153_THEOREMS), parsed=parsed)
            for name, info in parsed.items():
                result['axiom_results'][name] = info
            if names != list(RAISING153_THEOREMS) or any(not parsed[n]['allowed'] for n in names):
                result['reason'] = 'audit mismatch or forbidden axiom: ' + module
                return result
    result['passed'] = (
        len(result['axiom_results']) == 28
        and all(a['allowed'] for a in result['axiom_results'].values())
        and result.get('theorem_validation', {}).get('ok') is True
    )
    if not result['passed']:
        result['reason'] = result.get('reason') or 'audit key order/count mismatch'
    result['exit_status'] = 0 if result['passed'] else 1
    result['scope'] = entry.get('scope')
    result['not_claimed'] = entry.get('not_claimed')
    result['axiom_whitelist'] = sorted(ALLOWED_AXIOMS)
    return result



SHELL142_MODULES = (
    'CalculusNested', 'CalculusExport', 'CalculusBody', 'CalculusSimulation',
    'CalculusRelayLoop', 'CalculusRelayOuter', 'MemoryTransfer', 'BufferRelay',
    'CompareMain', 'CalculusRelaySpec', 'ScheduleConsumption', 'CalculusRelaySchedules',
    'CalculusRelayShared', 'ShellObservation', 'CalculusCommands', 'CalculusShellText',
    'CalculusShellTextSound', 'CalculusQuery', 'CalculusShellTextQuery',
    'CalculusShellTextRootFixtures',
)
SHELL142_AUDIT = {
    'MemoryTransfer': [
        'MemoryTransfer.load_store', 'MemoryTransfer.load_store_disjoint',
        'MemoryTransfer.success_bounds', 'MemoryTransfer.success_contract',
        'MemoryTransfer.read_emit_observation', 'MemoryTransfer.relay_contract',
        'MemoryTransfer.relays_observation', 'MemoryTransfer.relays_conservation',
        'MemoryTransfer.ready_relay_exists', 'MemoryTransfer.store_frame',
        'MemoryTransfer.invalid_is_ub', 'MemoryTransfer.error_preserves_state',
        'MemoryTransfer.Examples.short_binary_read',
        'MemoryTransfer.Examples.exhausted_input_read',
        'MemoryTransfer.Examples.foreign_pointer_ub',
        'MemoryTransfer.Examples.overrun_ub_even_when_short',
        'MemoryTransfer.Examples.one_past_zero',
        'MemoryTransfer.Examples.one_past_nonzero_ub',
        'MemoryTransfer.Examples.error_has_no_effect',
        'MemoryTransfer.Examples.invalid_error_path_is_ub',
        'MemoryTransfer.store_at', 'MemoryTransfer.amount_bounds',
        'MemoryTransfer.read', 'MemoryTransfer.emit',
    ],
    'CalculusRelaySchedules': [
        'relay_outer_schedules_step', 'relay_outer_schedules',
        'relay_matches_phase3_schedules', 'OuterExactSchedules.residuals_drop',
    ],
    'CalculusRelayShared': [
        'related_prologue', 'relay_body_shared', 'relay_action_shared', 'relay_entry_shared',
    ],
    'CalculusCommands': [
        'mark_body', 'mark_action', 'runCmd_iff_exec', 'Budget.relay_step', 'encode_run',
        'encode_sound', 'encoded_query_sound', 'relayAndMark_query', 'relayOrMark_read_error',
        'relayOrMark_read_error_nested', 'relayAndMark_nested',
    ],
    'CalculusShellTextSound': [
        'parse_sound', 'parseTokens_sound', 'parseProgram_sound', 'parseSupported_sound',
    ],
    'CalculusQuery': [
        'compile_eval', 'prologue_run', 'program_run', 'script_query_run', 'script_query_universal',
        'relayAndMark_markedOrFailed', 'relay_alone_not_marked', 'relayOrMark_statusZero',
        'relayAndMark_markedOrFailed_nested', 'relayOrMark_statusZero_nested', 'export_mark_body',
        'markSpec_of_commands', 'markSpec_of_export', 'encode_run_spec',
        'script_query_universal_spec', 'relayAndMark_markedOrFailed_export',
        'relayOrMark_statusZero_export',
    ],
    'CalculusShellTextQuery': [
        'CalculusShellText.compileScriptQuery_nested',
        'CalculusShellText.compileScriptQuery_some',
    ],
}
SHELL142_THEOREMS = tuple(n for names in SHELL142_AUDIT.values() for n in names)
SHELL142_FILES = {
    'BufferRelay.lean': 'b07e64e4499e38f0ab0f0879a1ad54fcf1d4b1cfe5c723cad111d4eef6538877',
    'CalculusBody.lean': '481d8d61041e2893697c03c2cc5db7cc92d1f7c8389041164d4b43ff3c3aa5c6',
    'CalculusCommands.lean': '16efc2851af54840989030f876a062a26216b51fb85464e8a21a5fa83721f681',
    'CalculusExport.lean': 'd11ba63f0bd8f465bf60f489c3b5daab9bf4f46bc4c3f051361e8aae4083a763',
    'CalculusNested.lean': 'e2a7cffb206b3669da4bb56961b22d6d676063feeebade3212be822ee1fd651d',
    'CalculusQuery.lean': '0162c7938bac5e1cd73c56dc1f12c6f813978c7ea6234f5f9dcce2b9e0906c59',
    'CalculusRelayLoop.lean': 'c5ece9e93b95002116de63b2fd2736971bf08ad0625f6c049fa7abe10c604f09',
    'CalculusRelayOuter.lean': 'c49b20a885f1a5dfa52997e68fbfc885d90b5f3f7d2c7598c1d992d6200bc1eb',
    'CalculusRelaySchedules.lean': 'af7e21e14e9cbbbb0ccd257f47e8b102614ad9faf778b857fe8b9aa8fe3baac4',
    'CalculusRelayShared.lean': '160830a7807ccd8b6e0f8c8e731fa1bae37cf503566e4646a06212d42ad54fda',
    'CalculusRelaySpec.lean': '860e66d82bc39ec8b1dbbf25f088c228a92c70ddf4780538dec379b07b8d35ca',
    'CalculusShellText.lean': '742d002844d318716d43714d1397881ede5a872ef9f4409b25c7514d99099071',
    'CalculusShellTextQuery.lean': '7d0c32dc29ec89a33430778acfb81a8994fe94807b0fea764bf519d726be0b06',
    'CalculusShellTextRootFixtures.lean': 'db4f477a9f1841d50676e4f4e8ab4e0056ef476a5ccf5c41c582ac927ce20e4d',
    'CalculusShellTextSound.lean': '9126ea58bbf472adb7e9362f1dfd7b3fb7226dfab7e098ecad8a0fb34fa2686b',
    'CalculusSimulation.lean': '37ed70b30c5347ebe33ee5b9cb5cb233b296f83a828ab1b5f7a9eaba1362bc80',
    'CompareMain.lean': '6b9177464411f05dc42bff1bab5151d4ca22103d27450990b0492b85605f8d00',
    'MemoryTransfer.lean': '9f80ebc6b33b81960aada7a3967ad0455d9b086d679b55439454302dca6d1d71',
    'ScheduleConsumption.lean': '952e3e7307457b929da8a16ec0b4fdc881b27c5a96bc0fd562b9bf3fd4e96235',
    'ShellObservation.lean': '029c64d6a8f4a3b53dc6dfeb6c618e1066f1b1d55cb86e5f3a5bfa09041e19ba',
    'fixtures.json': '4a9e90d71796233236534aa29232abd138362e7bb194bbf929539bca583cf6e7',
    'lakefile.toml': '9498dbc794307d5a7b578bf19a0f9fc736af179725f97a46ae0982fed45f00f2',
    'lean-toolchain': 'efac0b94923b2d8b6840cd35be9177ad0fc5ab2332f4f4311c98712cee92fdee',
}
_SHELL142_CASE_RE = re.compile(r'\("case(\d+)",\s*(true|false)\)')
_SHELL142_SORRY_RE = re.compile(r'\bsorry\b')


def _shell142_parse_fixture_log(text):
    found = []
    for m in _SHELL142_CASE_RE.finditer(text):
        idx = int(m.group(1))
        if idx != len(found):
            raise ValueError('fixture case order mismatch at %s vs %s' % (idx, len(found)))
        found.append(m.group(2) == 'true')
    return found


def replay_lean_calculus_shellfrontend142(entry, receipts):
    """Isolated shellfrontend142 adapter: raw Lean argv through run_real (3GiB cap), lock-only retry."""
    result = dict(passed=False, per_file=[], axiom_results={}, axiom_results_by_file={},
                  lock_only_retries={})
    expected_files = set(SHELL142_FILES)
    try:
        hashes = entry['source_files']
        if (not isinstance(hashes, dict) or hashes != SHELL142_FILES
                or set(hashes) != expected_files
                or entry.get('modules') != list(SHELL142_MODULES)
                or entry.get('theorems') != list(SHELL142_THEOREMS)
                or entry.get('archive_dir') != 'phase5/artifact/archive/calculus-shellfrontend142'):
            raise ValueError('malformed shellfrontend142 snapshot specification')
        arch = LIBC / entry['archive_dir']
        ok, identity = hash_verify_host(arch, hashes)
        result['file_identity'] = identity
        if not ok:
            raise ValueError('shellfrontend142 archive identity mismatch or missing file')
        if (arch / 'lean-toolchain').read_text() != LEAN_TOOLCHAIN:
            raise ValueError('unexpected pinned Lean toolchain')
        for module, expected in SHELL142_AUDIT.items():
            names = re.findall(r'^#print axioms (\S+)', (arch / (module + '.lean')).read_text(), re.M)
            if names != expected:
                raise ValueError('archive audit mismatch: ' + module)
        for lean_file in sorted(arch.glob('*.lean')):
            body = lean_file.read_text()
            stripped = re.sub(r'/-.*?-/', '', body, flags=re.S)
            stripped = re.sub(r'--.*', '', stripped)
            if _SHELL142_SORRY_RE.search(stripped):
                raise ValueError('sorry present: ' + lean_file.name)
        lean = _pinned_lean_binary()
        scratch = fresh_scratch('shellfrontend142')
        for filename in hashes:
            shutil.copy2(arch / filename, scratch / filename)
        staged_ok, staged_identity = hash_verify_host(scratch, hashes)
        result.update(scratch=str(scratch), staged_identity=staged_identity,
                      compiler=str(lean), compiler_sha256=sha(lean))
        if not staged_ok:
            raise ValueError('staged shellfrontend142 snapshot identity mismatch')
    except (KeyError, TypeError, ValueError, OSError) as exc:
        result['reason'] = str(exc)
        return result
    env = {'LEAN_PATH': str(scratch), 'LEAN_NUM_THREADS': '1', 'MIMALLOC_ARENA_RESERVE': '65536'}
    lock_wait = entry.get('lock_wait_seconds', 5)
    seconds = entry.get('seconds_per_file', 60)
    for module in SHELL142_MODULES:
        output = scratch / (module + '.olean')
        log = receipts / (entry['id'] + '.' + module + '.log')
        argv = [str(lean), '-j1', '-s16384', '-DwarningAsError=true', '-DElab.async=false',
                '-o', str(output), module + '.lean']
        lock_attempts = []
        code = None
        elapsed = None
        for lock_attempt in range(60):
            try:
                code, elapsed = run_real(argv, scratch, seconds, log, max_wait=lock_wait, extra_env=env)
            except OSError as exc:
                log.write_text('Compiler launch failed: ' + str(exc) + '\n')
                code, elapsed = None, 0
            if not (code is None and log.exists() and 'lock wait expired' in log.read_text()):
                break
            wait_log = log.with_name(log.name + '.lock-' + str(lock_attempt))
            shutil.copy2(log, wait_log)
            lock_attempts.append(dict(attempt=lock_attempt, log=str(wait_log), log_sha256=sha(wait_log)))
        if lock_attempts:
            result['lock_only_retries'][module] = lock_attempts
        if code is None and log.exists() and 'lock wait expired' in log.read_text():
            result['skipped'] = True
            result['reason'] = 'compiler lock busy'
            receipt = dict(
                file=module + '.lean', command=argv, workdir=str(scratch),
                environment=dict(env), address_space_bytes=HOST_LEAN_ADDRESS_SPACE,
                exit_status=code, elapsed_seconds=elapsed, log=str(log),
                log_sha256=sha(log) if log.exists() else None,
                output=str(output), output_sha256=None,
                source_sha256=sha(scratch / (module + '.lean')))
            receipt_path = receipts / (entry['id'] + '.' + module + '.json')
            receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
            result['per_file'].append({**receipt, 'receipt': str(receipt_path)})
            return result
        receipt = dict(
            file=module + '.lean', command=argv, workdir=str(scratch),
            environment=dict(env), address_space_bytes=HOST_LEAN_ADDRESS_SPACE,
            exit_status=code, elapsed_seconds=elapsed, log=str(log),
            log_sha256=sha(log) if log.exists() else None,
            output=str(output), output_sha256=sha(output) if output.is_file() else None,
            source_sha256=sha(scratch / (module + '.lean')))
        receipt_path = receipts / (entry['id'] + '.' + module + '.json')
        receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
        result['per_file'].append({**receipt, 'receipt': str(receipt_path)})
        if code != 0 or not output.is_file() or output.stat().st_size == 0:
            result['reason'] = 'compiler failure or missing output: ' + module
            return result
        log_text = log.read_text() if log.exists() else ''
        if module in SHELL142_AUDIT:
            if not log_text.strip():
                result['reason'] = 'empty axiom log (no heuristic pass): ' + module
                return result
            names, parsed = _parse_axiom_prints(log_text)
            expected = SHELL142_AUDIT[module]
            # 161: Lean prints module-qualified names; Budget/OuterExactSchedules need prefix.
            namespace = 'CalculusShellText' if module == 'CalculusShellTextQuery' else module
            qualified = [n if n.startswith(namespace + '.') else namespace + '.' + n for n in expected]
            result['axiom_results_by_file'][module] = dict(
                names=names, expected=expected, qualified=qualified, parsed=parsed)
            for name, info in parsed.items():
                result['axiom_results'][module + ':' + name] = info
            ok_names = names == expected or names == qualified
            if not ok_names or any(not parsed[n]['allowed'] for n in names):
                result['reason'] = 'audit mismatch or forbidden axiom: ' + module
                return result
        if module == 'CalculusShellTextRootFixtures':
            if not log_text.strip():
                result['reason'] = 'empty fixture log (no heuristic pass)'
                return result
            fixtures = json.loads((scratch / 'fixtures.json').read_text())
            got = _shell142_parse_fixture_log(log_text)
            if len(got) != 38 or len(fixtures) != 38:
                result['reason'] = 'fixture count %s vs %s not 38' % (len(got), len(fixtures))
                return result
            mismatches = []
            for i, (exp, actual) in enumerate(zip(fixtures, got)):
                if bool(exp['expected_supported']) != actual:
                    mismatches.append(dict(i=i, text=exp['text'],
                                           expected=exp['expected_supported'], actual=actual))
            result['fixtures'] = dict(count=38, passed=38 - len(mismatches), mismatches=mismatches)
            if mismatches:
                result['reason'] = 'fixture mismatch vs 135 fixtures.json'
                return result
    expected_count = sum(len(v) for v in SHELL142_AUDIT.values())
    result['passed'] = (
        len(result['axiom_results']) == expected_count
        and set(result['axiom_results_by_file']) == set(SHELL142_AUDIT)
        and all(a['allowed'] for a in result['axiom_results'].values())
        and result.get('fixtures', {}).get('passed') == 38
    )
    if not result['passed']:
        result['reason'] = result.get('reason') or 'audit key order/count mismatch'
    result['exit_status'] = 0 if result['passed'] else 1
    result['scope'] = entry.get('scope')
    result['not_claimed'] = entry.get('not_claimed')
    result['axiom_whitelist'] = sorted(ALLOWED_AXIOMS)
    return result


REPLAYERS = {
    'lean_stateful55_replay': replay_lean_stateful55,
    'lean_calculus_typed_shared77_replay': replay_lean_typed_shared77,
    'lean_calculus_query_guards95_replay': replay_lean_query_guards95,
    'lean_calculus_tokenizer134_replay': replay_lean_tokenizer134,
    'lean_calculus_raising153_replay': replay_lean_calculus_raising153,
    'lean_calculus_shellfrontend142_replay': replay_lean_calculus_shellfrontend142,
    'case_wrapper_transfer_chain_replay': replay_case_wrapper_transfer_chain,
    'lean_phase3_project': replay_lean_phase3_project,
    'lean_calculus_nested_real': replay_lean_calculus_nested_real,
    'lean_calculus_body_replay': replay_lean_calculus_body,
    'lean_calculus_outer_replay': replay_lean_calculus_outer,
    'utility_juicy_dry_chain_replay': replay_utility_juicy_dry_chain,
    'lean_calculus_spec15_replay': replay_lean_calculus_spec15,
    'utility_pre_drypost_chain_replay': replay_utility_pre_drypost_chain,
    'c_relay_compile': replay_c_relay_compile,
    'coq_relay_ast_replay': replay_coq_relay_ast,
    'gnu_vsu_utility_reuse_chain_replay': replay_gnu_vsu_chain,
    'shell_bridge_chain_replay': replay_shell_bridge_chain,
    'relay_full_behavioral_chain_replay': replay_relay_full_chain,
    'universal_full_chain_replay': replay_universal_full_chain,
    'shell_expansion_accepted_replay': replay_shell_expansion_accepted,
    'case_studies_full_chain_replay': replay_case_studies_full_chain,
    'shell_expansion_compose_chain_replay': replay_shell_expansion_compose_chain,
    'case_studies_differential_replay': replay_case_studies_differential,
    'coq_universal_ast_replay': replay_coq_universal_ast,
    'ocaml_state_based_pinned_container': replay_ocaml_state_based_container,
    'calculus_bytes_corpus_comparison_replay': replay_calculus_bytes_corpus,
    'calculus_bytes_oracle_chain_replay': replay_calculus_bytes_oracle_chain,
    'calculus_bytes_check_v2_replay': replay_calculus_bytes_check_v2,
}


REPLAY_PY_SHA256 = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()[:16]
# artifact-finish-12, final root round: caching for the chain entries is DISABLED entirely.
# Root's third negative-test round (ROOT-CACHE-PREFIX-PROBE.json) established that scratch-path-
# prefix + -Q-count validation is not, and cannot be, EXACT command/workdir provenance: every
# real chain execution generates a brand-new random scratch directory name
# (`uuid.uuid4().hex[:8]`) by design, so there is no stable "the expected exact argv/workdir" a
# past receipt can be compared against -- only structural plausibility, which root correctly
# rejected as insufficient ("do not fit only the literal /wrong reproducer... exact required
# comparison = command == expected argv... using the same chain planning data"). Root explicitly
# offered the fallback used here: "If cache cannot establish provenance reliably, disable
# affected caching and execute fresh rather than claim validation." Every replay.py invocation
# now always executes every non-pending entry fresh; `find_cached_pass` is kept (dead code path,
# always empty) rather than deleted, so a future worker who builds a truly deterministic
# provenance mechanism (e.g. content-addressed scratch names, or a signed chain-of-custody
# linking each receipt to its exact manifest entry) can re-enable it deliberately, entry by
# entry, rather than by accident.
CHECK_ONLY_CAPABLE = set()


def entry_fingerprint(entry):
    """Hash of everything in the entry EXCEPT prose (description) and tunables that don't
    change what's actually being verified (seconds/timeouts) -- so editing a comment or a wall
    budget doesn't invalidate a cached pass, but any source-hash/path/order change does. Also
    folds in this SCRIPT's own sha256: editing replay.py's compile logic (as happened this
    session -- gnu_vsu_utility_reuse_chain_replay's lock granularity changed without its
    manifest entry changing) must invalidate old caches even though the entry data didn't
    change -- root review's exact finding."""
    relevant = {k: v for k, v in entry.items()
               if k not in ('description', 'seconds', 'seconds_per_file')}
    relevant['_replay_py_sha256'] = REPLAY_PY_SHA256
    return hashlib.sha256(json.dumps(relevant, sort_keys=True).encode()).hexdigest()[:16]


def find_cached_pass(out_dir, entry_id, fingerprint, entry):
    """Look for the most recent PASSING receipt of this exact entry (same fingerprint, same
    replay.py version) in any prior run under out_dir, THEN actively re-validate it before
    trusting it (root review finding: a prior version trusted a cached summary's 'passed' flag
    with no re-check of live source, receipt files, or whether the candidate was itself just
    another cache reuse -- '072926Z wholly reused 072820Z' with nothing re-verified in between).
    Three checks, in order, all cheap (no compiler invocations):
      1. Only consider ORIGINAL execution results (skip anything with its own 'cached_from_run'
         -- never chain cache off cache; every hit traces to one real receipt).
      2. Every per-file (or single-file) receipt log this candidate recorded must still exist
         on disk with a MATCHING sha256 -- a deleted/edited/corrupted log invalidates the cache.
      3. For entries that support it (CHECK_ONLY_CAPABLE), re-run JUST the hash-verification
         phase against the CURRENT live source (no staging, no compiling) and require it to
         still report full identity match -- a source edit since the cached run invalidates it,
         even though the manifest entry (and thus the fingerprint) didn't change.
    Returns (run_id, cached_result) or (None, None) with a 'cache_reject_reason' side-note
    printed for any near-miss so silent staleness isn't invisible."""
    if not out_dir.exists():
        return None, None
    for d in sorted((p for p in out_dir.iterdir() if p.is_dir()), reverse=True):
        sp = d / 'summary.json'
        if not sp.exists():
            continue
        try:
            s = json.loads(sp.read_text())
        except (json.JSONDecodeError, OSError):
            continue
        for r in s.get('results', []):
            if not (r.get('id') == entry_id and r.get('passed')
                    and r.get('entry_fingerprint') == fingerprint):
                continue
            if r.get('cached_from_run'):
                continue  # check 1: never chain cache off cache
            if entry_id not in CHECK_ONLY_CAPABLE:
                # root review: caching an entry with no live-source re-validation path is
                # unsafe (stale-cacheable) -- fail closed, always execute fresh, rather than
                # claim every entry is cache-valid when only the 5 chain entries actually are.
                continue
            # check 2a: the per_file list must contain EXACTLY the (group, file) set the CURRENT
            # manifest entry would actually produce -- not just the right COUNT (root's exact
            # finding: a same-sized per_file list could still be missing one required file while
            # duplicating another, or a stale/self-reported files_total could be trusted instead
            # of the real manifest-derived chain).
            per_file = r.get('per_file', [])
            expected = expected_group_files(entry_id, entry)
            if expected is None:
                print(f'  (cache candidate {d.name} rejected: no expected-file-set spec for {entry_id})')
                continue
            actual_pairs = sorted((pf.get('group'), pf.get('file')) for pf in per_file)
            if actual_pairs != sorted(expected):
                print(f'  (cache candidate {d.name} rejected: per_file (group,file) set does not '
                      f'match the manifest-derived chain -- {len(actual_pairs)} vs {len(expected)} expected)')
                continue
            # check 2b: EVERY file's REAL underlying run_vst.py receipt (not our own summary's
            # self-reported log hash) must independently confirm exit_status==0, a coqc command
            # that actually compiles that exact file, and a log whose current content still
            # hashes to what the receipt recorded -- root review's "open actual run receipt
            # JSON... status/timing/command/workdir/hash" requirement.
            all_receipts_ok = True
            reject_detail = None
            for pf in per_file:
                if pf.get('exit_status') != 0 or not pf.get('receipt_name') or not pf.get('file'):
                    all_receipts_ok = False
                    reject_detail = f"per_file entry incomplete/failed: {pf.get('file')!r}"
                    break
                qcount = expected_q_arg_count(entry_id, pf.get('group'), pf['file'])
                ok, reason = verify_real_receipt(pf['receipt_name'], pf['file'], expected_q_count=qcount)
                if not ok:
                    all_receipts_ok = False
                    reject_detail = f"{pf['file']}: {reason}"
                    break
            if not all_receipts_ok:
                print(f'  (cache candidate {d.name} rejected: {reject_detail})')
                continue  # check 2
            check = REPLAYERS[entry_id](entry, None, check_only=True)
            if not check.get('passed'):
                print(f'  (cache candidate {d.name} rejected: live source no longer matches)')
                continue  # check 3
            return d.name, r
    return None, None


def utc_stamp(dt):
    """UTC ISO-8601 seconds for summary timestamps. Distinct from run_id (compact Z form)."""
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=datetime.timezone.utc)
    return dt.astimezone(datetime.timezone.utc).isoformat(timespec='seconds')


def run_id_from(dt):
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=datetime.timezone.utc)
    return dt.astimezone(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')


def summary_time_fields(started, finished):
    """Truthful wall-clock fields: started at process start, finished at summary write.

    Historical full19 wrote started_utc at summary time (~end 10:52:16) while run_id / process
    start was 10:40:47. Keep run_id derived from the same `started` instant.
    """
    return dict(run_id=run_id_from(started),
                started_utc=utc_stamp(started),
                finished_utc=utc_stamp(finished))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out-dir', type=Path,
                    default=Path.home() / 'agent-jobs/astra-research/phase5/claude-resume'
                    / 'evaluation-artifact-4/artifact-replay')
    ap.add_argument('--fresh', action='store_true',
                    help='ignore all cached passes; truly fresh full replay of every entry')
    ap.add_argument('--only', type=str, default=None,
                    help='comma-separated entry ids to run (skips fingerprint caching for '
                         'entries not listed; for iterating on one entry without paying for '
                         'the whole manifest every time)')
    args = ap.parse_args()
    out_dir = args.out_dir.expanduser().resolve()
    if LIBC.parents[1] in out_dir.parents:
        ap.error('receipts must stay outside the repository')
    only = set(args.only.split(',')) if args.only else None
    started = datetime.datetime.now(datetime.timezone.utc)
    run_id = run_id_from(started)
    receipts = out_dir / run_id
    receipts.mkdir(parents=True)
    manifest = json.loads((HERE / 'manifest.json').read_text())
    results = []
    overall_ok = True
    for entry in manifest['entries']:
        eid, cat = entry['id'], entry['category']
        if only and eid not in only:
            continue
        if cat == 'pending':
            results.append(dict(id=eid, category=cat, kind=entry.get('kind'), skipped=True,
                                reason=entry.get('reason', 'not yet accepted upstream'), passed=None))
            print(f'[{cat}] {eid}: PENDING (not yet accepted upstream, not skipped-as-complete)')
            continue
        if entry.get('status') == 'missing_environment':
            results.append(dict(id=eid, category=cat, kind=entry['kind'], skipped=True,
                                reason=entry['reason'], passed=None))
            print(f'[{cat}] {eid}: SKIPPED (missing_environment) -- {entry["reason"][:80]}...')
            continue
        fp = entry_fingerprint(entry)
        if not args.fresh:
            cached_run, cached_r = find_cached_pass(out_dir, eid, fp, entry)
            if cached_r:
                r = dict(cached_r)
                r['cached_from_run'] = cached_run
                r['entry_fingerprint'] = fp
                results.append(r)
                print(f'[{cat}] {eid}: CACHED-PASS (unchanged since {cached_run}; use --fresh to force)')
                continue
        replayer = REPLAYERS[eid]
        t0 = time.monotonic()
        r = replayer(entry, receipts)
        r.update(id=eid, category=cat, kind=entry['kind'], wall_seconds=round(time.monotonic() - t0, 2),
                 entry_fingerprint=fp)
        results.append(r)
        status = 'SKIPPED' if r.get('skipped') else ('PASS' if r.get('passed') else 'FAIL')
        print(f'[{cat}] {eid}: {status} ({r["wall_seconds"]}s)')
        if cat == 'required' and not r.get('passed'):
            overall_ok = False
    # Three aggregates, deliberately NOT collapsed into one boolean -- root review found
    # `required_all_passed` alone reads as "the replay is done" when it actually only gates the
    # 3 required-category entries and says nothing about current/pending/experimental state.
    non_pending = [r for r in results if r.get('category') not in ('pending',)]
    gating = [r for r in non_pending if r.get('category') != 'experimental']
    selected_all_passed = bool(gating) and all(r.get('passed') is True for r in gating)
    any_pending_in_manifest = any(e['category'] == 'pending' for e in manifest['entries'])
    full_scope_complete = selected_all_passed and only is None and not any_pending_in_manifest
    finished = datetime.datetime.now(datetime.timezone.utc)
    times = summary_time_fields(started, finished)
    if times['run_id'] != run_id:
        raise RuntimeError('run_id drifted from started instant')
    summary = dict(schema='phase5-artifact-replay-summary/2', run_id=run_id,
                   started_utc=times['started_utc'],
                   finished_utc=times['finished_utc'],
                   manifest_frozen_utc=manifest['frozen_utc'], results=results,
                   fresh_mode=args.fresh, only_filter=sorted(only) if only else None,
                   required_all_passed=overall_ok,
                   required_all_passed_meaning=('ONLY the 3 required-category entries (fresh-copy '
                       'Lean/C builds with no shared-container dependency); does NOT reflect '
                       'current/pending/experimental status -- see selected_all_passed and '
                       'full_scope_complete for that'),
                   selected_all_passed=selected_all_passed,
                   selected_all_passed_meaning=('every entry actually attempted this run (subject '
                       'to --only if given), excluding pending and experimental, has passed=true; '
                       'false on ANY skip, fail, or lock-exhaustion among required/current entries'),
                   full_scope_complete=full_scope_complete,
                   full_scope_complete_meaning=('selected_all_passed AND the full manifest was run '
                       '(no --only) AND zero pending entries remain in manifest.json -- this is '
                       'false while case_studies_body_proofs_pending / '
                       'shell_expansion_extended_compose_pending exist, by design: pending means '
                       'not yet accepted, not silently complete'),
                   known_gaps=manifest['known_gaps'])
    summary_path = receipts / 'summary.json'
    summary_path.write_text(json.dumps(summary, indent=2) + '\n')
    print('summary:', summary_path)
    print('required_all_passed:', overall_ok, '(narrow scope, see required_all_passed_meaning)')
    print('selected_all_passed:', selected_all_passed)
    print('full_scope_complete:', full_scope_complete)
    sys.exit(0 if overall_ok else 1)


if __name__ == '__main__':
    main()
