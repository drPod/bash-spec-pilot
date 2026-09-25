#!/usr/bin/env python3
"""Resume-safe, independently checked execution of the full four-task slice.

These are local environment observations, NOT the paper's multi-OS labels.
Frozen reference controls must pass before any candidate is executed.
"""
import argparse
import concurrent.futures
from datetime import datetime,timezone
import hashlib
import json
from pathlib import Path
import subprocess
import uuid

ROOT=Path(__file__).resolve().parents[1]
TASKS=('a01','a02','a06','a17')
IMAGE='astrogator-lab:20260924-v2'
SCENARIOS=('baseline','adversarial')


def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def now(): return datetime.now(timezone.utc).isoformat()


def freeze(run):
    manifest=[json.loads(l) for l in (ROOT/'data/manifest.jsonl').read_text().splitlines()]
    selected=[r for r in manifest if r['task_id'] in TASKS]
    sources={str(p.relative_to(ROOT)):sha(p) for p in
             [ROOT/'scripts/container_case.py',ROOT/'scripts/corpus_ground_truth.py']}
    for task in TASKS:
        for name in ['setup.py','check.py','reference.yml']:
            p=ROOT/'benchmarks/original-pilot'/task/name; sources[str(p.relative_to(ROOT))]=sha(p)
    image_id=subprocess.check_output(['docker','image','inspect',IMAGE,'--format','{{.Id}}'],text=True).strip()
    config={'tasks':TASKS,'scenarios':SCENARIOS,'image_id':image_id,'source_sha256':sources,
            'iterations':1,'task_scope':'existing supplied natural-language request; exact-byte a06 oracle',
            'sample_scope':'all raw attempts on four tasks; no model/output selection',
            'raw_attempts':len(selected),'processed_samples':sum('response' in r['artifacts'] for r in selected),
            'samples':[{'sample_id':r['sample_id'],'task_id':r['task_id'],
                        'response':r['artifacts'].get('response')} for r in selected]}
    # JSON round trip canonicalizes tuples to lists for resume comparison.
    config=json.loads(json.dumps(config))
    path=run/'frozen-inputs.json'
    if path.exists():
        if json.loads(path.read_text())!=config:
            raise RuntimeError('Frozen inputs changed; use a NEW --run instead of mixing measurements')
    else: path.write_text(json.dumps(config,indent=2)+'\n')
    return config


def execute(case,image_id):
    sample,task,scenario,path,expected_sha=case
    if sha(path)!=expected_sha:
        raise RuntimeError(f'Candidate content changed: {sample}')
    name='astro-ground-'+uuid.uuid4().hex[:12]
    options={'candidate':'/suite/'+str(path.relative_to(ROOT)),'iterations':1}
    cmd=['docker','run','--rm','--init','--name',name,'--network=none','--memory=384m',
         '--cpus=0.75','--pids-limit=96','--cap-drop=NET_RAW','-v',f'{ROOT}:/suite:ro',image_id,
         'python3','/suite/scripts/container_case.py',task,scenario,'candidate',json.dumps(options)]
    started=now()
    try:
        r=subprocess.run(cmd,capture_output=True,text=True,timeout=75)
        if r.returncode: raise RuntimeError(f'Docker returned {r.returncode}: {r.stderr[-1500:]}')
        result=json.loads(r.stdout)
        if result['input_sha256']['candidate']!=expected_sha:
            raise RuntimeError('Container observed different candidate bytes')
    except Exception as e:
        result={'task_id':task,'scenario':scenario,'status':'harness_error','error':str(e)}
    finally:
        subprocess.run(['docker','rm','-f',name],capture_output=True)
    return {**result,'sample_id':sample,'image_id':image_id,'started_at':started,'finished_at':now()}


def observations(path):
    if not path.exists(): return {}
    rows={}
    for n,line in enumerate(path.read_text().splitlines(),1):
        try: r=json.loads(line)
        except ValueError: raise RuntimeError(f'Incomplete JSONL line {n}; preserve and repair file before resuming')
        key=(r['sample_id'],r['scenario'])
        if key in rows: raise RuntimeError(f'Duplicate observation {key}')
        rows[key]=r
    return rows


def summarize(config,rows):
    summary={'raw_attempts':config['raw_attempts'],'processed_samples':config['processed_samples'],
             'observed_cases':len(rows),'expected_cases':config['processed_samples']*2,'samples':[]}
    for r in config['samples']:
        obs=[rows.get((r['sample_id'],s)) for s in SCENARIOS]
        if r['response'] is None: label='missing_processed'
        elif any(o is None for o in obs): label='pending'
        elif any(o['status'] in ['harness_error','fixture_error','execution_timeout'] for o in obs): label='unresolved'
        elif all(o['status']=='passed' for o in obs): label='passed_local_checks'
        else: label='failed_local_checks_or_execution'
        summary['samples'].append({'sample_id':r['sample_id'],'task_id':r['task_id'],'local_label':label,
                                   'scenario_statuses':{s:o['status'] if o else None for s,o in zip(SCENARIOS,obs)}})
    from collections import Counter
    summary['counts']=dict(Counter(r['local_label'] for r in summary['samples']))
    summary['complete']=len(rows)==summary['expected_cases'] and not summary['counts'].get('pending')
    return summary


def main():
    p=argparse.ArgumentParser(); p.add_argument('--run',default='four-task-full-v1'); p.add_argument('--limit',type=int)
    p.add_argument('--workers',type=int,default=2); a=p.parse_args()
    if not 1<=a.workers<=2: raise ValueError('Use one or two workers')
    run=ROOT/'experiments'/a.run; run.mkdir(parents=True,exist_ok=True)
    config=freeze(run)
    controls=run/'reference-controls.jsonl'
    if not controls.exists():
        results=[]
        for task in TASKS:
            path=ROOT/'benchmarks/original-pilot'/task/'reference.yml'
            for scenario in SCENARIOS:
                results.append(execute(('reference/'+task,task,scenario,path,sha(path)),config['image_id']))
        controls.write_text(''.join(json.dumps(r)+'\n' for r in results))
    control_rows=observations(controls)
    if len(control_rows)!=8 or any(r['status']!='passed' for r in control_rows.values()):
        raise RuntimeError('Reference control failed; candidate execution is not authorized by this measurement protocol')
    path=run/'execution.jsonl'; done=observations(path)
    cases=[]
    for r in config['samples']:
        if not r['response']: continue
        for s in SCENARIOS:
            if (r['sample_id'],s) not in done:
                cases.append((r['sample_id'],r['task_id'],s,ROOT/r['response']['path'],r['response']['sha256']))
    if a.limit is not None: cases=cases[:a.limit]
    with path.open('a') as f, concurrent.futures.ThreadPoolExecutor(max_workers=a.workers) as pool:
        for r in pool.map(lambda c:execute(c,config['image_id']),cases):
            f.write(json.dumps(r)+'\n'); f.flush()
            done[r['sample_id'],r['scenario']]=r
            (run/'summary.json').write_text(json.dumps(summarize(config,done),indent=2)+'\n')
            print(len(done),r['sample_id'],r['scenario'],r['status'],flush=True)
    summary=summarize(config,done); (run/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k!='samples'}))


if __name__=='__main__': main()
