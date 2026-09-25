#!/usr/bin/env python3
"""Causal metadata-scope ablation; verifier/query logic and OS branches unchanged.

Run inside the lab image. Restrict only heuristic metadata to Debian rows.
This is not a Debian-only verifier or a reconstruction of container facts.
"""
import ast
import hashlib
import json
from pathlib import Path
import sys
import tempfile
sys.path.insert(0,'/suite/scripts')
from upstream_eval import BIN, MODULES, UP, ROOT, call


def main():
    assert Path('/.dockerenv').exists()
    tree=ast.parse((UP/'astrogator-eval/verifier.py').read_text())
    config=dict(next(ast.literal_eval(n.value) for n in tree.body if isinstance(n,ast.Assign)
                     and any(isinstance(v,ast.Name) and v.id=='problems' for v in n.targets)))
    originals={b['id']:b for b in json.loads((ROOT/'benchmarks/original.json').read_text())}
    for s in map(json.loads,(ROOT/'data/manifest.jsonl').read_text().splitlines()):
        if s['task_id'] not in ('a01','a02','a06','a17'):continue
        if 'response' not in s['artifacts']:continue
        b=originals[s['task_id']]; users,groups,files,hosts=config[b['legacy_id'][1:]]
        metadata={}
        for name in (users,groups,'packages.txt',files):
            source=(UP/'heuristics'/name).read_text()
            kept=[l for l in source.splitlines() if l.startswith('Debian:')]
            assert kept or not source.strip(), (name,source)
            metadata[name]={'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'restricted_text':'\n'.join(kept)+'\n' if kept else source}
        with tempfile.TemporaryDirectory() as td:
            td=Path(td)
            for name,meta in metadata.items():(td/name).write_text(meta['restricted_text'])
            q=td/'query.fql';q.write_text(b['formal_query'])
            code=ROOT/s['artifacts']['response']['path']; assert hashlib.sha256(code.read_bytes()).hexdigest()==s['artifacts']['response']['sha256']
            flags=[v for flag,name in zip(('--users','--groups','--pkgs','--files'),(users,groups,'packages.txt',files)) for v in (flag,str(td/name))]
            flags+=['--reboot',hosts,'--writes',hosts]
            r=call([str(BIN/'verify.exe'),*flags,str(q),str(code),'--',*MODULES])
        status={0:'accepted_with_possible_residuals',4:'ansible_lowering_error',5:'verification_rejected',7:'heuristic_rejected'}.get(r['returncode'],'other_error')
        print(json.dumps({'sample_id':s['sample_id'],'task_id':s['task_id'],'code_sha256':s['artifacts']['response']['sha256'],
                          'query_sha256':hashlib.sha256(b['formal_query'].encode()).hexdigest(),'status':status,
                          'metadata':metadata,'reboot_hosts':hosts,'writes_hosts':hosts,
                          'scope':'Only heuristic metadata filtered to Debian; verifier OS branches unchanged.',**r}),flush=True)


if __name__=='__main__':main()
