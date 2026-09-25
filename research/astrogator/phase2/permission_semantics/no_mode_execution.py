import json,subprocess,uuid
from pathlib import Path
H=Path(__file__).resolve().parent;ROOT=H.parents[1]
with (H/'a32-no-mode-execution.jsonl').open('w')as f:
 for scenario in ['baseline','adversarial']:
  name='astro-no-mode-'+uuid.uuid4().hex[:10]
  try:
   r=subprocess.run(['docker','run','--rm','--init','--name',name,'--network=none','--memory=384m','--cpus=.5','--pids-limit=96','-v',f'{ROOT}:/suite:ro','astrogator-lab:20260924-v2','python3','/suite/scripts/container_case.py','a32',scenario,'candidate',json.dumps({'candidate':'/suite/phase2/permission_semantics/review-cases/a32/no-mode.yml','iterations':1})],capture_output=True,text=True,timeout=100)
   result=json.loads(r.stdout)if r.returncode==0 else {'status':'harness_error','stderr':r.stderr}
  except Exception as e:result={'status':'harness_error','error':repr(e)}
  finally:subprocess.run(['docker','rm','-f',name],capture_output=True)
  result.update(task_id='a32',scenario=scenario,program_name='reference_without_mode');f.write(json.dumps(result)+'\n');f.flush();print(scenario,result['status'],flush=True)
