#!/usr/bin/env python3
import collections,hashlib,json,re
from pathlib import Path
import yaml
H=Path(__file__).resolve().parent;ROOT=H.parents[1];A=H.parent/'adequacy'
def read(p):return [json.loads(l)for l in p.read_text().splitlines()]
def keyed(rows,fields):
 d={tuple(r[f]for f in fields):r for r in rows};assert len(d)==len(rows);return d
def write(name,x):(H/name).write_text(json.dumps(x,indent=2)+'\n')
def main():
 original=keyed(read(ROOT/'reports/corpus-verifier.jsonl'),['sample_id']);new=read(H/'corpus.jsonl');assert len(new)==2310
 assert {r['sample_id']for r in new}=={k[0]for k in original}
 manifest={r['sample_id']:r for r in read(ROOT/'data/manifest.jsonl')}
 labels={r['sample_id']:r['local_label']for r in json.loads((ROOT/'experiments/four-task-full-v1/summary.json').read_text())['samples']}
 modules={'file','copy','get_url','uri','lineinfile','blockinfile'}
 def modes(node):
  if isinstance(node,dict):
   for k,v in node.items():
    if k.split('.')[-1]in modules and isinstance(v,dict):
     for field in ['mode','directory_mode']:
      if field in v:yield v[field]
    yield from modes(v)
  elif isinstance(node,list):
   for v in node:yield from modes(v)
 def category(m):
  if type(m)is int:return 'unquoted_integer_in_PyYAML_upstream_numeric_typing_unsupported'
  if type(m)is float:return 'floating_point_mode_unsupported'
  if isinstance(m,str)and'{{'in m:return 'dynamic_expression'
  if isinstance(m,str)and'X'in m:return 'conditional_X_without_supported_directory_context'
  return 'other_literal_mode_arguments_in_unsupported_program'
 changes=[];unsupported=[]
 for r in new:
  before=original[r['sample_id'],]
  if r['status']!='missing_processed':assert r['code_sha256']==before['code_sha256']==manifest[r['sample_id']]['artifacts']['response']['sha256']
  if 'Unsupported permission mode'in r.get('stdout',''):
   src=(ROOT/manifest[r['sample_id']]['artifacts']['response']['path']).read_text()
   try:values=list(modes(yaml.safe_load(src)))
   except yaml.YAMLError:values=[]
   unsupported.append({'sample_id':r['sample_id'],'task_id':r['task_id'],'raw_modes':values,'categories':sorted({category(m)for m in values}),'old_status':before['status'],'local_label_if_available':labels.get(r['sample_id']),'source_path':manifest[r['sample_id']]['artifacts']['response']['path']})
  if r['status']!=before['status']:
   assert 'Unsupported permission mode'in r.get('stdout','')
   changes.append({'sample_id':r['sample_id'],'task_id':r['task_id'],'before':before['status'],'after':r['status'],'local_label_if_available':labels.get(r['sample_id'])})
 write('corpus-summary.json',{'records':len(new),'processed':2238,'missing':72,'before':dict(collections.Counter(r['status']for r in original.values())),'after':dict(collections.Counter(r['status']for r in new)),'transitions':[{'before':a,'after':b,'count':n}for(a,b),n in collections.Counter((r['before'],r['after'])for r in changes).items()],'changed_count':len(changes),'explicit_unsupported_count':len(unsupported),'unsupported_categories':dict(collections.Counter(c for r in unsupported for c in r['categories'])),'changed_local_labels':dict(collections.Counter(r['local_label_if_available']or'not_executed_in_four_task_slice'for r in changes)),'changes':changes,'unsupported_programs':unsupported})
 fields=['task_id','query_name','program_name'];old=keyed(read(A/'patched-verifier.jsonl'),fields);off=keyed(read(H/'default-off.jsonl'),fields);on=keyed(read(H/'integration.jsonl'),fields);assert len(old)==len(off)==len(on)==165
 assert all(off[k]['status']==r['status']for k,r in old.items())
 changes=[{'task_id':k[0],'query_name':k[1],'program_name':k[2],'before':old[k]['status'],'after':r['status']}for k,r in on.items()if r['status']!=old[k]['status']]
 write('integration-summary.json',{'paired_records':165,'default_disabled_status_differences':0,'enabled_changes':changes,'normalizer_regressions':14,'base_regressions':9,'guard_control_cases':28,'guard_verifier_calls':43})
 rv=read(H/'review-verifier.jsonl');ex=read(H/'review-execution.jsonl');assert len(rv)==15 and len(ex)==10
 panel=[]
 for d in json.loads((H/'review-design.json').read_text()):
  panel.append({**d,'execution':{r['scenario']:r['status']for r in ex if r['task_id']==d['task_id']and r['program_name']==d['program_name']},'verifier':{r['version']:r['status']for r in rv if r['task_id']==d['task_id']and r['program_name']==d['program_name']}})
 write('review-summary.json',panel)
 for path,sha in json.loads((H/'final-run-inputs.json').read_text())['files'].items():assert hashlib.sha256((H/path).read_bytes()).hexdigest()==sha,path
 print('PASS corpus identities/hashes,165 paired controls,15 review outcomes,10 runtime cases,final source/binary hashes')
if __name__=='__main__':main()
