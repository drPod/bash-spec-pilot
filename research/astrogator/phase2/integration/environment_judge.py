#!/usr/bin/env python3
"""Matched environment-information sensitivity on the frozen 86-program slice."""
import argparse
import copy
import json
from pathlib import Path
import frontier as f

HERE=Path(__file__).resolve().parent
OUT=HERE/'environment-judge'
FACTS='''Additional execution context for this assessment:
Debian 13; Ansible-core 2.19.11; root execution inside a disposable container.
The inventory is exactly localhost, and connection is local. Invocation is
ansible-playbook -i localhost, -c local -e ansible_python_interpreter=/usr/bin/python3 PLAYBOOK.
External networking is disabled. Only Ansible built-ins and the internal
ansible._protomatter collection are installed; no community collections are installed.
The supplied baseline and adversarial states each receive one fresh execution.
Judge whether the request succeeds in this stated environment. Do not silently
substitute another Ansible version, inventory, installed collection, or network.
No execution outcomes, reference solutions, or oracle implementation are provided.'''

def prepare():
    path=HERE/'frontier/frozen-inputs.json';base=json.loads(path.read_text()); tasks=[]
    for t in base['tasks']:
        if t['mode']!='judge':continue
        row=copy.deepcopy(t);row['messages'][0]['content']+='\n\n'+FACTS
        assert row['messages'][1:]==t['messages'][1:]
        row['arm']='environment_information';tasks.append(row)
    cfg={'version':1,'models':f.MODELS,'tasks':tasks,'base_frozen_input_sha256':f.sha(path.read_bytes()),
         'facts':FACTS,'source_sha256':{str(p.relative_to(f.ROOT)):f.sha(p.read_bytes()) for p in [Path(__file__),Path(f.__file__),f.ROOT/'reports/environment.json',f.ROOT/'scripts/container_case.py']},
         'design':'Same preselected86programs, same code/request/states; append execution facts only to system instructions. One fresh call/model/program. Outcome-informed methodology refinement, not preregistered confirmatory evidence; no outcome labels sent to models.'}
    dest=OUT/'frozen-inputs.json'
    if dest.exists():assert json.loads(dest.read_text())==cfg
    else:f.save(dest,cfg)

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('mode',choices=['prepare','run']);ap.add_argument('--workers',type=int,default=4);a=ap.parse_args()
    if a.mode=='prepare':prepare()
    else:
        f.OUT=OUT;f.run(argparse.Namespace(models=list(f.MODELS),modes=['judge'],workers=a.workers))
