#!/usr/bin/env python3
import concurrent.futures
import json
from pathlib import Path
import subprocess
import uuid
import argparse

ROOT=Path(__file__).resolve().parents[1]


def execute(case):
    task,scenario,variant,kind,path=case
    name='astro-test-'+uuid.uuid4().hex[:12]
    cmd=['docker','run','--rm','--init','--name',name,'--network=none','--memory=384m','--cpus=0.75','--pids-limit=96',
         '-v',f'{ROOT}:/suite:ro','astrogator-lab:20260924-v2','python3','/suite/scripts/container_case.py',
         task,scenario,variant,json.dumps({'test':'/suite/'+str(path.relative_to(ROOT))})]
    try:
        r=subprocess.run(cmd,capture_output=True,text=True,timeout=115)
        result=json.loads(r.stdout)
    except Exception as e: result={'task_id':task,'scenario':scenario,'variant':variant,'status':'harness_error','error':str(e)}
    finally: subprocess.run(['docker','rm','-f',name],capture_output=True)
    result['test_kind']=kind
    return result


def main():
    p=argparse.ArgumentParser(); p.add_argument('--schema-only',action='store_true'); a=p.parse_args()
    cases=[]
    for kind in (['checks-0shot-schema'] if a.schema_only else ['tests-0shot','checks-0shot']):
        for record in sorted((ROOT/'experiments/qwen-local-pilot'/kind).glob('*.json')):
            if record.name.endswith('.checks.json'): continue
            r=json.loads(record.read_text()); task=r['task_id']
            if kind.startswith('checks'):
                path=record.with_suffix('.checks.json'); path.write_text(record.with_suffix('.txt').read_text())
            else: path=record.with_suffix('.py')
            for s in ['baseline','adversarial']:
                for v in ['reference','mutant']: cases.append((task,s,v,kind,path))
    report='generated-tests-schema-execution.jsonl' if a.schema_only else 'generated-tests-execution.jsonl'
    with (ROOT/'reports'/report).open('w') as f, concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        for r in pool.map(execute,cases):
            f.write(json.dumps(r)+'\n'); f.flush()
            print(r['task_id'],r['scenario'],r['variant'],r['test_kind'],r.get('generated_test',{}).get('status',r['status']),flush=True)


if __name__=='__main__': main()
