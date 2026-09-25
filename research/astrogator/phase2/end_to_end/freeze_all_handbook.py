#!/usr/bin/env python3
import hashlib,json,sys
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
arm=sys.argv[1];original=json.loads((R/'benchmarks/original.json').read_text());manifest=[json.loads(x)for x in(R/'data/manifest.jsonl').read_text().splitlines()]
samples=[{'sample_id':x['sample_id'],'task_id':x['task_id'],'response':x['artifacts'].get('response')}for x in manifest]
assert len(samples)==2310 and sum(bool(x['response'])for x in samples)==2238
for s in samples:
 if s['response']:assert sha(R/s['response']['path'])==s['response']['sha256']
queries=[];sourcepaths=[H/'freeze_all_handbook.py',H/'run.py',R/'data/manifest.jsonl',R/'benchmarks/original.json'];marker=None
if arm!='control-all':
 base=arm.removesuffix('-all');d=R/('phase2/integration/frontier'if base=='compact'else'phase2/translation_method/runs')
 marker=H/'compact-settlement-confirmation.json'if base=='compact'else R/'phase2/integration/translation-summary.json'
 assert marker.exists()
 if base=='handbook':assert all(json.loads(marker.read_text())['arms']['handbook/'+m]['complete']for m in ['gpt-6-astra','claude-opus-5-5'])
 cfgp=d/'frozen-inputs.json';cfg=json.loads(cfgp.read_text());sourcepaths.append(cfgp)
 for model in ['gpt6','opus55']:
  tasks=[x for x in cfg['tasks']if x['mode']=='fql'];assert len(tasks)==63
  for t in tasks:
   p=d/model/(t['id']+'.json');x=json.loads(p.read_text());assert x['task']==t and x['frozen_input_sha256']==sha(cfgp)
   if x['status']=='ok':assert not x.get('tool_use_detected')
   q=x.get('extracted','');assert isinstance(q,str)
   dst=H/'inputs'/arm/model/p.name;dst.parent.mkdir(parents=True,exist_ok=True)
   if dst.exists():assert dst.read_bytes()==p.read_bytes()
   else:dst.write_bytes(p.read_bytes())
   queries.append({'id':t['id'],'task_id':t['task_id'],'repeat':t['repeat'],'model_alias':model,'model':x['model'],'generation_status':x['status'],'query':q,'query_sha256':hashlib.sha256(q.encode()).hexdigest(),'source_record':str(p.relative_to(R)),'source_sha256':sha(p),'snapshot':str(dst.relative_to(R)),'prompt_sha256':x['prompt_sha256']})
refs=[{'task_id':x['id'],'query':x['formal_query'],'query_sha256':hashlib.sha256(x['formal_query'].encode()).hexdigest()}for x in original]
f={'arm':arm,'tasks':[x['id']for x in original],'models':['gpt6','opus55'],'repeats':[0,1,2],'samples':samples,'translations':queries,'supplied_queries':refs,'image_id':json.loads((H/'frozen-compact.json').read_text())['image_id'],'protocol':'21-task paired decision extension; no behavioral correctness labels outside frozen four-task cohort. Every unselected translation retained. Original default verifier, exact-byte cache only.','source_sha256':{str(p.relative_to(R)):sha(p)for p in sourcepaths},'settlement_marker':str(marker.relative_to(R))if marker else None,'settlement_marker_sha256':sha(marker)if marker else None}
p=H/f'frozen-{arm}.json'
if p.exists():assert json.loads(p.read_text())==f
else:p.write_text(json.dumps(f,indent=2)+'\n')
print(arm,len(queries),len(samples))
