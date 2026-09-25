import hashlib,json,subprocess,sys,tempfile,uuid
from pathlib import Path
H=Path(__file__).resolve().parent;ROOT=H.parents[1]
rows=json.loads((H/'review-design.json').read_text())
if sys.argv[1]=='execute':
 with (H/'review-execution.jsonl').open('w')as out:
  for row in rows:
   for scenario in ['baseline','adversarial']:
    name='astro-mode-review-'+uuid.uuid4().hex[:10]
    try:
     r=subprocess.run(['docker','run','--rm','--init','--name',name,'--network=none','--memory=384m','--cpus=.5','--pids-limit=96','-v',f'{ROOT}:/suite:ro','astrogator-lab:20260924-v2','python3','/suite/scripts/container_case.py',row['task_id'],scenario,'candidate',json.dumps({'candidate':'/suite/'+row['path'],'iterations':1})],capture_output=True,text=True,timeout=100)
     result=json.loads(r.stdout)if r.returncode==0 else {'status':'harness_error','stderr':r.stderr}
    except Exception as e:result={'status':'harness_error','error':repr(e)}
    finally:subprocess.run(['docker','rm','-f',name],capture_output=True)
    result.update(row,scenario=scenario);out.write(json.dumps(result)+'\n');out.flush();print(row['task_id'],row['program_name'],scenario,result['status'],flush=True)
else:
 import yaml
 sys.path.insert(0,'/suite/scripts');import upstream_eval as u
 bins={'original':u.BIN,'ordinary_permission_patch':ROOT/'phase2/adequacy/.cache/bin','normalizer':H/'.cache/bin'}
 base_call=u.call
 def guarded_call(argv,*args,**kwargs):
  if version=='normalizer' and argv[0]==str(u.BIN/'verify.exe'):
   argv=list(argv);argv.insert(3,'--constant-modes')
  return base_call(argv,*args,**kwargs)
 u.call=guarded_call
 for version,bin in bins.items():
  u.BIN=bin
  for row in rows:
   q=(ROOT/'benchmarks/expanded'/row['task_id']/'query.fql').read_text()
   plays=yaml.safe_load((ROOT/row['path']).read_text());plays[0].pop('gather_facts')
   with tempfile.NamedTemporaryFile(mode='w',suffix='.yml')as f:
    yaml.safe_dump(plays,f,sort_keys=False);f.flush();r=u.verify(q,f.name)
   print(json.dumps({**row,'version':version,**r}),flush=True)
