import pathlib,json,subprocess
p=pathlib.Path(__file__).resolve().parent;root=p.parents[1]
with (p/'review-case-results-v3.jsonl').open('w') as f:
 for spec in json.loads((p/'review-case-design-v3.json').read_text()):
  r=subprocess.run(['docker','run','--rm','--init','--network','none','--memory','384m','--cpus','0.5','--pids-limit','96','-v',str(root)+':/suite:ro','astrogator-lab:20260924-v2','python3','/suite/phase2/benchmark_audit/container_review_cases_v3.py',spec['id']],capture_output=True,text=True,timeout=160)
  try:row=json.loads(r.stdout.splitlines()[-1])
  except Exception:row={**spec,'infrastructure_error':True,'stdout':r.stdout,'stderr':r.stderr}
  f.write(json.dumps(row)+'\n');f.flush();print(spec['id'],[(x.get('v2'),x.get('v3')) for x in row.get('iterations',[])],flush=True)
