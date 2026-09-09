#!/usr/bin/env python3
"""Check one submitted proof body against a frozen task, in a private Lean build copy.

Gates, in order (any failure rejects the attempt, all are recorded):
  1. frozen identity: template hash equals tasks/manifest.json; every source in the private
     build copy is byte-identical to the repository file it was copied from;
  2. lexical guard on the submission (no sorry/admit/axiom/new declarations/imports/options);
  3. `lake build +<Module>:olean` on the module = frozen template + submission, single thread,
     120 s wall / 3 GiB address space; a build that mentions `sorry` is a failure;
  4. `#print axioms` of the target must be a subset of {propext, Classical.choice, Quot.sound};
  5. `#check @<target>` output must equal the pretty-printed type recorded from the unchanged
     repository build (theorem-strength identity independent of the template text).
Caches and receipts live outside the repository (~/.cache and the job directory).
"""
import argparse
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

HERE = Path(__file__).resolve().parent
LIBC = HERE.parents[1]
TASKS = HERE / 'tasks'
CACHE = Path.home() / '.cache/bash-spec-pilot/phase5-evaluation'
BASELINE = CACHE / 'baseline'
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}
BASE_SOURCES = ['memory-experiment/MemoryTransfer.lean', 'phase2/BufferRelay.lean',
                'phase3/PointerCore.lean', 'phase3/PointerRelay.lean', 'phase3/ShellObservation.lean',
                'phase3/RelayComposition.lean', 'phase3/TraceMain.lean', 'phase3/PointerAxioms.lean',
                'phase3/ShellAxioms.lean', 'phase3/CompositionAxioms.lean', 'phase3/lakefile.toml',
                'phase3/lean-toolchain']
FORBIDDEN = re.compile(
    r"^\s*(import|open|set_option|namespace|end|section|variable|universe|attribute)\b"
    r"|\b(theorem|lemma|def|abbrev|instance|structure|inductive|axiom|axioms|sorry|admit|opaque|"
    r"partial|unsafe|native_decide|macro|macro_rules|elab|syntax|notation|extern|implemented_by|"
    r"decide\s*\+kernel)\b|^\s*#", re.M)
AXIOM_LINE = re.compile(r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)")


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


LOCK = Path.home() / '.cache/bash-spec-pilot/phase3-compiler.lock'
LOCK_WAIT = {'seconds': 0.0, 'retries': 0}


def acquire_lock(max_wait=900):
    """Shared compiler lock (same flock as phase3/run_vst.py). Sibling workers build Lean/VST
    concurrently; wait 30 s and retry rather than overlap. Never held during model generation."""
    LOCK.parent.mkdir(parents=True, exist_ok=True)
    handle = LOCK.open('a')
    t0 = time.monotonic()
    while True:
        try:
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
            LOCK_WAIT['seconds'] = round(time.monotonic() - t0, 1)
            return handle
        except BlockingIOError:
            if time.monotonic() - t0 > max_wait:
                raise SystemExit('compiler lock busy for more than %d s; not a proof failure' % max_wait)
            LOCK_WAIT['retries'] += 1
            time.sleep(30)


def run(argv, cwd, seconds, log):
    env = dict(os.environ, LEAN_NUM_THREADS='1', LEAN_STACK_SIZE_KB='16384')
    handle = acquire_lock()
    t0 = time.monotonic()
    try:
        with open(log, 'w') as stream:
            cp = subprocess.run(['timeout', '--kill-after=2s', f'{seconds}s', 'prlimit',
                                 '--as=3221225472:3221225472', '--core=0:0', '--', *argv],
                                cwd=cwd, env=env, stdout=stream, stderr=subprocess.STDOUT)
    finally:
        fcntl.flock(handle, fcntl.LOCK_UN)
        handle.close()
    return cp.returncode, time.monotonic() - t0, Path(log).read_text()


def check_file(module, theorem):
    return f'import {module}\n#print axioms {theorem}\n#check @{theorem}\n'


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--task', required=True)
    ap.add_argument('--condition', required=True, choices=['helper', 'base'])
    ap.add_argument('--submission', type=Path, required=True, help='file with the proof body only')
    ap.add_argument('--name', required=True, help='fresh receipt name')
    ap.add_argument('--receipts', type=Path,
                    default=Path.home() / 'agent-jobs/astra-research/phase5/claude-resume/evaluation/checks')
    ap.add_argument('--record-baseline', action='store_true',
                    help='record the repository theorem type into tasks/<task>/expected_check.txt')
    ap.add_argument('--seconds', type=int, default=120)
    args = ap.parse_args()
    manifest = json.loads((TASKS / 'manifest.json').read_text())
    task = manifest['tasks'][args.task]
    cond = task['conditions'][args.condition]
    receipts = args.receipts.expanduser().resolve()
    if LIBC.parents[1] in receipts.parents:
        ap.error('receipts must stay outside the repository')
    receipts.mkdir(parents=True, exist_ok=True)
    receipt = receipts / (args.name + '.json')
    if receipt.exists():
        ap.error('choose a fresh name; receipts are never overwritten')
    rec = dict(schema='phase5-evaluation-check/1', name=args.name, task=args.task,
               condition=args.condition, theorem=task['theorem'], module=task['module'],
               checked_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds'),
               gates={}, accepted=False)

    def finish(reason=None):
        rec['compiler_lock_wait'] = dict(LOCK_WAIT)
        rec['reject_reason'] = reason
        rec['accepted'] = reason is None
        receipt.write_text(json.dumps(rec, indent=2) + '\n')
        print(json.dumps({k: rec[k] for k in ('name', 'accepted', 'reject_reason')}))
        raise SystemExit(0 if rec['accepted'] else 1)

    # Gate 1: frozen identity.
    template_path = HERE / cond['template']
    template = template_path.read_bytes()
    identity = dict(template_sha256=sha(template), template_matches=sha(template) == cond['template_sha256'],
                    source_matches=sha((LIBC / task['source']).read_bytes()) == task['source_sha256'],
                    baseline_copy_matches={})
    for rel in BASE_SOURCES:
        repo, copy = LIBC / rel, BASELINE / Path(rel).name
        identity['baseline_copy_matches'][rel] = copy.exists() and repo.read_bytes() == copy.read_bytes()
    rec['gates']['identity'] = identity
    if not (identity['template_matches'] and identity['source_matches']
            and all(identity['baseline_copy_matches'].values())):
        finish('frozen identity mismatch')

    # Gate 2: lexical guard and normalization (indent only; text otherwise untouched).
    submission = args.submission.read_text()
    rec['submission_sha256'] = sha(submission.encode())
    bad = FORBIDDEN.search(submission)
    rec['gates']['lexical'] = dict(forbidden_match=bad.group(0) if bad else None,
                                   nonempty=bool(submission.strip()))
    if bad or not submission.strip():
        finish('lexical guard: ' + (repr(bad.group(0)) if bad else 'empty submission'))
    body = '\n'.join('  ' + l if l.strip() else '' for l in submission.rstrip('\n').splitlines())
    module_text = template.decode().replace(' :=\n\nend ', ' :=\n' + body + '\n\nend ', 1)
    if body not in module_text:
        finish('template splice point not found')

    # Gate 3: build in a private copy of the frozen baseline.
    work = CACHE / 'attempts' / args.name
    if work.exists():
        finish('attempt directory already exists')
    shutil.copytree(BASELINE, work, symlinks=True)
    (work / f"{task['module']}.lean").write_text(module_text)
    rec['module_sha256'] = sha(module_text.encode())
    lake = shutil.which('lake') or str(Path.home() / '.elan/bin/lake')
    code, secs, out = run([lake, 'build', f"+{task['module']}:olean"], work, args.seconds,
                          receipts / (args.name + '.build.log'))
    sorry_seen = 'sorry' in out
    rec['gates']['build'] = dict(exit_status=code, elapsed_seconds=round(secs, 2), mentions_sorry=sorry_seen,
                                 log=str(receipts / (args.name + '.build.log')), log_sha256=sha(out.encode()),
                                 errors=[l for l in out.splitlines() if re.search(r'(?:^|:\s)error:', l)][:20])
    if code != 0 or sorry_seen:
        finish('build failed' if code else 'build mentions sorry')

    # Gates 4-5: axioms and theorem-type identity.
    (work / 'Check.lean').write_text(check_file(task['module'], task['theorem']))
    code, secs, out = run([lake, 'env', 'lean', '-j1', '-s16384', 'Check.lean'], work, args.seconds,
                          receipts / (args.name + '.check.log'))
    reported = {m[1]: sorted(a.strip() for a in (m[2] or '').split(',') if a.strip())
                for m in AXIOM_LINE.finditer(out)}
    axioms = reported.get(task['theorem'])
    check_lines = [l for l in out.splitlines() if not AXIOM_LINE.search(l)]
    check_text = '\n'.join(check_lines).strip()
    expected_path = TASKS / args.task / 'expected_check.txt'
    if args.record_baseline:
        expected_path.write_text(check_text + '\n')
    expected = expected_path.read_text().strip() if expected_path.exists() else None
    rec['gates']['axioms'] = dict(exit_status=code, reported=axioms,
                                  allowed=axioms is not None and set(axioms) <= ALLOWED)
    rec['gates']['theorem_type'] = dict(check_output_sha256=sha(check_text.encode()),
                                        expected_sha256=sha(expected.encode()) if expected else None,
                                        matches=expected is not None and check_text == expected)
    if code != 0 or axioms is None or not set(axioms) <= ALLOWED:
        finish('axiom gate failed')
    if not rec['gates']['theorem_type']['matches']:
        finish('theorem type does not match the recorded repository type')
    finish()


if __name__ == '__main__':
    main()
