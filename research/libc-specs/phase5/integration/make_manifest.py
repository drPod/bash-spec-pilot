#!/usr/bin/env python3
"""Write results/manifest.json: hashes of every artifact in this directory plus the run
receipts referenced by README.md. Receipts live outside the repository
(~/agent-jobs/astra-research/phase5/runs); their hashes are recorded here so a reviewer can
check that the copied JSON lines match the container logs. This script proves nothing.
"""
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
RUNS = Path.home() / 'agent-jobs/astra-research/phase5/runs'
RECEIPTS = ['integration-dune-build-6', 'integration-dune-build-7', 'integration-fixtures-parse-2',
            'integration-fixtures-reparse-1', 'integration-fixtures-semant-2',
            'integration-fixtures-interp-1']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    files = sorted(p for p in HERE.rglob('*') if p.is_file() and p.name != 'manifest.json'
                   and '__pycache__' not in p.parts)
    receipts = {}
    for name in RECEIPTS:
        rec = RUNS / (name + '.json')
        log = RUNS / (name + '.log')
        if rec.exists():
            data = json.loads(rec.read_text())
            receipts[name] = {'receipt_sha256': sha(rec), 'log_sha256': sha(log),
                              'exit_status': data['exit_status'],
                              'elapsed_seconds': data['elapsed_seconds'],
                              'peak_rss_kib': data['peak_rss_kib']}
        else:
            receipts[name] = 'missing'
    upstream = {
        'repository': 'https://github.com/counc009/state_based', 'branch': 'bash',
        'commit': '190dd8491b258d8a0ee29f79629908540236b332',
        'tree': '292a37c9848e8f9a1cc679a8c3f1e28dfcffd116',
        'stdint_tarball_sha256': '1560198d8bc9c7af3ea952c40dabe82666694210ecc3fdf9bbfeb43211e977e6',
    }
    manifest = {
        'generated_by': 'make_manifest.py',
        'git_head': subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=HERE, capture_output=True,
                                   text=True).stdout.strip(),
        'upstream': upstream,
        'files': {str(p.relative_to(HERE)): sha(p) for p in files},
        'container_receipts': receipts,
        'scope': 'Identity and replay record only; see README.md for what each result establishes.',
    }
    out = HERE / 'results/manifest.json'
    out.write_text(json.dumps(manifest, indent=2) + '\n')
    print(out)


if __name__ == '__main__':
    main()
