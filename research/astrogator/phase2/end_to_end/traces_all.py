#!/usr/bin/env python3
"""Descriptive all-task transitions, with no new correctness labels."""
import json,re
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[1]
def read(p):return json.loads(p.read_text())
def rows(p):return [json.loads(x)for x in p.read_text().splitlines()]
s=read(H/'all-summary.json');original={x['id']:x for x in read(R/'benchmarks/original.json')};manifest={x['sample_id']:x for x in rows(R/'data/manifest.jsonl')};effects=read(H/'effects.json')['queries'];traces=[]
for arm in s['arms']:
 f=read(H/f'frozen-{arm}.json');qi={(x['model_alias'],x['repeat'],x['task_id']):x for x in f['translations']};groups={}
 for c in rows(H/f'changed-cells-{arm}.jsonl'):
  key=(c['task_id'],c['query_sha256'],c['supplied_query_status'],c['status']);groups.setdefault(key,c)
 for key,c in sorted(groups.items()):
  q=qi[c['model_alias'],c['repeat'],c['task_id']];path=manifest[c['sample_id']]['artifacts']['response']['path'];sup=read(R/c['supplied_query_result_path'])if c.get('supplied_query_result_path')else None;gen=read(R/c['verifier_result_path'])if c.get('verifier_result_path')else None;diag=read(R/c['query_diagnostics_path'])if c.get('query_diagnostics_path')else None
  traces.append({'cell':c,'natural_language':original[c['task_id']]['natural_language'],'query':q['query'],'supplied_query':original[c['task_id']]['formal_query'],'generation_record':q['snapshot'],'program_path':path,'program':(R/path).read_text(),'generated_effects':effects.get(q['query_sha256']),'generated_verifier':gen,'supplied_verifier':sup,'query_diagnostics':diag,'behavioral_label':'Not assigned in this21-task paired decision analysis; four-task labels are reported separately.'})
(H/'all-traces.json').write_text(json.dumps({'selection':'First encountered sample for each task/query/exact-status transition, for descriptive inspection only. Not independent examples and not labels.','traces':traces},indent=2)+'\n')
lines=['# Traced paired-decision changes across21 tasks','','These transitions show downstream consequences of generated specifications. They do not establish which decision is correct. Full raw diagnostics, normalized effect proxies, candidate programs, and residual branches are in `all-traces.json`.','']
# Show one trace per task and resulting status; full query/repeat variants remain JSON.
seen=set()
for t in traces:
 c=t['cell'];k=(c['arm'],c['task_id'],c['supplied_query_status'],c['status'])
 if k in seen:continue
 seen.add(k);ev=t['generated_verifier']or(t['query_diagnostics']or{}).get('diagnostics',{});raw=re.sub(r'\x1b\[[0-9;]*m','',ev.get('stdout','')+'\n'+ev.get('stderr','')).strip()
 lines += [f'## {c["arm"]}: {c["task_id"]}, {c["sample_id"]}', '',f'{c["model_alias"]}, r{c["repeat"]}: `{c["supplied_query_status"]}` → `{c["status"]}`.','',t['natural_language'],'','Supplied query:','```',t['supplied_query'],'```','Generated query:','```',t['query'],'```','Diagnostic/verifier excerpt:','```',raw[:1500],'```','']
(H/'ALL-TRACES.md').write_text('\n'.join(lines)+'\n');print('All-task descriptive traces',len(traces))
