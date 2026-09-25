#!/usr/bin/env python3
"""Trusted fixtures/oracle, executed ONLY inside a disposable lab container."""
import grp
import ast
import hashlib
import io
import json
import os
from pathlib import Path as P
import pwd
import subprocess
import sys
import tarfile
import time


def run(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True)


def output(*args):
    return run(*args).stdout


def put(path, content):
    p=P(path); p.parent.mkdir(parents=True,exist_ok=True); p.write_text(content)


def read(path): return P(path).read_text()
def mode(path): return os.stat(path).st_mode & 0o7777


def user_exists(name):
    try: pwd.getpwnam(name); return True
    except KeyError: return False


def package_version(name):
    r=subprocess.run(['dpkg-query','-W','-f=${db:Status-Status} ${Version}',name],capture_output=True,text=True)
    return r.stdout.split(' ',1)[1] if r.returncode == 0 and r.stdout.startswith('installed ') else None


def git_fixture():
    run('git','init','-b','main','/fixtures/repo')
    run('git','-C','/fixtures/repo','config','user.email','fixture@example.invalid')
    run('git','-C','/fixtures/repo','config','user.name','Fixture')
    put('/fixtures/repo/version','tag-v1')
    run('git','-C','/fixtures/repo','add','version'); run('git','-C','/fixtures/repo','commit','-m','v1')
    run('git','-C','/fixtures/repo','tag','v1')
    put('/fixtures/repo/version','main'); run('git','-C','/fixtures/repo','commit','-am','main')
    run('git','-C','/fixtures/repo','checkout','-b','release')
    put('/fixtures/repo/version','release'); run('git','-C','/fixtures/repo','commit','-am','release')
    run('git','-C','/fixtures/repo','checkout','main')


def archive_fixture():
    with tarfile.open('/fixtures/bundle.tar','w') as tf:
        data=b'artifact'; info=tarfile.TarInfo('app/data'); info.size=len(data); info.mode=0o644
        tf.addfile(info,io.BytesIO(data))


def generated_test(path,scenario):
    source=P(path).read_text()
    if path.endswith('.checks.json'):
        from generated_checks import evaluate
        try: return {'status':'evaluated',**evaluate(json.loads(source),scenario)}
        except Exception as e: return {'status':'invalid','error':repr(e)}
    try:
        tree=ast.parse(source)
        allowed={'os','stat','pathlib','pwd','grp','json','unittest','subprocess','sys'}
        for n in ast.walk(tree):
            if isinstance(n,ast.Import) and any(x.name.split('.')[0] not in allowed for x in n.names): raise ValueError('Nonstandard or unsupported import')
            if isinstance(n,ast.ImportFrom) and (n.module or '').split('.')[0] not in allowed: raise ValueError('Nonstandard or unsupported import')
            if isinstance(n,ast.Call):
                name=n.func.attr if isinstance(n.func,ast.Attribute) else getattr(n.func,'id','')
                if name in {'exec','eval','compile','system','popen','Popen','write','write_text','write_bytes','chmod','chown','unlink','remove','rmdir','mkdir','makedirs','rename','replace'}: raise ValueError('Test has forbidden side-effect or dynamic call')
                if name in {'run','check_output','check_call','call'}:
                    argv=ast.literal_eval(n.args[0])
                    if not isinstance(argv,list) or not argv or argv[0] not in ['pgrep','dpkg-query','getent','stat','id']:
                        raise ValueError('Only fixed read-only subprocess commands allowed')
                if name=='open':
                    mode=n.args[1] if len(n.args)>1 else next((k.value for k in n.keywords if k.arg=='mode'),ast.Constant('r'))
                    if ast.literal_eval(mode) not in ['r','rb']: raise ValueError('Non-read file access')
        if not any(isinstance(n,ast.Assert) or isinstance(n,ast.Attribute) and n.attr.startswith('assert') for n in ast.walk(tree)):
            raise ValueError('No assertions')
    except Exception as e: return {'status':'invalid','error':repr(e)}
    r=subprocess.run(['python3',path],capture_output=True,text=True,timeout=10,
                     env={**os.environ,'ASTRO_SCENARIO':scenario})
    return {'status':'evaluated','passed':r.returncode==0,'returncode':r.returncode,'stdout':r.stdout,'stderr':r.stderr}


def main():
    if not P('/.dockerenv').exists() or not P('/opt/astrogator-lab-marker').exists():
        raise SystemExit('This runner only executes inside its disposable Docker image')
    task_id, scenario, variant = sys.argv[1:4]
    d=P('/suite/benchmarks')/('expanded' if int(task_id[1:])>=22 else 'original-pilot')/task_id
    assert task_id.startswith('a') and scenario in ['baseline','adversarial']
    assert variant in ['reference','mutant','candidate']
    options=json.loads(sys.argv[4]) if len(sys.argv)>4 else {}
    code=options.get('candidate',str(d/f'{variant}.yml'))
    iterations=options.get('iterations',2)
    if type(iterations) is not int or not 1<=iterations<=2:
        raise ValueError('iterations must be 1 or 2')
    P('/work').mkdir(exist_ok=True); P('/fixtures').mkdir(exist_ok=True)
    env=dict(globals(),adversarial=scenario=='adversarial')
    result=dict(task_id=task_id,scenario=scenario,variant=variant,status='fixture_error',executions=[])
    result['iterations_requested']=iterations
    result['input_sha256']={name:hashlib.sha256(P(path).read_bytes()).hexdigest()
                            for name,path in [('candidate',code),('setup',d/'setup.py'),('oracle',d/'check.py')]}
    started=time.monotonic()
    try:
        exec(compile((d/'setup.py').read_text(),str(d/'setup.py'),'exec'),env)
        for iteration in range(iterations):
            try:
                r=subprocess.run(['ansible-playbook','-i','localhost,','-c','local',
                    '-e','ansible_python_interpreter=/usr/bin/python3',code],
                    capture_output=True,text=True,timeout=45,
                    env={**os.environ,'ANSIBLE_NOCOLOR':'1','ANSIBLE_LOCAL_TEMP':'/tmp/ansible-local'})
            except subprocess.TimeoutExpired:
                result.update(status='execution_timeout',error='playbook exceeded 45 seconds')
                break
            result['executions'].append(dict(iteration=iteration+1,returncode=r.returncode,stdout=r.stdout,stderr=r.stderr))
            if r.returncode:
                result['status']='execution_error'; break
            if iteration==0 and 'test' in options:
                try:
                    result['generated_test']=generated_test(options['test'],scenario)
                except Exception as e:
                    result['generated_test']={'status':'test_error','error':repr(e)}
            try:
                exec(compile((d/'check.py').read_text(),str(d/'check.py'),'exec'),env)
            except Exception as e:
                result.update(status='oracle_rejected',error=repr(e)); break
            result['status']='passed'
    except Exception as e:
        result.update(error=repr(e))
    result['seconds']=round(time.monotonic()-started,3)
    print(json.dumps(result))


if __name__=='__main__': main()
