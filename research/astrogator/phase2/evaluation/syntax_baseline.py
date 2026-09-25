#!/usr/bin/env python3
"""Native Ansible syntax-check baseline, same image/candidates as local execution.

Syntax-check pass is an operational baseline decision, NOT semantic correctness.
Run inside a bounded container; reference controls must pass first.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

ROOT=Path('/suite')


def check(sample_id,task_id,path,kind):
    start=time.monotonic()
    row={'sample_id':sample_id,'task_id':task_id,'kind':kind,
         'code_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
         'runner_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    argv=['ansible-playbook','--syntax-check','-i','localhost,','-c','local',
          '-e','ansible_python_interpreter=/usr/bin/python3',str(path)]
    try:
        r=subprocess.run(argv,capture_output=True,text=True,timeout=20,
                         env={**os.environ,'ANSIBLE_NOCOLOR':'1','ANSIBLE_LOCAL_TEMP':'/tmp/ansible-local'})
        row.update(returncode=r.returncode,stdout=r.stdout,stderr=r.stderr,
                   status='syntax_pass' if r.returncode==0 else 'syntax_reject')
    except subprocess.TimeoutExpired:row.update(status='timeout')
    except Exception as e:row.update(status='harness_error',error=repr(e))
    row['seconds']=round(time.monotonic()-start,3)
    return row


def main():
    assert Path('/.dockerenv').exists() and Path('/opt/astrogator-lab-marker').exists()
    for task in ('a01','a02','a06','a17'):
        r=check('reference/'+task,task,ROOT/'benchmarks/original-pilot'/task/'reference.yml','reference')
        print(json.dumps(r),flush=True);assert r['status']=='syntax_pass'
    for s in map(json.loads,(ROOT/'data/manifest.jsonl').read_text().splitlines()):
        if s['task_id'] not in ('a01','a02','a06','a17') or 'response' not in s['artifacts']:continue
        p=ROOT/s['artifacts']['response']['path']
        assert hashlib.sha256(p.read_bytes()).hexdigest()==s['artifacts']['response']['sha256']
        print(json.dumps(check(s['sample_id'],s['task_id'],p,'candidate')),flush=True)


if __name__=='__main__':main()
