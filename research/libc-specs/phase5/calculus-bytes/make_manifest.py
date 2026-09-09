#!/usr/bin/env python3
"""Write results/manifest.json: sha256 of every artifact in this directory and the
run_vst receipts of the calculus-bytes container runs (exit status, elapsed, peak RSS)."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
RUNS = Path.home() / 'agent-jobs/astra-research/phase5/runs'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    files = sorted(p for p in HERE.rglob('*') if p.is_file() and p.name != 'manifest.json')
    receipts = {}
    names = sorted(set(RUNS.glob('calculus-bytes-*.json')) | set(RUNS.glob('calculus-resume*-*.json')))
    for r in names:
        d = json.loads(r.read_text())
        receipts[r.stem] = dict(exit_status=d['exit_status'], elapsed_seconds=d['elapsed_seconds'],
                                peak_rss_kib=d['peak_rss_kib'], command=' '.join(d['command'])[:200])
    out = dict(files={str(p.relative_to(HERE)): sha(p) for p in files}, receipts=receipts,
               note='Hashes identify artifacts; receipts record commands, not verification claims.')
    (HERE / 'results' / 'manifest.json').write_text(json.dumps(out, indent=1) + '\n')
    print(len(files), 'files,', len(receipts), 'receipts')


if __name__ == '__main__':
    main()
