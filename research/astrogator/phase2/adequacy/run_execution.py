#!/usr/bin/env python3
import json,subprocess,uuid
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
design=json.loads((HERE/'frozen-design.json').read_text())
with (HERE/'execution.jsonl').open('w') as out:
 for b in design['cases']:
  if b['task_id'] not in design['selected_tasks']:continue
  for name,path in b['programs'].items():
   if not name.startswith('heldout'):continue
   for scenario in ['baseline','adversarial']:
    cname='astro-adequacy-'+uuid.uuid4().hex[:10]
    cmd=['docker','run','--rm','--init','--name',cname,'--network=none','--memory=384m','--cpus=0.5','--pids-limit=96','--cap-drop=NET_RAW','-v',f'{ROOT}:/suite:ro',design['image'],'python3','/suite/scripts/container_case.py',b['task_id'],scenario,'candidate',json.dumps({'candidate':'/suite/'+path,'iterations':1})]
    try:
     r=subprocess.run(cmd,capture_output=True,text=True,timeout=100)
     result=json.loads(r.stdout) if r.returncode==0 else {'status':'harness_error','stderr':r.stderr}
    except Exception as e:result={'status':'harness_error','error':repr(e)}
    finally:subprocess.run(['docker','rm','-f',cname],capture_output=True)
    result.update(task_id=b['task_id'],program_name=name,scenario=scenario)
    out.write(json.dumps(result)+'\n');out.flush();print(b['task_id'],name,scenario,result['status'],flush=True)
