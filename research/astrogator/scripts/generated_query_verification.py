#!/usr/bin/env python3
"""Measure verifier outcome changes under generated versus supplied FQL.

No correctness labels are inferred here. Invalid queries remain pipeline failures.
Run in the lab container; stdout is the durable JSONL result stream.
"""
import hashlib
import json
from pathlib import Path
from upstream_eval import verify

ROOT = Path('/suite')
ARM = 'experiments/qwen-grammar-v2-repair/fql-3shot-constrained-repair1'


def main():
    diagnostics = {r['task_id']: r for r in map(json.loads,
        (ROOT / 'reports/fql-translations.jsonl').read_text().splitlines())
        if r['path'].startswith(ARM + '/')}
    if len(diagnostics) != 21: raise RuntimeError('Expected all 21 final query results')
    supplied = {r['sample_id']: r for r in map(json.loads,
        (ROOT / 'reports/corpus-verifier.jsonl').read_text().splitlines())}
    for sample in map(json.loads, (ROOT / 'data/manifest.jsonl').read_text().splitlines()):
        sid = sample['sample_id']; task = sample['task_id']; diagnostic = diagnostics[task]
        file = ROOT / Path(diagnostic['path']).with_suffix('.fql')
        query = file.read_text()
        row = {'sample_id': sid, 'task_id': task, 'query_arm': ARM,
               'query_sha256': hashlib.sha256(query.encode()).hexdigest(),
               'supplied_query_status': supplied[sid]['status'],
               'query_normalization': 'none: use generated query bytes, including generated domains'}
        response = sample['artifacts'].get('response')
        if response is None: row['status'] = 'missing_processed'
        else:
            path = ROOT / response['path']
            if hashlib.sha256(path.read_bytes()).hexdigest() != response['sha256']:
                raise RuntimeError('Candidate bytes changed')
            row['code_sha256'] = response['sha256']
            if diagnostic['result']['returncode'] != 0:
                row.update(status='generated_query_invalid', query_diagnostic=diagnostic['result'])
            else: row.update(verify(query, path))
        print(json.dumps(row), flush=True)


if __name__ == '__main__': main()
