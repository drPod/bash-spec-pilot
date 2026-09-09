#!/usr/bin/env python3
"""Replay phase3 serially: Lean, independent C traces, Lean trace comparison, Bash.

No network or dependency installation is performed. Lean4.31.0, Python3, GCC,
GNU time, prlimit, timeout, nm, Bash and cat must already be available locally.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--tier', choices=['quick', 'standard'], default='standard')
    ap.add_argument('--out', type=Path, default=Path.home()/'.cache/bash-spec-pilot/phase3-replay')
    args = ap.parse_args()
    out = args.out.expanduser().resolve()
    repo = ROOT.parents[2]
    if out == repo or repo in out.parents:
        ap.error('output must stay outside the source repository')
    out.mkdir(parents=True, exist_ok=True)
    lock = (Path.home()/'.cache/bash-spec-pilot/phase3-replay.lock').open('a')
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE='1', LEAN_NUM_THREADS='1',
               LEAN_STACK_SIZE_KB='16384')
    start = time.monotonic()
    hashes = {str(p.relative_to(repo)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in sorted(ROOT.rglob('*')) if p.is_file() and '__pycache__' not in p.parts
              and p != ROOT/'results.json'
              and p.suffix in {'.lean', '.py', '.c', '.json', '.toml'}}
    result = dict(passed=False, tier=args.tier, source_hashes=hashes, groups={})

    def limit(kind, value):
        hard = resource.getrlimit(kind)[1]
        n = value if hard == resource.RLIM_INFINITY else min(value, hard)
        return f'{n}:{n}'

    def command(name, seconds, cmd):
        log = out/(name+'.log')
        timing = out/(name+'.time')
        with log.open('w') as stream:
            cp = subprocess.run(['/usr/bin/time', '-f', 'MEASURE %e %M', '-o', str(timing),
                'timeout', '--kill-after=3s', str(seconds)+'s', 'prlimit',
                '--as='+limit(resource.RLIMIT_AS, 3221225472),
                '--cpu='+limit(resource.RLIMIT_CPU, 900), '--core=0:0',
                '--fsize='+limit(resource.RLIMIT_FSIZE, 268435456), '--', *cmd],
                cwd=repo, env=env, stdout=stream, stderr=subprocess.STDOUT, timeout=seconds+8)
        match = re.search(r'MEASURE ([0-9.]+) ([0-9]+)', timing.read_text())
        result['groups'][name] = dict(command=cmd, status=cp.returncode,
            seconds=float(match[1]) if match else None, peak_rss_kib=int(match[2]) if match else None)
        print(name, 'PASS' if cp.returncode == 0 else 'FAIL', flush=True)
        if cp.returncode:
            raise RuntimeError(name+' failed; inspect '+str(log))

    try:
        command('proof', 180, [sys.executable, '-B', str(ROOT/'check.py'), '--cache', str(out/'proof')])
        proof = json.loads((out/'proof/result.json').read_text())
        if not proof['passed']:
            raise RuntimeError('proof record is not PASS')
        model = proof['executable']
        command('c_validation', 300, [sys.executable, '-B', str(ROOT/'validation/validate_pointer.py'),
            '--mode', 'full', '--tier', args.tier, '--budget-seconds', '240', '--out', str(out/'c-validation')])
        c = json.loads((out/'c-validation/results.json').read_text())
        command('lean_validation', 180, [sys.executable, '-B', str(ROOT/'compare_lean.py'),
            '--model', model, '--tier', args.tier, '--out', str(out/'lean-validation')])
        lean = json.loads((out/'lean-validation/results.json').read_text())
        command('shell_contexts', 120, [sys.executable, '-B', str(ROOT/'shell_contexts.py'),
            '--out', str(out/'shell-contexts')])
        shell = json.loads((out/'shell-contexts/results.json').read_text())
        if c['overall'] != 'PASS' or not lean['passed'] or not shell['passed']:
            raise RuntimeError('a result record is not PASS')
        if c['corpus']['sha256'] != lean['corpus_sha256']:
            raise RuntimeError('C/Lean corpus identities differ')
        if c['source']['sha256'] != shell['source_hashes']['relay.c']:
            raise RuntimeError('C source identities differ')
        if proof['executable_sha256'] != lean['executable_sha256']:
            raise RuntimeError('Lean executable identities differ')
        for name, digest in hashes.items():
            if hashlib.sha256((repo/name).read_bytes()).hexdigest() != digest:
                raise RuntimeError('source changed during replay: '+name)
        result.update(passed=True, elapsed_seconds=time.monotonic()-start,
            declarations=len(proof['axioms']), cases=lean['count'], shell_cases=shell['count'],
            corpus_sha256=lean['corpus_sha256'], c_sha256=c['source']['sha256'],
            executable_sha256=proof['executable_sha256'],
            scope='Checked Lean layers and finite C/Bash evidence; C lowering and real Bash semantics unverified.')
    finally:
        (out/'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {'groups','source_hashes'}}), flush=True)


if __name__ == '__main__':
    main()
