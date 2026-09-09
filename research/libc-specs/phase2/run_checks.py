#!/usr/bin/env python3
"""Stage and check phase2; source/AST/model/runtime hashes and local-only caches."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import shutil
import subprocess
import sys
import time

from frontend import translate, binding

ROOT = Path(__file__).resolve().parent
TOOLCHAIN = 'leanprover/lean4:v4.31.0'
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def bounded_limit(kind, requested):
    hard = resource.getrlimit(kind)[1]
    n = requested if hard == resource.RLIM_INFINITY else min(requested, hard)
    return f'{n}:{n}'


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--source', type=Path, default=ROOT / 'relay.c')
    ap.add_argument('--cache', type=Path, default=Path.home() / '.cache/bash-spec-pilot/phase2')
    ap.add_argument('--out', type=Path, help='summary JSON, defaults to cache/check_result.json')
    args = ap.parse_args()
    cache = args.cache.expanduser().resolve()
    repository = ROOT.parents[2]
    if cache == repository or repository in cache.parents:
        ap.error('--cache must stay outside the repository')
    # Validate candidate BEFORE touching artifacts or invoking any compiler.
    # Rejection raises and aborts; previous cache is never built or reported as this candidate.
    source_bytes = args.source.read_bytes()
    translation = translate(source_bytes)
    required = ['BufferRelay.lean', 'Axioms.lean', 'Main.lean', 'InputBoundTests.lean', 'lakefile.toml', 'lean-toolchain']
    for name in required:
        if not (ROOT / name).is_file():
            ap.error('missing required source: ' + name)
    dependency = ROOT.parent / 'memory-experiment/MemoryTransfer.lean'
    if not dependency.is_file():
        ap.error('missing required phase1 MemoryTransfer.lean')
    work = cache / 'lean'
    work.mkdir(parents=True, exist_ok=True)
    # Stage immutable input snapshot; comparator is pointed at this same C byte snapshot.
    (work / 'relay.c').write_bytes(source_bytes)
    sources = {'relay.c': translation['source_sha256']}
    for name in required:
        src = ROOT / name
        sources[name] = sha(src)
        dst = work / name
        if not dst.exists() or dst.read_bytes() != src.read_bytes():
            shutil.copy2(src, dst)
    dst = work / 'MemoryTransfer.lean'
    if not dst.exists() or dst.read_bytes() != dependency.read_bytes():
        shutil.copy2(dependency, dst)
    sources['MemoryTransfer.lean'] = sha(dependency)
    generated = work / 'GeneratedRelay.lean'
    code = binding(translation)
    if not generated.exists() or generated.read_text() != code:
        generated.write_text(code)
    (cache / 'translation.json').write_text(json.dumps(translation, indent=2) + '\n')
    sources['GeneratedRelay.lean'] = sha(generated)
    for name in ['frontend.py', 'test_frontend.py', 'test_replay_guard.py', 'run_checks.py']:
        sources[name] = sha(ROOT / name)
    env = dict(os.environ, LEAN_NUM_THREADS='1', LEAN_STACK_SIZE_KB='16384', PYTHONDONTWRITEBYTECODE='1')
    lake = shutil.which('lake') or str(Path.home() / '.elan/bin/lake')
    timer = shutil.which('gtime') or '/usr/bin/time'
    measurements = {}

    def command(name, cmd, cwd, expected=None):
        log = cache / (name + '.log')
        timing = cache / (name + '.time.json')
        with log.open('w') as out:
            p = subprocess.run([timer, '-o', str(timing), '-f',
                '{"elapsed_seconds":%e,"peak_rss_kib":%M}',
                'timeout', '--kill-after=2s', '120s', 'prlimit',
                '--as=' + bounded_limit(resource.RLIMIT_AS, 3221225472), '--cpu=' + bounded_limit(resource.RLIMIT_CPU, 120), '--', *cmd],
                cwd=cwd, env=env, stdout=out, stderr=subprocess.STDOUT)
        text = log.read_text()
        if p.returncode or 'sorryAx' in text or re.search(r'declaration uses .sorry.', text):
            raise RuntimeError(f'{name} failed, see {log}')
        reports = {}
        for m in re.finditer(r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)", text):
            axioms = {a.strip() for a in (m[2] or '').split(',') if a.strip()}
            if not axioms <= ALLOWED:
                raise RuntimeError(f'{m[1]} uses unexpected axioms {axioms}')
            reports[m[1]] = sorted(axioms)
        if expected is not None and set(expected) != set(reports):
            raise RuntimeError(f'{name} axiom-manifest mismatch: see {log}')
        measurements[name] = dict(json.loads(timing.read_text()), exit_code=p.returncode, axioms=reports)

    command('frontend_tests', [sys.executable, '-B', '-m', 'unittest', 'discover', '-s', str(ROOT), '-p', 'test_*.py', '-v'], ROOT)
    # Build each module's Lean and C artifacts in dependency order. Lake may
    # otherwise overlap a dependency C compiler with its dependent Lean compiler.
    for module in ['MemoryTransfer', 'BufferRelay', 'GeneratedRelay', 'Main']:
        command('build_' + module + '_lean', [lake, 'build', '+' + module + ':olean'], work)
        command('build_' + module + '_c', [lake, 'build', '+' + module + ':c.o'], work)
    command('build', [lake, 'build'], work)
    expected = re.findall(r'^#print axioms (\S+)', (work / 'Axioms.lean').read_text(), re.M)
    if not expected:
        raise RuntimeError('required explicit proof manifest is empty')
    expected = [n if n.startswith('BufferRelay.') else 'BufferRelay.' + n for n in expected]
    command('kernel', [lake, 'env', 'lean', '-j1', '-s16384', '-DwarningAsError=true', 'Axioms.lean'], work, expected)
    command('binding', [lake, 'env', 'lean', '-j1', '-s16384', '-DwarningAsError=true', 'GeneratedRelay.lean'], work,
            ['GeneratedRelay.binding_is_reference'])
    command('input_bound_tests', [lake, 'env', 'lean', '-j1', '-s16384', 'InputBoundTests.lean'], work)
    if 'InputBoundTests: 72 finite cases and 1 returning no-EOF stream passed' not in (cache / 'input_bound_tests.log').read_text():
        raise RuntimeError('runtime input-bound test completion marker missing')
    executable = work / '.lake/build/bin/relay-model'
    if not executable.is_file():
        raise RuntimeError('model executable missing after build')
    result = {'schema': translation['schema'], 'translation_verified': False,
              'source_hashes': sources, 'ast_sha256': translation['ast_sha256'],
              'executable_sha256': sha(executable), 'executable': str(executable),
              'staged_c_source': str(work / 'relay.c'),
              'toolchain': subprocess.check_output([lake, 'env', 'lean', '--version'],cwd=work,env=env,text=True,timeout=10).strip(),
              'limits': {'parallel_builds': 1, 'lean_threads': 1, 'thread_stack_kib': 16384, 'command_address_space_bytes': 3221225472, 'command_wall_seconds': 120},
              'measurements': measurements,
              'scope': 'Reviewed model proofs; restricted C translation, native runtime and shell semantics unverified.'}
    out = args.out or cache / 'check_result.json'
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'result': str(out), 'executable': str(executable), 'staged_c_source': str(work/'relay.c'),
                      'measurements': {n:{k:v for k,v in m.items() if k!='axioms'} for n,m in measurements.items()}},indent=2))


if __name__ == '__main__':
    main()
