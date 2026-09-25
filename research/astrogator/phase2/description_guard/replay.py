#!/usr/bin/env python3
import hashlib,json,subprocess,tempfile
from pathlib import Path
R=Path('/suite');H=R/'phase2/description_guard';E=R/'phase2/end_to_end'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
queries=[];inputs={}
for p in [R/'benchmarks/original.json',E/'frozen-compact-all.json',E/'frozen-handbook-all.json']:inputs[str(p.relative_to(R))]=sha(p)
for x in json.loads((R/'benchmarks/original.json').read_text()):queries.append({'source':'supplied','task_id':x['id'],'query':x['formal_query']})
for arm in ['compact-all','handbook-all']:
 for x in json.loads((E/f'frozen-{arm}.json').read_text())['translations']:
  assert x['generation_status']=='ok';queries.append({'source':arm,'task_id':x['task_id'],'model':x['model_alias'],'repeat':x['repeat'],'query':x['query'],'record_sha256':x['source_sha256']})
assert len(queries)==273
bins={'original':R/'.cache/bin/fql_probe.exe','patched':H/'.cache/bin/description_probe.exe'};cache={};rows=[]
for q in queries:
 result={**q,'results':{}}
 for label,binary in bins.items():
  key=(label,q['query'])
  if key not in cache:
   with tempfile.NamedTemporaryFile(mode='w',suffix='.fql')as f:
    f.write(q['query']);f.flush();p=subprocess.run([str(binary),f.name],capture_output=True,text=True,timeout=15)
   stages={}
   for line in p.stdout.splitlines():
    parts=line.split('\t',2)
    if len(parts)==3:stages[parts[0]]={'status':parts[1],'detail':parts[2]}
   cache[key]={'returncode':p.returncode,'stdout':p.stdout,'stderr':p.stderr,'stages':stages}
  result['results'][label]=cache[key]
 a=result['results']['original'];b=result['results']['patched'];result['identical_diagnostics']=a==b;result['original_lowered']=a['stages'].get('codegen',{}).get('status')=='ok';result['patched_lowered']=b['stages'].get('codegen',{}).get('status')=='ok';rows.append(result)
(H/'replay.json').write_text(json.dumps({'inputs_sha256':inputs,'binaries_sha256':{k:sha(v)for k,v in bins.items()},'logical_queries':len(rows),'unique_binary_query_calls':len(cache),'rows':rows},indent=2)+'\n');print('replayed',len(rows),'changed',sum(not x['identical_diagnostics']for x in rows))
