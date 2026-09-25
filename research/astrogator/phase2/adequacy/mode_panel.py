#!/usr/bin/env python3
"""Diagnostic panel added after inspecting initial reference incompatibility.
Not a held-out test of the screening procedure. No upstream algorithm modified.
"""
import hashlib,json,subprocess,sys,uuid
from pathlib import Path
import yaml
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
MODES={'a22':['0700','u=rwx,g=,o=','u=rwX','u=rwX,g=,o='],'a67':['0700','u=rwx,g=,o=','u=rwx']}
def build():
 rows=[]
 for task,modes in MODES.items():
  for i,mode in enumerate(modes):
   p=HERE/'mode-cases'/task/f'mode{i}.yml';p.parent.mkdir(parents=True,exist_ok=True)
   plays=yaml.safe_load((ROOT/'benchmarks/expanded'/task/'reference.yml').read_text());plays[0]['tasks'][-1]['ansible.builtin.file']['mode']=mode
   p.write_text(yaml.safe_dump(plays,sort_keys=False))
   rows.append({'task_id':task,'mode':mode,'path':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
 (HERE/'mode-design.json').write_text(json.dumps({'purpose':__doc__,'cases':rows},indent=2)+'\n')
def execute():
 with (HERE/'mode-execution.jsonl').open('w') as f:
  for row in json.loads((HERE/'mode-design.json').read_text())['cases']:
   for scenario in ['baseline','adversarial']:
    name='astro-mode-'+uuid.uuid4().hex[:10]
    try:
     r=subprocess.run(['docker','run','--rm','--init','--name',name,'--network=none','--memory=384m','--cpus=.5','--pids-limit=96','-v',f'{ROOT}:/suite:ro','astrogator-lab:20260924-v2','python3','/suite/scripts/container_case.py',row['task_id'],scenario,'candidate',json.dumps({'candidate':'/suite/'+row['path'],'iterations':1})],capture_output=True,text=True,timeout=100)
     result=json.loads(r.stdout) if r.returncode==0 else {'status':'harness_error','stderr':r.stderr}
    except Exception as e: result={'status':'harness_error','error':repr(e)}
    finally: subprocess.run(['docker','rm','-f',name],capture_output=True)
    result.update(row,scenario=scenario);f.write(json.dumps(result)+'\n');f.flush();print(row['task_id'],row['mode'],scenario,result['status'],flush=True)
def verify():
 sys.path.insert(0,'/suite/scripts');from upstream_eval import verify
 for row in json.loads((HERE/'mode-design.json').read_text())['cases']:
  import tempfile
  plays=yaml.safe_load((ROOT/row['path']).read_text());plays[0].pop('gather_facts')
  with tempfile.NamedTemporaryFile(mode='w',suffix='.yml') as f:
   yaml.safe_dump(plays,f,sort_keys=False);f.flush()
   q=(ROOT/'benchmarks/expanded'/row['task_id']/'query.fql').read_text()
   print(json.dumps({**row,**verify(q,f.name)}),flush=True)
if __name__=='__main__': {'build':build,'execute':execute,'verify':verify}[sys.argv[1]]()
