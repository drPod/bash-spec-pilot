#!/usr/bin/env python3
"""Run only inside pinned lab image. No candidate playbook execution occurs."""
import hashlib,json,sys
from pathlib import Path
sys.path.insert(0,'/suite/scripts');import upstream_eval as u
R=Path('/suite');H=R/'phase2/end_to_end'
def sha(b):return hashlib.sha256(b).hexdigest()
def read(p):return json.loads(p.read_text())
def save(p,x):p.parent.mkdir(parents=True,exist_ok=True);t=p.with_suffix('.tmp');t.write_text(json.dumps(x,indent=2)+'\n');t.replace(p)
def main():
 assert Path('/.dockerenv').exists()
 arm=sys.argv[1];frozen=H/f'frozen-{arm}.json';cfg=read(frozen)
 assert str(u.BIN)=='/opt/astrogator/_build/default/bin'
 binaries=[u.BIN/'verify.exe',R/'.cache/bin/fql_probe.exe']
 environment={'binary_sha256':{str(p):sha(p.read_bytes())for p in binaries},'modules_sha256':{str(p):sha(p.read_bytes())for p in map(Path,u.MODULES)},'driver_sha256':sha((R/'scripts/upstream_eval.py').read_bytes()),'permission_semantics':'original pinned default; no experimental patches or flags','image_id':cfg['image_id']}
 envhash=sha(json.dumps(environment,sort_keys=True).encode());environment['sha256']=envhash
 ep=H/'environment.json'
 if ep.exists():assert read(ep)==environment
 else:save(ep,environment)
 for s in cfg['samples']:
  if s.get('response'):assert sha((R/s['response']['path']).read_bytes())==s['response']['sha256']
 for q in cfg['translations']:
  assert sha((R/q['source_record']).read_bytes())==q['source_sha256'],'Settled original prediction changed'
  assert sha(q['query'].encode())==q['query_sha256']
 counters={'new_queries':0,'new_verifications':0,'reused_verifications':0}
 def diagnose(q):
  p=H/'cache/queries'/f'{envhash}-{q["query_sha256"]}.json'
  if p.exists():return read(p)
  r=u.probe(q['query']);s=r['stages']
  status='query_lowered'
  if s.get('parse',{}).get('status')!='ok':status='query_parse_error'
  elif s.get('nonempty',{}).get('status')=='error':status='query_empty'
  elif s.get('semantic',{}).get('status')!='ok':status='query_semantic_error'
  elif s.get('codegen',{}).get('status')!='ok':status='query_codegen_error'
  result={'query_sha256':q['query_sha256'],'query':q['query'],'environment_sha256':envhash,'status':status,'diagnostics':r}
  save(p,result);counters['new_queries']+=1;return result
 def cell(q,s,control=False):
  row={'arm':arm,'model_alias':'supplied_query'if control else q['model_alias'],'model':'supplied_query'if control else q['model'],'repeat':None if control else q['repeat'],'task_id':q['task_id'],'sample_id':s['sample_id'],'query_sha256':q['query_sha256'],'environment_sha256':envhash,'generation_status':'supplied'if control else q['generation_status']}
  if not s.get('response'):return {**row,'status':'missing_processed','verifier_status':None}
  row['code_sha256']=s['response']['sha256']
  if not control and q['generation_status']!='ok':return {**row,'status':'generation_error','verifier_status':None}
  d=diagnose(q);row['query_status']=d['status'];row['query_diagnostics_path']=str((H/'cache/queries'/f'{envhash}-{q["query_sha256"]}.json').relative_to(R))
  if d['status']!='query_lowered':return {**row,'status':d['status'],'verifier_status':None}
  key=sha((envhash+'\0'+q['query_sha256']+'\0'+row['code_sha256']).encode());p=H/'cache/verifier'/f'{key}.json'
  if p.exists():r=read(p);counters['reused_verifications']+=1
  else:
   r={'cache_key':key,'environment_sha256':envhash,'query_sha256':q['query_sha256'],'code_sha256':row['code_sha256'],**u.verify(q['query'],R/s['response']['path'])}
   save(p,r);counters['new_verifications']+=1
  assert r['environment_sha256']==envhash and r['query_sha256']==q['query_sha256']and r['code_sha256']==row['code_sha256']
  return {**row,'status':r['status'],'verifier_status':r['status'],'verifier_result_path':str(p.relative_to(R))}
 # Keep supplied-query control separate, reused across arms through the same cache.
 with (H/f'control-{arm}.jsonl').open('w')as f:
  for q in cfg['supplied_queries']:
   for s in cfg['samples']:
    if s['task_id']==q['task_id']:f.write(json.dumps(cell(q,s,True))+'\n');f.flush()
 with (H/f'cells-{arm}.jsonl').open('w')as f:
  for q in cfg['translations']:
   count=0
   for s in cfg['samples']:
    if s['task_id']==q['task_id']:f.write(json.dumps(cell(q,s))+'\n');f.flush();count+=1
   print(arm,q['model_alias'],q['id'],count,flush=True)
 save(H/f'run-{arm}.json',{'complete':True,'arm':arm,'frozen_sha256':sha(frozen.read_bytes()),'environment_sha256':envhash,**counters})
if __name__=='__main__':main()
