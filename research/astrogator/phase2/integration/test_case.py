#!/usr/bin/env python3
"""Evaluate all eligible generated check sets against ONE common execution.

Runs only in lab Docker. No generated code runs on the host. Tests execute before
the independent oracle. Original and strengthened password labels both retained.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time
sys.path.insert(0,'/suite/scripts')
import container_case as c
from generated_checks import evaluate
sys.path.insert(0,'/suite/phase2/evaluation')
from revised_case import HASH, password_matches, observe

assert Path('/.dockerenv').exists() and Path('/opt/astrogator-lab-marker').exists()
task,scenario,candidate,checks_json=sys.argv[1:]
specs=json.loads(checks_json)
result={'task_id':task,'scenario':scenario,'candidate_sha256':hashlib.sha256(Path(candidate).read_bytes()).hexdigest(),
        'status':'fixture_error','generated_tests':{}}
started=time.monotonic()
try:
    d=Path('/suite/benchmarks/original-pilot')/task
    Path('/work').mkdir(exist_ok=True); Path('/fixtures').mkdir(exist_ok=True)
    env=dict(vars(c),adversarial=scenario=='adversarial')
    if task=='a17':
        assert password_matches(HASH)
        c.run('useradd','-m','service'); c.run('usermod','-p',('!' if scenario=='adversarial' else '')+HASH,'service')
        result['before']=observe(task,scenario)
        assert result['before']['fixture_password_still_matches']==(scenario=='baseline')
    else: exec(compile((d/'setup.py').read_text(),str(d/'setup.py'),'exec'),env)
    p=subprocess.run(['ansible-playbook','-i','localhost,','-c','local','-e','ansible_python_interpreter=/usr/bin/python3',candidate],
        capture_output=True,text=True,timeout=45,env={**os.environ,'ANSIBLE_NOCOLOR':'1','ANSIBLE_LOCAL_TEMP':'/tmp/ansible-local'})
    result['execution']={'returncode':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
    result['status']='execution_error' if p.returncode else 'observed'
    if p.returncode==0:
        for key,path in specs.items():
            try: result['generated_tests'][key]={'status':'evaluated',**evaluate(json.loads(Path(path).read_text()),scenario)}
            except Exception as e: result['generated_tests'][key]={'status':'test_error','error':repr(e)}
        try:
            exec(compile((d/'check.py').read_text(),str(d/'check.py'),'exec'),env)
            result['original_oracle']=True
        except Exception as e: result.update(original_oracle=False,original_oracle_error=repr(e))
        if task in ['a06','a17']: result['observations']=observe(task,scenario)
except subprocess.TimeoutExpired: result['status']='execution_timeout'
except Exception as e: result['error']=repr(e)
result['seconds']=round(time.monotonic()-started,3)
print(json.dumps(result))
