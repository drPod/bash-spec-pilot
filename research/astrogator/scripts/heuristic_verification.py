#!/usr/bin/env python3
"""Explicit configured heuristic arm using pinned upstream metadata.

This is not claimed to reproduce the paper's unpublished command line.
"""
import ast
import hashlib
import json
from pathlib import Path
import tempfile
from upstream_eval import BIN, MODULES, UP, ROOT, call


def main():
    tree = ast.parse((UP / 'astrogator-eval/verifier.py').read_text())
    config = next(ast.literal_eval(n.value) for n in tree.body
                  if isinstance(n, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'problems' for t in n.targets))
    tasks = dict(config)
    originals = {b['id']: b for b in json.loads((ROOT / 'benchmarks/original.json').read_text())}
    for sample in map(json.loads, (ROOT / 'data/manifest.jsonl').read_text().splitlines()):
        b = originals[sample['task_id']]
        row = {'sample_id': sample['sample_id'], 'task_id': b['id'],
               'arm': 'users,groups,packages,files(non-strict),reboot,writes; pinned upstream metadata'}
        response = sample['artifacts'].get('response')
        if response is None: row['status'] = 'missing_processed'
        else:
            users, groups, files, hosts = tasks[b['legacy_id'][1:]]
            paths = [UP / 'heuristics' / name for name in (users, groups, 'packages.txt', files)]
            flags = [item for flag, path in zip(('--users', '--groups', '--pkgs', '--files'), paths)
                     for item in (flag, str(path))] + ['--reboot', hosts, '--writes', hosts]
            row.update(heuristic_flags=flags, heuristic_sha256={str(p.relative_to(UP)):
                       hashlib.sha256(p.read_bytes()).hexdigest() for p in paths})
            query = b['formal_query'].replace('http://example.com/', 'http://acc240.com/') if b['legacy_id'] == 'p17' else b['formal_query']
            code = ROOT / response['path']
            if hashlib.sha256(code.read_bytes()).hexdigest() != response['sha256']:
                raise RuntimeError('Candidate bytes changed')
            with tempfile.NamedTemporaryFile(mode='w', suffix='.fql') as f:
                f.write(query); f.flush()
                r = call([str(BIN / 'verify.exe'), *flags, f.name, str(code), '--', *MODULES])
            row.update(r, code_sha256=response['sha256'], query_sha256=hashlib.sha256(query.encode()).hexdigest(),
                       status={0:'accepted_with_possible_residuals',1:'module_parse_error',2:'module_lowering_error',
                               3:'query_lowering_error',4:'ansible_lowering_error',5:'verification_rejected',
                               6:'trivial_query',7:'heuristic_rejected',None:'timeout'}.get(r['returncode'],'exception'))
            if 'Fatal error: exception' in r['stderr']: row['status'] = 'uncaught_exception'
        print(json.dumps(row), flush=True)


if __name__ == '__main__': main()
