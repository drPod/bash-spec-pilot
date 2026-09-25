#!/usr/bin/env python3
"""Recover each container harness failure once, retaining primary attempts.

No execution_error, oracle rejection, generated-test rejection or in-container
execution timeout is retried. A second harness failure stays unresolved.
"""
import os
os.environ["GOMAXPROCS"] = "2"

import argparse
import importlib
import json
from pathlib import Path
import subprocess
from orchestration import wait_success
import time
from frontier import ROOT, save, sha

HERE=Path(__file__).resolve().parent

def finish(kind):
    is_python=kind=='python'
    module=importlib.import_module('run_python_tests' if is_python else 'run_tests')
    dest=module.DEST
    cfg=json.loads((dest/'frozen.json').read_text());gates=json.loads((dest/'gates.json').read_text())
    rows={r['sample_id']:r for r in map(json.loads,(ROOT/'data/manifest.jsonl').read_text().splitlines())}
    attempts=[]
    for path in sorted((dest/'cases').glob('*.json')):
        r=json.loads(path.read_text())
        if r['status']!='harness_error':continue
        archive=dest/'infrastructure-attempts'/path.name
        if archive.exists():continue
        archive.parent.mkdir(parents=True,exist_ok=True);path.rename(archive)
        row=rows[r['sample_id']]
        specs={k:'/suite/'+str((dest/'specifications'/(k+('.py' if is_python else '.json'))).relative_to(ROOT))
               for k,g in gates.items() if g['task_id']==r['task_id'] and g['eligible']}
        result=module.execute(r['sample_id'],r['task_id'],r['scenario'],ROOT/row['artifacts']['response']['path'],specs,cfg['image_id'])
        result['infrastructure_retry_of_sha256']=sha(archive.read_bytes());save(path,result)
        attempts.append({'sample_id':r['sample_id'],'scenario':r['scenario'],'original_sha256':sha(archive.read_bytes()),'retry_status':result['status']})
    if attempts:save(dest/'infrastructure-retry.json',{'policy':__doc__,'attempts':attempts,'source_sha256':sha(Path(__file__).read_bytes())})
    import summarize_tests
    summarize_tests.DEST=dest;summarize_tests.main()

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('kind',choices=['declarative','python']);p.add_argument('--wait-unit');a=p.parse_args()
    if a.wait_unit:
        wait_success(a.wait_unit)
    finish(a.kind)
