#!/usr/bin/env python3
"""Reference-gated frontier test study, one execution per candidate/state.

Generations are independent of candidates and gold checks. A gate may use good
references only after generation, an explicit advantage over ungated tests.
"""
import argparse
import concurrent.futures
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import uuid
from frontier import ROOT, OUT, MODELS, save, sha
sys.path.insert(0,str(ROOT/'scripts'))
from generated_checks import validate

HERE=Path(__file__).resolve().parent
DEST=HERE/'generated-tests'

def execute(sample,task,scenario,path,specs,image):
    name='astro-frontier-test-'+uuid.uuid4().hex[:12]
    argv=['docker','run','--rm','--init','--name',name,'--network=none','--memory=320m','--cpus=.5','--pids-limit=96',
          '--cap-drop=NET_RAW','-v',f'{ROOT}:/suite:ro',image,'python3','/suite/phase2/integration/test_case.py',
          task,scenario,'/suite/'+str(path.relative_to(ROOT)),json.dumps(specs)]
    try:
        p=subprocess.run(argv,capture_output=True,text=True,timeout=75)
        if p.returncode: raise RuntimeError(p.stderr[-1500:])
        r=json.loads(p.stdout); assert r['candidate_sha256']==sha(path.read_bytes())
    except Exception as e: r={'task_id':task,'scenario':scenario,'status':'harness_error','error':repr(e)}
    finally: subprocess.run(['docker','rm','-f',name],capture_output=True)
    return {**r,'sample_id':sample}

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--workers',type=int,default=2); ap.add_argument('--full',action='store_true'); args=ap.parse_args()
    config=json.loads((OUT/'frozen-inputs.json').read_text())
    spec_by_task={t:{} for t in ['a01','a02','a06','a17']}; spec_status={}
    for m in MODELS:
        for task in [t for t in config['tasks'] if t['mode']=='checks']:
            src=OUT/m/(task['id']+'.json')
            if not src.exists(): raise RuntimeError('All 16 generations must finish first: '+str(src))
            r=json.loads(src.read_text()); key=m+'-'+task['id']; spec_status[key]={'task_id':task['task_id'],'source_sha256':sha(src.read_bytes())}
            try:
                assert r['status']=='ok', r['status']
                spec=validate(json.loads(r['extracted']))
                path=DEST/'specifications'/(key+'.json'); save(path,spec)
                spec_by_task[task['task_id']][key]='/suite/'+str(path.relative_to(ROOT))
                spec_status[key]['status']='valid'
            except Exception as e: spec_status[key].update(status='invalid',error=repr(e))
    image=subprocess.check_output(['docker','image','inspect','astrogator-lab:20260924-v2','--format','{{.Id}}'],text=True).strip()
    frozen={'image_id':image,'specifications':spec_status,'selection_sha256':sha((OUT/'frozen-inputs.json').read_bytes()),
            'source_sha256':{str(p.relative_to(ROOT)):sha(p.read_bytes()) for p in [Path(__file__),HERE/'test_case.py',ROOT/'scripts/generated_checks.py',ROOT/'scripts/container_case.py',ROOT/'phase2/evaluation/revised_case.py', *sorted((ROOT/'benchmarks/original-pilot').glob('*/*.py'))]},
            'check_sha256':{p.name:sha(p.read_bytes()) for p in sorted((DEST/'specifications').glob('*.json'))},
            'selection':'full422' if args.full else 'identity86','password_fixture':'real crypt hash; original and structural-integrity checks separately',
            'failure_policy':'execution_error counts as program rejection; timeout/infrastructure invalid or missing generated tests abstain; no oracle used to manufacture test verdicts'}
    cfg=DEST/'frozen.json'
    if cfg.exists(): assert json.loads(cfg.read_text())==frozen,'Frozen execution configuration changed'
    else: save(cfg,frozen)
    controls={}
    for task,specs in spec_by_task.items():
        controls[task]=[]
        for scenario in ['baseline','adversarial']:
            path=DEST/f'control-{task}-{scenario}.json'
            if not path.exists(): save(path,execute('reference/'+task,task,scenario,ROOT/'benchmarks/original-pilot'/task/'reference.yml',specs,image))
            controls[task].append(json.loads(path.read_text()))
    gates={}
    for key,state in spec_status.items():
        eligible=state['status']=='valid' and all(r['status']=='observed' and r.get('original_oracle') and r.get('observations',{}).get('strict_oracle',True) and
                  r.get('generated_tests',{}).get(key,{}).get('status')=='evaluated' and r['generated_tests'][key]['passed']
                  for r in controls[state['task_id']])
        gates[key]={**state,'eligible':eligible}
    save(DEST/'gates.json',gates)
    if args.full:
        selected=[r for r in map(json.loads,(ROOT/'data/manifest.jsonl').read_text().splitlines()) if r['task_id'] in spec_by_task]
    else: selected=config['selection']
    cases=[]
    for row in selected:
        if 'response' not in row['artifacts']: continue
        artifact=row['artifacts']['response']; path=ROOT/artifact['path']; assert sha(path.read_bytes())==artifact['sha256']
        specs={k:v for k,v in spec_by_task[row['task_id']].items() if gates[k]['eligible']}
        if not specs: continue
        for scenario in ['baseline','adversarial']:
            dest=DEST/'cases'/(row['sample_id'].replace('/','-')+'-'+scenario+'.json')
            if not dest.exists(): cases.append((dest,(row['sample_id'],row['task_id'],scenario,path,specs,image)))
    def job(case):
        dest,params=case; r=execute(*params); save(dest,r); return r['sample_id'],r['scenario'],r['status']
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
        for r in pool.map(job,cases): print(r,flush=True)

if __name__=='__main__': main()
