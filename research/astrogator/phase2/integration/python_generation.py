#!/usr/bin/env python3
"""Python-test baseline: no reference, oracle, candidate code or labels in prompt."""
import argparse
import json
from pathlib import Path
import frontier as f

HERE=Path(__file__).resolve().parent
OUT=HERE/'frontier-python'
SYSTEM='''Write a standalone Python 3 post-execution test for the given Ansible task.
It runs as root on Debian after ONE playbook execution in a fresh stated initial
state. ASTRO_SCENARIO is baseline or adversarial. Output Python code only.
Use standard-library imports from os, stat, pathlib, pwd, grp, json, unittest,
subprocess, sys. Use assertions; exit zero iff the requested final state holds.
The test must be read-only: no writes, chmod, account changes, exec/eval/compile,
network, package installs, shell, or playbook execution. If needed, subprocess
calls must use a literal argv list starting with pgrep, dpkg-query, getent, stat,
or id. Do not inspect playbook source. Check observable state, not inferred
success. Do not demand unspecified behavior. You receive neither reference
code nor an oracle. Check each stated scenario according to the request.'''

def prepare():
    base_path=HERE/'frontier/frozen-inputs.json';base=json.loads(base_path.read_text())
    tasks=[]
    for t in base['tasks']:
        if t['mode']!='checks': continue
        tasks.append({'id':t['id'].replace('checks-','python-'),'mode':'python','task_id':t['task_id'],'repeat':t['repeat'],
                      'messages':[{'role':'system','content':SYSTEM},t['messages'][-1]]})
    cfg={'version':1,'models':f.MODELS,'tasks':tasks,'base_frozen_sha256':f.sha(base_path.read_bytes()),
         'source_sha256':{p.name:f.sha(p.read_bytes()) for p in [Path(__file__),Path(f.__file__)]},
         'design':'Two task-level Python tests/model/task; read-only contract screen and known-good reference gate; no candidate, reference, oracle or outcome supplied. Separate from restricted declarative-check baseline.'}
    dest=OUT/'frozen-inputs.json'
    if dest.exists(): assert json.loads(dest.read_text())==cfg
    else:f.save(dest,cfg)

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('mode',choices=['prepare','run']);ap.add_argument('--workers',type=int,default=4);a=ap.parse_args()
    if a.mode=='prepare':prepare()
    else:
        f.OUT=OUT;f.run(argparse.Namespace(models=list(f.MODELS),modes=['python'],workers=a.workers))
