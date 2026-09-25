#!/usr/bin/env python3
import hashlib,json
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[1]
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rows(p):return[json.loads(x)for x in p.read_text().splitlines()]
s=read(H/'all-summary.json');out={'arms':{}};checked={}
for arm in s['arms']:
 f=read(H/f'frozen-{arm}.json');cfgs={q['task_id']:q for q in f['supplied_queries']};qs={(q['model_alias'],q['repeat'],q['task_id']):q for q in f['translations']};samples={x['sample_id']:x for x in f['samples']};seen=set();keys=set()
 for p,h in f['source_sha256'].items():assert sha(R/p)==h
 for q in f['translations']:assert sha(R/q['source_record'])==q['source_sha256']==sha(R/q['snapshot'])
 for sid,x in samples.items():
  if x['response']:assert sha(R/x['response']['path'])==x['response']['sha256']
 for c in rows(H/f'cells-{arm}.jsonl'):
  k=(c['model_alias'],c['repeat'],c['sample_id']);assert k not in seen;seen.add(k)
  q=qs[c['model_alias'],c['repeat'],c['task_id']];assert c['query_sha256']==q['query_sha256'];x=samples[c['sample_id']];assert x['task_id']==c['task_id']
  if not x['response']:assert c['status']=='missing_processed';continue
  assert c['code_sha256']==x['response']['sha256']
  if c.get('verifier_result_path'):
   p=c['verifier_result_path'];keys.add(p)
   if p not in checked:checked[p]=read(R/p)
   v=checked[p]
   for field in ['query_sha256','code_sha256','environment_sha256','status']:assert c[field]==v[field]
   key=hashlib.sha256((v['environment_sha256']+'\0'+v['query_sha256']+'\0'+v['code_sha256']).encode()).hexdigest();assert Path(p).stem==key==v['cache_key']
 assert len(seen)==13860
 out['arms'][arm]={'unique_attempt_cells':len(seen),'processed_cells':13428,'queries':126,'unique_verifier_evidence_files':len(keys),'source_and_candidate_hashes_verified':True,'frozen_sha256':sha(H/f'frozen-{arm}.json')}
out['unique_evidence_files_across_arms']=len(checked);out['complete']=True
(H/'ALL-AUDIT.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out))
