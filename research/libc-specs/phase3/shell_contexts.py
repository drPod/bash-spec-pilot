#!/usr/bin/env python3
"""Bash witnesses distinguishing byte-equivalent relay runs by exit status; not a Bash/libc proof."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import resource
import shutil
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parent
PHASE2 = ROOT.parent / 'phase2'
SCENARIOS = [
    ('success', b'abc', [3], [], b'abc', 0),
    ('late_read_error', b'abc', [3, -1], [], b'abc', 1),
    ('short_then_zero', b'abcdef', [4], [2, 0], b'ab', 2),
    ('first_read_error', b'abc', [-1], [], b'', 1),
    ('empty_success', b'', [], [], b'', 0),
]
CONTEXTS = {
    'bare': '"$@" 2>/dev/null',
    'and': '"$@" 2>/dev/null && printf "!"',
    'or': '"$@" 2>/dev/null || printf "?"',
    'seq': '"$@" 2>/dev/null; printf "#"',
    'pipe': '"$@" 2>/dev/null | cat',
    'pipefail': 'set -o pipefail; "$@" 2>/dev/null | cat',
}


def expected(context, output, status):
    if context == 'and':
        return output + (b'!' if status == 0 else b''), status
    if context == 'or':
        return output + (b'?' if status != 0 else b''), 0
    if context == 'seq':
        return output + b'#', 0
    return output, 0 if context == 'pipe' else status


def limit(kind, n):
    hard = resource.getrlimit(kind)[1]
    n = n if hard == resource.RLIM_INFINITY else min(n, hard)
    return f'{n}:{n}'


def run(cmd, seconds, stdin=b''):
    # Payloads and expected outputs are tiny; file limits bound accidental output.
    env = dict(os.environ, LC_ALL='C')
    for key in ['BASH_ENV', 'ENV', 'SHELLOPTS', 'BASHOPTS']:
        env.pop(key, None)
    start = time.monotonic()
    with tempfile.TemporaryFile() as stdout, tempfile.TemporaryFile() as stderr:
        result = subprocess.run(['timeout', '--kill-after=2s', str(seconds) + 's',
            'prlimit', '--as=' + limit(resource.RLIMIT_AS, 1073741824),
            '--cpu=' + limit(resource.RLIMIT_CPU, seconds), '--core=0:0',
            '--fsize=' + limit(resource.RLIMIT_FSIZE, 8388608), '--', *cmd],
            input=stdin, stdout=stdout, stderr=stderr,
            env=env, timeout=seconds + 4)
        stdout.seek(0)
        stderr.seek(0)
        result.stdout = stdout.read(8388609)
        result.stderr = stderr.read(8388609)
        if len(result.stdout) > 8388608 or len(result.stderr) > 8388608:
            raise RuntimeError('command capture exceeded limit')
    return result, time.monotonic() - start


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, default=Path.home()/'.cache/bash-spec-pilot/phase3-shell')
    args = ap.parse_args()
    out = args.out.expanduser().resolve()
    repo = ROOT.parents[2]
    if out == repo or repo in out.parents:
        ap.error('output must remain outside the source repository')
    out.mkdir(parents=True, exist_ok=True)
    cc = shutil.which('cc')
    bash = shutil.which('bash')
    if not cc or not bash or not shutil.which('cat'):
        raise RuntimeError('cc, bash and cat required')
    source = PHASE2/'relay.c'
    driver = PHASE2/'validation/driver/relay_driver.c'
    sources = {}
    for src in [source, driver]:
        target = out/src.name
        target.write_bytes(src.read_bytes())
        sources[src.name] = hashlib.sha256(target.read_bytes()).hexdigest()
    flags = ['-std=c11', '-Wall', '-Wextra', '-Werror', '-U_FORTIFY_SOURCE', '-O2']
    commands = [
        [cc, *flags, '-Dread=shim_read', '-Dwrite=shim_write', '-c', str(out/'relay.c'), '-o', str(out/'relay.o')],
        [cc, *flags, '-DRELAY_SHIM_MACRO', '-c', str(out/'relay_driver.c'), '-o', str(out/'driver.o')],
        [cc, str(out/'relay.o'), str(out/'driver.o'), '-o', str(out/'relay-controlled')],
    ]
    builds = []
    for cmd in commands:
        cp, elapsed = run(cmd, 60)
        builds.append(dict(command=cmd, seconds=elapsed, status=cp.returncode,
                           stdout=cp.stdout.decode(), stderr=cp.stderr.decode()))
        if cp.returncode:
            (out/'build.json').write_text(json.dumps(builds, indent=2)+'\n')
            raise RuntimeError('C build failed: '+cp.stderr.decode())
    cases = []
    for name, payload, reads, writes, output, status in SCENARIOS:
        argv = [str(out/'relay-controlled'), '--reads', ','.join(map(str, reads)),
                '--writes', ','.join(map(str, writes))]
        for context, script in CONTEXTS.items():
            eo, es = expected(context, output, status)
            cp, elapsed = run([bash, '--noprofile', '--norc', '-c', script, '--', *argv], 5, payload)
            record = dict(scenario=name, context=context, input_hex=payload.hex(),
                reads=reads, writes=writes, script=script, stdout_hex=cp.stdout.hex(),
                status=cp.returncode, stderr_hex=cp.stderr.hex(), expected_stdout_hex=eo.hex(),
                expected_status=es, seconds=elapsed,
                passed=cp.stdout == eo and cp.returncode == es and cp.stderr == b'')
            cases.append(record)
    version, _ = run([bash, '--version'], 5)
    result = dict(passed=all(c['passed'] for c in cases), cases=cases, count=len(cases),
        source_hashes=sources, builds=builds,
        bash_version=version.stdout.decode().splitlines()[0],
        scope='Empirical Bash contexts over controlled C IO; no shell or C translation proof.')
    (out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(passed=result['passed'], cases=len(cases), result=str(out/'results.json'))))
    if not result['passed']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
