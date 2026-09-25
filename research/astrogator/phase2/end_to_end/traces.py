#!/usr/bin/env python3
"""Post-hoc descriptive traces; never feeds back into generation or query choice."""
import collections,json,re
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[1]
def rows(p):return [json.loads(l)for l in p.read_text().splitlines()]
def main():
 summary=json.loads((H/'summary.json').read_text());cells=rows(H/'joined-cells.jsonl');effects=json.loads((H/'effects.json').read_text())['queries']
 originals={r['id']:r for r in json.loads((R/'benchmarks/original.json').read_text())};manifest={r['sample_id']:r for r in rows(R/'data/manifest.jsonl')}
 oldex=collections.defaultdict(list)
 for n,r in enumerate(rows(R/'experiments/four-task-full-v1/execution.jsonl'),1):oldex[r['sample_id']].append({'line':n,'scenario':r['scenario'],'status':r['status'],'error':r.get('error'),'input_sha256':r.get('input_sha256')})
 revised=collections.defaultdict(list)
 for p in [R/'phase2/evaluation/revised-execution.jsonl',R/'phase2/evaluation/revised-infra-retries.jsonl']:
  for n,r in enumerate(rows(p),1):
   if 'sample_id'in r:revised[r['sample_id']].append({'source':str(p.relative_to(R)),'line':n,'scenario':r['scenario'],'status':r['status'],'before':r.get('before'),'after':r.get('after'),'returncode':r.get('execution',{}).get('returncode')})
 translations={(arm,q['model_alias'],q['repeat'],q['task_id']):q for arm,a in summary['arms'].items()for q in a['query_outputs']}
 controls={r['sample_id']:r for r in rows(H/f'control-{next(iter(summary["arms"]))}.jsonl')}
 def category(c):
  if c['status'].startswith('query_')or c['status']=='generation_error':return 'query_unavailable'
  if c['status']=='ansible_lowering_error':return 'program_lowering_unavailable'
  if c['status']=='accepted_with_possible_residuals'and c['supplied_query_status']!='accepted_with_possible_residuals':return 'new_acceptance'
  if c['status']=='verification_rejected'and c['supplied_query_status']=='accepted_with_possible_residuals':return 'new_rejection'
  return 'unchanged_status'
 # One lexicographically first example per distinct query+transition+strict label;
 # prioritize changed decisions, while retaining unchanged local-failure examples.
 groups={}
 for c in sorted(cells,key=lambda x:(x['arm'],x['model_alias'],x['repeat'],x['sample_id'])):
  key=(c['query_sha256'],category(c),c['supplied_query_status'],c['labels']['strict_integrity'])
  if category(c)!='unchanged_status'or c['labels']['strict_integrity']=='failed_local_checks_or_execution':groups.setdefault(key,c)
 chosen=sorted(groups.values(),key=lambda c:({'new_acceptance':0,'new_rejection':1,'query_unavailable':2,'program_lowering_unavailable':3,'unchanged_status':4}[category(c)],c['arm'],c['model_alias'],c['repeat'],c['sample_id']))[:10]
 traces=[]
 for c in chosen:
  q=translations[c['arm'],c['model_alias'],c['repeat'],c['task_id']];old=controls[c['sample_id']];sq=originals[c['task_id']]['formal_query'];eff=effects.get(c['query_sha256'],{});ref=next((v for v in effects.values()if v['query']==sq),{})
  generated_result=json.loads((R/c['verifier_result_path']).read_text())if c.get('verifier_result_path')else None
  control_result=json.loads((R/old['verifier_result_path']).read_text())if old.get('verifier_result_path')else None
  traces.append({'category':category(c),'cell':c,'natural_language':originals[c['task_id']]['natural_language'],'generated_query':q['query'],'supplied_query':sq,'semantic_effect_proxy_match':eff.get('effects')==ref.get('effects')if eff.get('status')==ref.get('status')=='ok'else None,'generated_effects':eff,'supplied_effects':ref,'program_path':manifest[c['sample_id']]['artifacts']['response']['path'],'program':(R/manifest[c['sample_id']]['artifacts']['response']['path']).read_text(),'generated_verifier':generated_result,'supplied_verifier':control_result,'original_runtime_cases':oldex[c['sample_id']],'revised_runtime_cases':revised[c['sample_id']],'original_check_path':f'benchmarks/original-pilot/{c["task_id"]}/check.py','original_checks':(R/f'benchmarks/original-pilot/{c["task_id"]}/check.py').read_text(),'revised_check_source':'phase2/evaluation/revised_case.py'if c['task_id']in ['a06','a17']else None})
 (H/'traces.json').write_text(json.dumps({'selection':'Descriptive post-hoc traces, firstsample perdistinctquery/transition/strictlabel; prioritizeschanges. No effect on inference,queryselection,or scoring.','traces':traces},indent=2)+'\n')
 lines=['# Traced end-to-end outcomes','', 'These are descriptive post-hoc examples, not an additional evaluation set. Full original and generated verifier residuals and runtime observations are in `traces.json`.','']
 for t in traces:
  c=t['cell'];lines += [f'## {c["arm"]} / {c["model_alias"]} / repeat{c["repeat"]}: {c["sample_id"]}','',f'Category: **{t["category"]}**. Supplied query: `{c["supplied_query_status"]}`. Generated query: `{c["status"]}`. Strict local label: `{c["labels"]["strict_integrity"]}`.', '', 'Natural language: '+t['natural_language'],'','Generated FQL:','```',t['generated_query'],'```','Supplied FQL control:','```',t['supplied_query'],'```',f'Normalized semantic-effect agreement proxy: {t["semantic_effect_proxy_match"]}. This is not a proof of intent equivalence.','', 'Runtime cases: '+', '.join(r['scenario']+'='+r['status']for r in t['original_runtime_cases'])+'.','']
 # Append one compact evidence block per selected trace. Full branch trees remain JSON.
 for t in traces:
  c=t['cell'];ev=t['generated_verifier']
  if ev is None and c.get('query_diagnostics_path'):
   ev=json.loads((R/c['query_diagnostics_path']).read_text())['diagnostics']
  evidence=re.sub(r'\x1b\[[0-9;]*m','',(ev or {}).get('stdout','')+'\n'+(ev or {}).get('stderr','')).strip()
  lines += [f'### Evidence: {c["arm"]} / {c["model_alias"]} / r{c["repeat"]} / {c["sample_id"]}', '', 'First1,200 characters of generated-query stage/verifier output (full residual branches remain in JSON):','```',evidence[:1200],'```','Original local checks:','```python',t['original_checks'].strip(),'```','']
 (H/'TRACES.md').write_text('\n'.join(lines)+'\n');print('Traces:',len(traces))
if __name__=='__main__':main()
