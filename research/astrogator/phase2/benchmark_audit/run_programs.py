import subprocess,json,pathlib,hashlib
root=pathlib.Path(__file__).resolve().parents[2]
out=pathlib.Path(__file__).parent/'program-results.jsonl'
image='astrogator-lab:20260924-v2'
meta={'image':image,'image_id':subprocess.check_output(['docker','image','inspect',image,'--format','{{.Id}}'],text=True).strip(),'runner_sha256':hashlib.sha256(pathlib.Path(__file__).with_name('container_program_audit.py').read_bytes()).hexdigest()}
pathlib.Path(__file__).with_name('program-protocol.json').write_text(json.dumps(meta,indent=2))
with out.open('w') as f:
 for task in ['a24','a32','a34','a53','a58','a64','a68','a70']:
  for scenario in ['original','heldout']:
   for variant in ['reference','challenge']:
    # a68 original state must be absent to expose regular-file/absence confusion.
    r=subprocess.run(['docker','run','--rm','--init','--network','none','--memory','384m','--cpus','0.5','--pids-limit','96','-v',str(root)+':/suite:ro',image,'python3','/suite/phase2/benchmark_audit/container_program_audit.py',task,scenario,variant],capture_output=True,text=True,timeout=160)
    try: row=json.loads(r.stdout.splitlines()[-1])
    except Exception:row={'task':task,'scenario':scenario,'variant':variant,'infrastructure_error':True,'stdout':r.stdout,'stderr':r.stderr,'returncode':r.returncode}
    f.write(json.dumps(row)+'\n');f.flush();print(task,scenario,variant,[(x.get('old'),x.get('strengthened')) for x in row.get('runs',[])],flush=True)
