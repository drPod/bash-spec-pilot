import pathlib,subprocess,json
p=pathlib.Path(__file__).resolve().parent;root=p.parents[1]
with (p/'patch-validation.jsonl').open('w') as f:
 for task in ['a24','a32','a34','a53','a58','a64','a68','a70']:
  for scenario in ['baseline','adversarial']:
   for variant in ['reference','mutant','candidate']:
    options={'iterations':2} if variant!='candidate' else {'iterations':1,'candidate':'/suite/phase2/benchmark_audit/challenge-programs/'+task+'.yml'}
    r=subprocess.run(['docker','run','--rm','--init','--network','none','--memory','384m','--cpus','0.5','--pids-limit','96','-v',str(root)+':/suite:ro','-v',str(p/'patched-suite/benchmarks/expanded')+':/suite/benchmarks/expanded:ro','astrogator-lab:20260924-v2','python3','/suite/scripts/container_case.py',task,scenario,variant,json.dumps(options)],capture_output=True,text=True,timeout=160)
    try:row=json.loads(r.stdout.splitlines()[-1])
    except Exception:row={'task_id':task,'scenario':scenario,'variant':variant,'status':'infrastructure_error','stdout':r.stdout,'stderr':r.stderr}
    f.write(json.dumps(row)+'\n');f.flush();print(task,scenario,variant,row['status'],flush=True)
