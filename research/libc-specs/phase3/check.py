#!/usr/bin/env python3
"""Serial, measured phase3 kernel/build checks. All generated files stay local."""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parent
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bounded(kind, requested):
    hard = resource.getrlimit(kind)[1]
    value = requested if hard == resource.RLIM_INFINITY else min(requested, hard)
    return f'{value}:{value}'


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cache', type=Path, default=Path.home()/'.cache/bash-spec-pilot/phase3-check')
    args = ap.parse_args()
    cache = args.cache.expanduser().resolve()
    repo = ROOT.parents[2]
    if cache == repo or repo in cache.parents:
        ap.error('cache must stay outside Coding source repository')
    cache.mkdir(parents=True, exist_ok=True)
    lockpath = Path.home()/'.cache/bash-spec-pilot/phase3-compiler.lock'
    lockpath.parent.mkdir(parents=True, exist_ok=True)
    lock = lockpath.open('a')
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    work = cache/'lean'
    work.mkdir(exist_ok=True)
    inputs = [ROOT.parent/'memory-experiment/MemoryTransfer.lean',
              ROOT.parent/'phase2/BufferRelay.lean']
    inputs += [ROOT/n for n in ['PointerCore.lean', 'PointerRelay.lean', 'PointerAxioms.lean',
        'ShellObservation.lean', 'ShellAxioms.lean', 'RelayComposition.lean',
        'CompositionAxioms.lean', 'TraceMain.lean',
        'lakefile.toml', 'lean-toolchain']]
    source_hashes = {}
    for src in inputs:
        source_hashes[str(src.relative_to(repo))] = sha(src)
        target = work/src.name
        if not target.exists() or target.read_bytes() != src.read_bytes():
            shutil.copy2(src, target)
    env = dict(os.environ, LEAN_NUM_THREADS='1', LEAN_STACK_SIZE_KB='16384',
               PYTHONDONTWRITEBYTECODE='1')
    lake = shutil.which('lake') or str(Path.home()/'.elan/bin/lake')
    result = dict(passed=False, source_hashes=source_hashes, commands=[], axioms={},
                  limits=dict(builds=1, address_space_bytes=3221225472,
                              cpu_seconds=120, wall_seconds=120, stack_kib=16384))
    start = time.monotonic()

    def command(name, argv, expected=None):
        log = cache/(name+'.log')
        timing = cache/(name+'.time')
        with log.open('w') as stream:
            cp = subprocess.run(['/usr/bin/time', '-f', 'MEASURE %e %M', '-o', str(timing),
                'timeout', '--kill-after=2s', '120s', 'prlimit',
                '--as='+bounded(resource.RLIMIT_AS, 3221225472),
                '--cpu='+bounded(resource.RLIMIT_CPU, 120), '--core=0:0',
                '--fsize='+bounded(resource.RLIMIT_FSIZE, 67108864), '--', *argv],
                cwd=work, env=env, stdout=stream, stderr=subprocess.STDOUT, timeout=125)
        text = log.read_text()
        measure = re.search(r'MEASURE ([0-9.]+) ([0-9]+)', timing.read_text())
        record = dict(name=name, command=argv, status=cp.returncode,
                      elapsed_seconds=float(measure[1]) if measure else None,
                      peak_rss_kib=int(measure[2]) if measure else None)
        result['commands'].append(record)
        if cp.returncode or 'sorryAx' in text or re.search(r'declaration uses .sorry.', text):
            raise RuntimeError(f'{name} failed; see {log}')
        reports = {}
        for m in re.finditer(r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)", text):
            axioms = {a.strip() for a in (m[2] or '').split(',') if a.strip()}
            if not axioms <= ALLOWED:
                raise RuntimeError('unexpected axioms for '+m[1]+': '+repr(axioms))
            reports[m[1]] = sorted(axioms)
        if expected is not None and set(expected) != set(reports):
            raise RuntimeError(f'{name} exact axiom manifest mismatch: {log}')
        if expected is not None:
            result['axioms'].update(reports)

    try:
        for module in ['MemoryTransfer', 'BufferRelay', 'PointerCore', 'PointerRelay', 'ShellObservation',
                       'RelayComposition', 'TraceMain']:
            command('build_'+module+'_lean', [lake, 'build', '+'+module+':olean'])
            command('build_'+module+'_c', [lake, 'build', '+'+module+':c.o'])
        command('link', [lake, 'build'])
        for filename in ['PointerAxioms.lean', 'ShellAxioms.lean', 'CompositionAxioms.lean']:
            expected = re.findall(r'^#print axioms (\S+)', (work/filename).read_text(), re.M)
            if not expected or len(set(expected)) != len(expected):
                raise RuntimeError('empty or duplicate manifest '+filename)
            command(filename[:-5], [lake, 'env', 'lean', '-j1', '-s16384',
                                     '-DwarningAsError=true', filename], expected)
        exe = work/'.lake/build/bin/pointer-trace'
        result.update(passed=True, executable=str(exe), executable_sha256=sha(exe),
            elapsed_seconds=time.monotonic()-start,
            scope='Lean-to-Lean refinement only; C parsing/lowering, host IO and Bash unverified.')
    finally:
        (cache/'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(passed=True, declarations=len(result['axioms']),
                          elapsed_seconds=result['elapsed_seconds'], result=str(cache/'result.json'))))


if __name__ == '__main__':
    main()
