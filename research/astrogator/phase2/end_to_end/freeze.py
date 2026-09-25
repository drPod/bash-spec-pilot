#!/usr/bin/env python3
"""Freeze settled translation bytes and the unchanged422-program cohort per arm."""
import argparse,hashlib,json,subprocess
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[1]
TASKS=['a01','a02','a06','a17'];MODELS=['gpt6','opus55']
def sha(b):return hashlib.sha256(b).hexdigest()
def save(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 ap=argparse.ArgumentParser();ap.add_argument('arm',choices=['compact','handbook']);a=ap.parse_args()
 directory=R/('phase2/integration/frontier'if a.arm=='compact'else'phase2/translation_method/runs')
 marker=R/('phase2/integration/python-inference-complete.json'if a.arm=='compact'else'phase2/translation_method/translation-summary.json')
 if a.arm=='compact'and not marker.exists():marker=H/'compact-settlement-confirmation.json'
 assert marker.exists(),f'Final settlement marker absent: {marker}'
 if a.arm=='handbook':
  sums=json.loads(marker.read_text())['arms']
  assert all(sums['handbook/'+m]['complete']for m in ['gpt-6-astra','claude-opus-5-5'])
 cfgpath=directory/'frozen-inputs.json';cfg=json.loads(cfgpath.read_text());cfgsha=sha(cfgpath.read_bytes())
 tasks={x['id']:x for x in cfg['tasks']if x['mode']=='fql'and x['task_id']in TASKS}
 assert len(tasks)==12
 cohortpath=R/'experiments/four-task-full-v1/frozen-inputs.json';cohort=json.loads(cohortpath.read_text())
 assert cohort['tasks']==TASKS and len(cohort['samples'])==440
 programs=cohort['samples'];assert sum(bool(x.get('response'))for x in programs)==422
 for sample in programs:
  if sample.get('response'):assert sha((R/sample['response']['path']).read_bytes())==sample['response']['sha256']
 translations=[]
 for model in MODELS:
  for id,task in sorted(tasks.items()):
   p=directory/model/(id+'.json');r=json.loads(p.read_text())
   assert r['task']==task and r['frozen_input_sha256']==cfgsha,(p,'source configuration mismatch')
   assert r['model_alias']==model
   if r['status']=='ok':assert not r.get('tool_use_detected'), 'Tool-contaminated output cannot be an eligible generation'
   q=r.get('extracted','');assert isinstance(q,str)
   copy=H/'inputs'/a.arm/model/p.name
   if copy.exists():assert copy.read_bytes()==p.read_bytes(),'Settled output changed after snapshot'
   else:copy.parent.mkdir(parents=True,exist_ok=True);copy.write_bytes(p.read_bytes())
   translations.append({'id':id,'task_id':task['task_id'],'repeat':task['repeat'],'model_alias':model,'model':r['model'],'generation_status':r['status'],'query':q,'query_sha256':sha(q.encode()),'source_record':str(p.relative_to(R)),'source_sha256':sha(p.read_bytes()),'snapshot':str(copy.relative_to(R)),'prompt_sha256':r['prompt_sha256'],'tool_use_detected':r.get('tool_use_detected')})
 refs=[{'task_id':b['id'],'query':b['formal_query'],'query_sha256':sha(b['formal_query'].encode())}for b in json.loads((R/'benchmarks/original.json').read_text())if b['id']in TASKS]
 sourcepaths=[H/'freeze.py',H/'run.py',H/'summarize.py',H/'effects.py',H/'traces.py',R/'scripts/evaluate_effects.py',R/'scripts/upstream_eval.py',R/'scripts/fql_probe.ml',R/'benchmarks/original.json',R/'experiments/four-task-full-v1/summary.json',R/'phase2/evaluation/revised-summary.json',R/'reports/corpus-verifier.jsonl']
 result={'arm':a.arm,'protocol':'Translate once per task/model/repeat; apply each unselected output to every corresponding processed program. Original pinned Astrogator default semantics. No oracle-guided query selection/repair. Exact-byte query+candidate+environment dedup only; all logical cells retained. Supplied-query control is not independently validated gold.','tasks':TASKS,'models':MODELS,'repeats':[0,1,2],'settlement_marker':str(marker.relative_to(R)),'settlement_marker_sha256':sha(marker.read_bytes()),'source_config_sha256':cfgsha,'cohort_sha256':sha(cohortpath.read_bytes()),'image_id':cohort['image_id'],'samples':programs,'translations':translations,'supplied_queries':refs,'source_sha256':{str(p.relative_to(R)):sha(p.read_bytes())for p in sourcepaths},'expected_processed_cells':2532,'expected_attempt_cells':2640,'query_extraction':'Use upstream generator extracted field verbatim; no additional cleanup or normalization.'}
 path=H/f'frozen-{a.arm}.json'
 if path.exists():assert json.loads(path.read_text())==result,'Frozen arm changed'
 else:save(path,result)
 print(json.dumps({'arm':a.arm,'queries':len(translations),'processed_cells':2532,'attempt_cells':2640,'frozen_sha256':sha(path.read_bytes())}))
if __name__=='__main__':main()
