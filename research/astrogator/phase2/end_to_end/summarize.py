#!/usr/bin/env python3
import argparse,collections,hashlib,json
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[1]
ACCEPT='accepted_with_possible_residuals';REJECT='verification_rejected'
def rows(p):return [json.loads(l)for l in p.read_text().splitlines()]
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def verdict(status):return 'accept'if status==ACCEPT else'reject'if status==REJECT else'unavailable'
def metrics(cells,labels):
 out=collections.Counter()
 for c in cells:
  if c['status']=='missing_processed':continue
  label=labels[c['sample_id']];assert label in ['passed_local_checks','failed_local_checks_or_execution']
  outcome='pass'if label=='passed_local_checks'else'fail';out[verdict(c['status'])+'_'+outcome]+=1
 n=sum(out.values());assert n==422
 for a in ['accept','reject','unavailable']:
  for b in ['pass','fail']:out.setdefault(a+'_'+b,0)
 return {**out,'processed':n,'decisions':n-out['unavailable_pass']-out['unavailable_fail'],'decision_coverage':(n-out['unavailable_pass']-out['unavailable_fail'])/n}
def main():
 p=argparse.ArgumentParser();p.add_argument('--arms',nargs='+',default=['compact','handbook']);a=p.parse_args()
 original={r['sample_id']:r['local_label']for r in json.loads((R/'experiments/four-task-full-v1/summary.json').read_text())['samples']if r['local_label']in ['passed_local_checks','failed_local_checks_or_execution']}
 assert len(original)==422
 revised=json.loads((R/'phase2/evaluation/revised-summary.json').read_text());assert revised['complete']
 labels={'original':original,'strict_integrity':dict(original),'newline_sensitivity':dict(original)}
 for r in revised['samples']:
  for kind in ['strict_integrity','newline_sensitivity']:labels[kind][r['sample_id']]=r[kind]
 previous={r['sample_id']:r['status']for r in rows(R/'reports/corpus-verifier.jsonl')}
 summary={'arms':{},'label_counts':{kind:dict(collections.Counter(vals.values()))for kind,vals in labels.items()},'unit':'422 fixed programs nested within4 tasks;3 shared task-level translations permodel/guide. Repetitions andprogram-query cells are not independent problems.','permission_semantics':'Original pinned Astrogator default; no permission patches/flags','limitations':['Local behavioral labels are bounded fixture checks, not universal program correctness.','Supplied-query control is not independently validated gold.','No oracle-based selection among repeats and no query repair.','Translation and judge inference budgets differ; no equal-compute claim.','Fourtaskcohort omits broaderbenchmarktasks and generalization is not established.']}
 joined=[]
 for arm in a.arms:
  frozen=json.loads((H/f'frozen-{arm}.json').read_text());run=json.loads((H/f'run-{arm}.json').read_text());assert run['complete']
  assert run['frozen_sha256']==hashlib.sha256((H/f'frozen-{arm}.json').read_bytes()).hexdigest()
  cells=rows(H/f'cells-{arm}.jsonl');control=rows(H/f'control-{arm}.jsonl');assert len(cells)==2640 and len(control)==440
  cidx={r['sample_id']:r for r in control};assert len(cidx)==440
  for sid,r in cidx.items():assert r['status']==previous[sid],(sid,r['status'],previous[sid])
  ar={'complete':True,'attempt_cells':len(cells),'processed_cells':sum(r['status']!='missing_processed'for r in cells),'control':{kind:metrics(control,labs)for kind,labs in labels.items()},'models':{},'query_outputs':frozen['translations'],'deduplication':run}
  ids=set()
  for c in cells:
   key=(c['model_alias'],c['repeat'],c['sample_id']);assert key not in ids;ids.add(key)
   if c['status']!='missing_processed':joined.append({**c,'supplied_query_status':cidx[c['sample_id']]['status'],'labels':{k:v[c['sample_id']]for k,v in labels.items()}})
  for model in frozen['models']:
   ar['models'][model]={}
   for rep in frozen['repeats']:
    rs=[r for r in cells if r['model_alias']==model and r['repeat']==rep];assert len(rs)==440
    transitions=collections.Counter((verdict(cidx[r['sample_id']]['status']),verdict(r['status']))for r in rs if r['status']!='missing_processed')
    ar['models'][model][str(rep)]={'statuses':dict(collections.Counter(r['status']for r in rs)),'labels':{kind:metrics(rs,labs)for kind,labs in labels.items()},'transitions_from_supplied_query':[{'from':x,'to':y,'count':n}for(x,y),n in sorted(transitions.items())],'exact_status_agreement':sum(r['status']==cidx[r['sample_id']]['status']for r in rs if r['status']!='missing_processed')}
  summary['arms'][arm]=ar
 save(H/'summary.json',summary)
 with(H/'joined-cells.jsonl').open('w')as f:
  for r in joined:f.write(json.dumps(r)+'\n')
 lines=['# End-to-end natural-language specification generation and verification','',summary['unit'],'','All results use original pinned Astrogator with default permission semantics. Each row lists repeats r0/r1/r2; no repeat is selected using local correctness labels.','', '| Guide | Model | Decisions /422 | Accepted local failures | Rejected local passes | Unavailable |','|---|---|---|---|---|---|']
 for arm,ar in summary['arms'].items():
  for model,reps in ar['models'].items():
   mm=[reps[str(i)]['labels']['strict_integrity']for i in range(3)]
   vals=lambda k:' / '.join(str(m[k])for m in mm)
   unavailable=' / '.join(str(m['unavailable_pass']+m['unavailable_fail'])for m in mm)
   lines.append(f'| {arm} | {model} | {vals("decisions")} | {vals("accept_fail")} | {vals("reject_pass")} | {unavailable} |')
 if summary['arms']:
  ref=next(iter(summary['arms'].values()))['control']['strict_integrity'];lines+=['',f'Supplied-query control on the same strict-integrity labels: {ref["decisions"]}/422 decisions; {ref["accept_fail"]} accepted local failures; {ref["reject_pass"]} rejected local passes; {ref["unavailable_pass"]+ref["unavailable_fail"]} unavailable. This is not a gold-correctness guarantee.']
 lines+=['','The table uses strict-integrity labels. Full original-oracle and newline-sensitivity counts, per-repeat stage failures, supplied-query transitions, raw residuals, and all logical cells are retained in the JSON artifacts.','']+['- '+s for s in summary['limitations']]
 (H/'RESULTS.md').write_text('\n'.join(lines)+'\n')
 print(json.dumps({'complete_arms':list(summary['arms']),'joined_processed_cells':len(joined)}))
if __name__=='__main__':main()
