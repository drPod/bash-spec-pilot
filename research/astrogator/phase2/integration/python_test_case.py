#!/usr/bin/env python3
"""Evaluate read-only Python tests against ONE common execution.

Runs only in lab Docker. No generated code runs on the host. Independent
observations are captured before tests, preventing test-induced relabeling.
Relevant-state snapshots detect mutation; this is not a general security
proof of read-only Python. Original and strengthened password labels are retained.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import stat
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

def measured_state():
    paths={'a01':'/srv/www','a02':'/home/mydata/web','a06':'/etc/file.txt','a17':'/home/service'}
    out={}
    def visit(p):
        key=str(p)
        if not os.path.lexists(p):out[key]={'exists':False};return
        s=p.lstat(); row={'mode':s.st_mode,'uid':s.st_uid,'gid':s.st_gid,'inode':s.st_ino,
                         'mtime_ns':s.st_mtime_ns,'ctime_ns':s.st_ctime_ns}
        if stat.S_ISLNK(s.st_mode):row.update(link=os.readlink(p),target_exists=p.exists(),target_is_dir=p.is_dir())
        elif stat.S_ISREG(s.st_mode):
            with p.open('rb') as f:row['sha256']=hashlib.file_digest(f,'sha256').hexdigest()
        out[key]=row
        if stat.S_ISDIR(s.st_mode):
            for child in sorted(p.iterdir()):visit(child)
    for path in ['/etc/passwd','/etc/shadow',paths[task]]:visit(Path(path))
    return out

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
        # Gold observations are never sent to generated tests. Take them first
        # so a faulty test cannot change the execution's correctness label.
        try:
            exec(compile((d/'check.py').read_text(),str(d/'check.py'),'exec'),env)
            result['original_oracle']=True
        except Exception as e: result.update(original_oracle=False,original_oracle_error=repr(e))
        if task in ['a06','a17']: result['observations']=observe(task,scenario)
        before=measured_state();result['state_before_tests']=before
        contaminated=False
        for key,path in specs.items():
            if contaminated:
                result['generated_tests'][key]={'status':'contaminated_state_abstention'};continue
            try: result['generated_tests'][key]=c.generated_test(path,scenario)
            except Exception as e: result['generated_tests'][key]={'status':'test_error','error':repr(e)}
            after=measured_state()
            if before!=after:
                result['generated_tests'][key]={'status':'state_mutation_invalid','raw_test_result':result['generated_tests'][key]}
                contaminated=True
            result['generated_tests'][key]['measured_state_unchanged']=before==after
        result['measured_state_contaminated']=contaminated
except subprocess.TimeoutExpired: result['status']='execution_timeout'
except Exception as e: result['error']=repr(e)
result['seconds']=round(time.monotonic()-started,3)
print(json.dumps(result))
