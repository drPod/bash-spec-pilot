import pathlib,json,subprocess,shutil
p=pathlib.Path(__file__).resolve().parent;root=p.parents[1]
source=p/'program-results.jsonl';backup=p/'program-results-initial.jsonl'
if not backup.exists():shutil.copyfile(source,backup)
rows=[json.loads(l) for l in source.read_text().splitlines()]
for i,x in enumerate(rows):
 if not x.get('infrastructure_error'):continue
 r=subprocess.run(['docker','run','--rm','--init','--network','none','--memory','384m','--cpus','0.5','--pids-limit','96','-v',str(root)+':/suite:ro','astrogator-lab:20260924-v2','python3','/suite/phase2/benchmark_audit/container_program_audit.py',x['task'],x['scenario'],x['variant']],capture_output=True,text=True,timeout=160)
 row=json.loads(r.stdout.splitlines()[-1]);row['infrastructure_retry_of']='program-results-initial.jsonl';rows[i]=row
source.write_text(''.join(json.dumps(x)+'\n' for x in rows))
