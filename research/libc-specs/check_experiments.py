#!/usr/bin/env python3
"""Replay reviewed experiments, keeping every build/cache/log outside the source tree."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parent
TOOLCHAIN = 'leanprover/lean4:v4.31.0'
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--only', choices=['bytes', 'memory', 'all'], default='all')
    ap.add_argument('--cache', type=Path, default=Path.home() / '.cache/bash-spec-pilot/libc-experiments')
    ap.add_argument('--out', type=Path)
    args = ap.parse_args()
    cache = args.cache.expanduser().resolve()
    repo = ROOT.parents[1]
    if cache == repo or repo in cache.parents:
        ap.error('build cache must be outside the repository')
    cache.mkdir(parents=True, exist_ok=True)
    timer = shutil.which('gtime') or '/usr/bin/time'
    lean = shutil.which('lean') or str(Path.home() / '.elan/bin/lean')
    lake = shutil.which('lake') or str(Path.home() / '.elan/bin/lake')
    env = dict(os.environ, LEAN_NUM_THREADS='1')
    result = {'scope': 'reviewed mathematical models; no C compiler or kernel conformance proof',
              'lean_version': subprocess.check_output([lean, '+' + TOOLCHAIN, '--version'], text=True).strip(),
              'measurements': {}, 'sources': {}}

    def stage(src, dst):
        result['sources'][str(src.relative_to(ROOT))] = sha(src)
        if not dst.exists() or src.read_bytes() != dst.read_bytes():
            shutil.copy2(src, dst)

    def checked(name, cmd, cwd, expected):
        log, timing = cache / (name + '.log'), cache / (name + '.time.json')
        started = time.monotonic()
        with log.open('w') as f:
            p = subprocess.run([timer, '-o', str(timing), '-f',
                                '{"elapsed_seconds":%e,"peak_rss_kb":%M}', *cmd],
                               cwd=cwd, env=env, stdout=f, stderr=subprocess.STDOUT)
        text = log.read_text()
        if p.returncode or 'sorryAx' in text or 'declaration uses `sorry`' in text:
            raise RuntimeError(f'{name} failed; inspect {log}')
        reports = {}
        for match in re.finditer(r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)", text):
            axioms = {x.strip() for x in (match[2] or '').split(',') if x.strip()}
            if not axioms <= ALLOWED:
                raise RuntimeError(f'{match[1]} has unexpected axioms {axioms}')
            reports[match[1]] = sorted(axioms)
        if expected is not None and set(reports) != set(expected):
            raise RuntimeError(f'{name}: missing/unexpected axiom reports; inspect {log}')
        result['measurements'][name] = dict(json.loads(timing.read_text()),
            driver_elapsed_seconds=round(time.monotonic() - started, 3), exit_code=p.returncode,
            axioms=reports)

    if args.only in ('bytes', 'all'):
        work = cache / 'bytes'
        work.mkdir(exist_ok=True)
        for name in ('RawWc.lean', 'Main.lean', 'lakefile.toml', 'lean-toolchain'):
            stage(ROOT / 'byte-experiment' / name, work / name)
        stage(ROOT / 'example/WcFromC.lean', work / 'WcFromC.lean')
        # Build may reuse cache and replay old diagnostics. A separate lean invocation below
        # always elaborates the current module and checks the actual theorem dependencies.
        checked('byte_build', [lake, 'build'], work, None)
        expected = re.findall(r'^#print axioms (\w+)', (work / 'RawWc.lean').read_text(), re.M)
        checked('byte_kernel', [lake, 'env', 'lean', 'RawWc.lean'], work,
                ['RawWc.' + n for n in expected])
        result['byte_executable'] = str(work / '.lake/build/bin/rawwc')
    if args.only in ('memory', 'all'):
        work = cache / 'memory'
        work.mkdir(exist_ok=True)
        env['LEAN_PATH'] = str(work)
        for name in ('MemoryTransfer', 'CounterRefinement', 'MemoryCounterComposition'):
            src = ROOT / 'memory-experiment' / (name + '.lean')
            if not src.exists():
                raise FileNotFoundError(f'required experiment module is missing: {src}')
            stage(src, work / src.name)
            expected = re.findall(r'^#print axioms (\S+)', src.read_text(), re.M)
            # Sources print fully qualified names or names from inside their namespace.
            expected = [n if '.' in n else name + '.' + n for n in expected]
            checked(name, [lean, '+' + TOOLCHAIN, '-o', name + '.olean', src.name], work, expected)
    out = args.out or cache / 'check_result.json'
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'result': str(out), 'measurements': {
        n: {k: v for k, v in m.items() if k != 'axioms'} for n, m in result['measurements'].items()},
        'byte_executable': result.get('byte_executable')}, indent=2))


if __name__ == '__main__':
    main()
