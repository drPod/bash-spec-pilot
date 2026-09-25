#!/usr/bin/env python3
"""Execute bounded, offline Docker cases; never run playbooks on the host."""
import argparse
import concurrent.futures
import json
from pathlib import Path
import subprocess
import uuid

ROOT=Path(__file__).resolve().parents[1]


def execute(case,image):
    task,scenario,variant=case
    name='astro-case-'+uuid.uuid4().hex[:12]
    cmd=['docker','run','--rm','--init','--name',name,'--network=none','--memory=384m','--cpus=0.75',
         '--pids-limit=96','--cap-drop=NET_RAW','-v',f'{ROOT}:/suite:ro',image,
         'python3','/suite/scripts/container_case.py',task,scenario,variant]
    try:
        r=subprocess.run(cmd,capture_output=True,text=True,timeout=115)
        if r.returncode: raise RuntimeError(r.stderr[-3000:])
        result=json.loads(r.stdout)
    except Exception as e:
        result=dict(task_id=task,scenario=scenario,variant=variant,status='harness_error',error=str(e))
    finally:
        subprocess.run(['docker','rm','-f',name],capture_output=True)
    return result


def summarize(rows):
    tasks={}
    for r in rows:
        t=tasks.setdefault(r['task_id'],{'references':{},'mutants':{}})
        t['references' if r['variant']=='reference' else 'mutants'][r['scenario']]=r['status']
    for t in tasks.values():
        t['reference_validated']=len(t['references'])==2 and all(s=='passed' for s in t['references'].values())
        t['mutant_killed']=any(s in ['oracle_rejected','execution_error'] for s in t['mutants'].values())
        t['mutant_inconclusive']=any(s in ['harness_error','fixture_error'] for s in t['mutants'].values())
    return {'tasks':tasks,'reference_validated':sum(t['reference_validated'] for t in tasks.values()),
            'mutants_killed':sum(t['mutant_killed'] for t in tasks.values()),'case_count':len(rows)}


def main():
    p=argparse.ArgumentParser(); p.add_argument('--image',default='astrogator-lab:20260924-v2')
    p.add_argument('--tasks',nargs='*'); p.add_argument('--workers',type=int,default=2)
    p.add_argument('--output',default='reports/expansion-execution.jsonl'); a=p.parse_args()
    assert 1<=a.workers<=2
    ids=a.tasks or [t['id'] for t in json.loads((ROOT/'benchmarks/expanded.json').read_text())]
    cases=[(t,s,v) for t in ids for s in ['baseline','adversarial'] for v in ['reference','mutant']]
    rows=[]; out=ROOT/a.output; out.parent.mkdir(parents=True,exist_ok=True)
    with out.open('w') as f, concurrent.futures.ThreadPoolExecutor(max_workers=a.workers) as pool:
        for r in pool.map(lambda c:execute(c,a.image),cases):
            rows.append(r); f.write(json.dumps(r)+'\n'); f.flush()
            print(r['task_id'],r['scenario'],r['variant'],r['status'],flush=True)
    summary=summarize(rows)
    out.with_suffix('.summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k!='tasks'}))
    return 0 if all(t['reference_validated'] and t['mutant_killed'] and not t['mutant_inconclusive'] for t in summary['tasks'].values()) else 1


if __name__=='__main__': raise SystemExit(main())
