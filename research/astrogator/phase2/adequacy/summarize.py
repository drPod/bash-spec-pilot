#!/usr/bin/env python3
import collections,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def load(name):return [json.loads(l) for l in (HERE/name).read_text().splitlines()]
def dump(name,x):(HERE/name).write_text(json.dumps(x,indent=2)+'\n')
def main():
 design=json.loads((HERE/'frozen-design.json').read_text());vr=load('verifier.jsonl');ex=load('execution.jsonl')
 assert len(vr)==158 and len(ex)==40
 idx={(r['task_id'],r['query_name'],r['program_name']):r for r in vr}
 old=json.loads((ROOT/'reports/expansion-final.json').read_text())['tasks']
 tasks=[];challenges=[]
 accept='accepted_with_possible_residuals'
 for b in design['cases']:
  t=b['task_id']
  for path,sha in b['inputs_sha256'].items():assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest()==sha,(t,path)
  for q in b['queries']:
   ref=idx[t,q,'reference'];mut=idx[t,q,'discovery_mutant']
   stages=ref['query_diagnostics']['stages']
   gate='query_unavailable' if stages.get('codegen',{}).get('status')!='ok' else 'reference_rejected' if ref['status']=='verification_rejected' else 'reference_unavailable' if ref['status']!=accept else 'fault_not_distinguished' if mut['status']==accept else 'screen_passed' if mut['status']=='verification_rejected' else 'fault_unavailable'
   tasks.append({'task_id':t,'query_name':q,'reference_status':ref['status'],'discovery_status':mut['status'],'gate':gate,'discovery_runtime':old[t]})
  for n,p in b['programs'].items():
   if not n.startswith('heldout'):continue
   code=(ROOT/p).read_bytes()
   duplicate=next((k for k in ['reference','discovery_mutant'] if code==(ROOT/b['programs'][k]).read_bytes()),None)
   runs=[r for r in ex if r['task_id']==t and r['program_name']==n]
   assert len(runs)==2 and {r['scenario'] for r in runs}=={'baseline','adversarial'}
   for r in runs:assert r['input_sha256']['candidate']==hashlib.sha256(code).hexdigest()
   label='fails_local_checks' if any(r['status']=='oracle_rejected' for r in runs) else 'execution_error' if any(r['status']=='execution_error' for r in runs) else 'passes_local_checks' if all(r['status']=='passed' for r in runs) else 'unavailable'
   challenges.append({'task_id':t,'program_name':n,'duplicate_of':duplicate,'label':label,'execution_states':{r['scenario']:r['status'] for r in runs},'query_outcomes':{q:idx[t,q,n]['status'] for q in b['queries']}})
 out={'verifier_records':len(vr),'execution_records':len(ex),'candidate_screen_counts':dict(collections.Counter(t['gate'] for t in tasks if t['query_name']=='candidate')),'omission_screen_counts':dict(collections.Counter(t['gate'] for t in tasks if t['query_name']=='omission_control')),'challenge_count':len(challenges),'duplicate_controls':sum(c['duplicate_of'] is not None for c in challenges),'distinct_challenge_count':sum(c['duplicate_of'] is None for c in challenges),'distinct_challenge_labels':dict(collections.Counter(c['label'] for c in challenges if c['duplicate_of'] is None)),'screen':tasks,'challenges':challenges}
 dump('summary.json',out)
 mv=load('mode-verifier.jsonl');me=load('mode-execution.jsonl');assert len(mv)==7 and len(me)==14
 panel=[]
 for r in mv:
  ee=[e for e in me if e['task_id']==r['task_id'] and e['mode']==r['mode']];assert len(ee)==2
  panel.append({'task_id':r['task_id'],'mode':r['mode'],'verifier_status':r['status'],'execution':{e['scenario']:e['status'] for e in ee}})
 dump('mode-summary.json',panel)
 print(json.dumps({k:v for k,v in out.items() if k not in ['screen','challenges']},indent=2));print(json.dumps(panel,indent=2))
if __name__=='__main__':main()
