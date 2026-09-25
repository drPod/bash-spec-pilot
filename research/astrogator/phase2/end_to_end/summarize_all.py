#!/usr/bin/env python3
"""Paired decision analysis only; supplied queries are not truth labels."""
import collections,hashlib,json,sys
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[1]
def read(p):return json.loads(p.read_text())
def rows(p):return [json.loads(x)for x in p.read_text().splitlines()]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def v(s):return 'accept'if s=='accepted_with_possible_residuals'else'reject'if s=='verification_rejected'else'unavailable'
old={x['sample_id']:x for x in rows(R/'reports/corpus-verifier.jsonl')};out={'scope':'21 tasks,2238 processed programs,72 missing attempts. Paired decisions versus supplied-query control; no correctness claim. Repeated queries and cells are not independent tasks.','arms':{}}
lines=['# All21-task end-to-end paired decisions','','Supplied-query agreement and coverage are reported here; neither is accuracy. Actual behavioral labels remain restricted to the separate four-task experiment. Each row lists r0/r1/r2.','','| Guide | Model | Decisions /2238 | Status changes | Accept→reject | Accept→unavailable | Reject→accept | Unavailable→accept |','|---|---|---|---|---|---|---|---|']
for arm in sys.argv[1:]:
 f=read(H/f'frozen-{arm}.json');run=read(H/f'run-{arm}.json');assert run['complete']and run['frozen_sha256']==sha(H/f'frozen-{arm}.json')
 for p,h in f['source_sha256'].items():assert sha(R/p)==h
 for q in f['translations']:assert sha(R/q['source_record'])==q['source_sha256']==sha(R/q['snapshot'])
 cells=rows(H/f'cells-{arm}.jsonl');controls=rows(H/f'control-{arm}.jsonl');assert len(cells)==13860 and len(controls)==2310
 ci={x['sample_id']:x for x in controls};assert len(ci)==2310
 prior_differences=[]
 for sid,c in ci.items():
  if c['status']!=old[sid]['status']:
   assert c['task_id']=='a18' and old[sid]['status']=='accepted_with_possible_residuals' and c['status']=='verification_rejected',sid
   prior_differences.append({'sample_id':sid,'old_normalized_domain_status':old[sid]['status'],'current_verbatim_query_status':c['status']})
 assert len(prior_differences)==9
 refs={q['task_id']:q for q in f['supplied_queries']};qi={(q['model_alias'],q['repeat'],q['task_id']):q for q in f['translations']};seen=set();changed=[];models={}
 for c in cells:
  key=(c['model_alias'],c['repeat'],c['sample_id']);assert key not in seen;seen.add(key)
  q=qi[c['model_alias'],c['repeat'],c['task_id']];assert q['query_sha256']==c['query_sha256']
  if c['status']=='missing_processed':continue
  if c['status']!=ci[c['sample_id']]['status']:changed.append({**c,'supplied_query_status':ci[c['sample_id']]['status'],'supplied_query_result_path':ci[c['sample_id']].get('verifier_result_path')})
 for model in f['models']:
  reps={}
  for rep in f['repeats']:
   rs=[c for c in cells if c['model_alias']==model and c['repeat']==rep and c['status']!='missing_processed'];assert len(rs)==2238
   trans=collections.Counter(v(ci[c['sample_id']]['status'])+'->'+v(c['status'])for c in rs)
   tasks={}
   for tid in f['tasks']:
    cs=[c for c in rs if c['task_id']==tid];q=qi[model,rep,tid]
    tasks[tid]={'query':q['query'],'generation_status':q['generation_status'],'exact_query_match':q['query_sha256']==refs[tid]['query_sha256'],'statuses':dict(collections.Counter(c['status']for c in cs)),'changed_status':sum(c['status']!=ci[c['sample_id']]['status']for c in cs),'processed':len(cs)}
   reps[str(rep)]={'statuses':dict(collections.Counter(c['status']for c in rs)),'decisions':sum(v(c['status'])!='unavailable'for c in rs),'changed_status':sum(c['status']!=ci[c['sample_id']]['status']for c in rs),'transitions':dict(trans),'reference_decided':{'denominator':sum(n for k,n in trans.items()if not k.startswith('unavailable->')),'same_decision':trans['accept->accept']+trans['reject->reject'],'became_unavailable':trans['accept->unavailable']+trans['reject->unavailable'],'accept_to_reject':trans['accept->reject'],'reject_to_accept':trans['reject->accept']},'tasks':tasks}
  models[model]=reps
  def values(key):return' / '.join(str(reps[str(i)].get(key,reps[str(i)]['transitions'].get(key,0)))for i in range(3))
  lines.append('| '+' | '.join([arm,model]+[values(k)for k in ['decisions','changed_status','accept->reject','accept->unavailable','reject->accept','unavailable->accept']])+' |')
 p=H/f'changed-cells-{arm}.jsonl';p.write_text(''.join(json.dumps(c)+'\n'for c in changed))
 out['arms'][arm]={'complete':True,'processed_cells':13428,'attempt_cells':13860,'queries':126,'exact_query_matches':sum(q['query_sha256']==refs[q['task_id']]['query_sha256']for q in f['translations']),'control_statuses':dict(collections.Counter(c['status']for c in controls)),'prior_normalized_domain_sweep_differences':prior_differences,'models':models,'changed_cells_file':p.name,'run':run}
lines+=['','The verbatim supplied-query control has900 acceptances,628 rejections,710 lowering failures and72 missing attempts. Earlier corpus results used an explicit a18/p17 example.com→acc240.com domain substitution and had909 acceptances/619 rejections. The9 differences are retained separately; they are not translation-caused changes. Generated queries and control here both retain the prompt domain verbatim.','','Primary agreement denominator: the1,528 supplied-query-decided programs, excluding710 control-lowering failures.','','| Guide | Model | Same decision /1528 | Became unavailable | Accept→reject | Reject→accept |','|---|---|---|---|---|---|']
for arm,ar in out['arms'].items():
 for model,reps in ar['models'].items():
  def vals(k):return' / '.join(str(reps[str(i)]['reference_decided'][k])for i in range(3))
  assert all(reps[str(i)]['reference_decided']['denominator']==1528 for i in range(3))
  lines.append('| '+' | '.join([arm,model]+[vals(k)for k in ['same_decision','became_unavailable','accept_to_reject','reject_to_accept']])+' |')
lines+=['','Query-format failures, semantic/code-generation failures, program lowering failures, rejection, and acceptance remain distinct in JSON. A status change is not automatically a correction or a new bug. Acceptance retains verifier assumptions and residuals. All three repeats are kept; no best-repeat selection.']
(H/'all-summary.json').write_text(json.dumps(out,indent=2)+'\n');(H/'ALL-RESULTS.md').write_text('\n'.join(lines)+'\n');print(json.dumps({k:v['exact_query_matches']for k,v in out['arms'].items()}))
