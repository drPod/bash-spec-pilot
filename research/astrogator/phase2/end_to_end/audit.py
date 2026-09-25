#!/usr/bin/env python3
"""Validate immutable inputs, every logical cell, and content-addressed evidence."""
import hashlib,json
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def rows(p):return [json.loads(x)for x in p.read_text().splitlines()]
s=read(H/'summary.json');audit={'arms':{},'source_hashes':{}}
for arm in s['arms']:
 f=read(H/f'frozen-{arm}.json');sources=f['source_sha256']
 for name,digest in sources.items():assert sha(R/name)==digest,(arm,name,'source drift')
 for q in f['translations']:
  assert sha(R/q['source_record'])==q['source_sha256']==sha(R/q['snapshot'])
  assert hashlib.sha256(q['query'].encode()).hexdigest()==q['query_sha256']
 cells=rows(H/f'cells-{arm}.jsonl');controls=rows(H/f'control-{arm}.jsonl');qs={(q['model_alias'],q['repeat'],q['task_id']):q for q in f['translations']}
 samples={x['sample_id']:x for x in f['samples']};seen=set();cached=set()
 for c in cells:
  k=(c['model_alias'],c['repeat'],c['sample_id']);assert k not in seen;seen.add(k)
  q=qs[c['model_alias'],c['repeat'],c['task_id']];assert q['query_sha256']==c['query_sha256']
  sample=samples[c['sample_id']];assert sample['task_id']==c['task_id']
  if not sample.get('response'):assert c['status']=='missing_processed';continue
  assert c['code_sha256']==sample['response']['sha256']==sha(R/sample['response']['path'])
  if c.get('verifier_result_path'):
   p=R/c['verifier_result_path'];v=read(p);cached.add(str(p.relative_to(R)))
   for field in ['environment_sha256','query_sha256','code_sha256','status']:assert v[field]==c[field]
   key=hashlib.sha256((v['environment_sha256']+'\0'+v['query_sha256']+'\0'+v['code_sha256']).encode()).hexdigest()
   assert p.stem==v['cache_key']==key
 assert len(seen)==2640 and len(controls)==440
 supplied={q['task_id']:q['query_sha256']for q in f['supplied_queries']}
 audit['arms'][arm]={'logical_attempts':len(cells),'processed_cells':sum(bool(x.get('response'))for x in f['samples'])*6,'queries':len(qs),'query_byte_matches_to_supplied':sum(q['query_sha256']==supplied[q['task_id']]for q in f['translations']),'distinct_verifier_cache_entries':len(cached),'frozen_sha256':sha(H/f'frozen-{arm}.json'),'source_hash_checks':len(sources),'record_and_candidate_hashes_verified':True}
 audit['source_hashes'].update(sources)
audit['complete']=True
(H/'AUDIT.json').write_text(json.dumps(audit,indent=2)+'\n')
print(json.dumps(audit['arms']))
