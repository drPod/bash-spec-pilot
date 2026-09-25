#!/usr/bin/env python3
import collections,hashlib,json,subprocess,tempfile
from pathlib import Path
H=Path(__file__).resolve().parent;U=Path('/tmp/astrogator-upstream')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
with tempfile.TemporaryDirectory(prefix='description-guard-check-')as tmp:
 d=Path(tmp)
 for name in ['lib/fql/semant.ml','test/dune']:
  p=d/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((U/name).read_bytes())
 subprocess.run(['git','init','-q',str(d)],check=True);subprocess.run(['git','apply','--check',str(H/'description-guard.patch')],cwd=d,check=True);subprocess.run(['git','apply',str(H/'description-guard.patch')],cwd=d,check=True)
 for p in(H/'source').rglob('*'):
  if p.is_file():assert p.read_bytes()==(d/p.relative_to(H/'source')).read_bytes()
r=json.loads((H/'replay.json').read_text());assert len(r['rows'])==273
changed=[x for x in r['rows']if not x['identical_diagnostics']]
assert len(changed)==3 and all(x['source']=='compact-all'and x['task_id']=='a03'and x['model']=='gpt6'and x['original_lowered']and not x['patched_lowered']for x in changed)
assert {x['repeat']for x in changed}=={0,1,2}
prov=json.loads((H/'source-provenance.json').read_text());assert sha(U/'lib/fql/semant.ml')==prov['original_semant_sha256']
checks=(H/'regressions.txt').read_text().splitlines();assert len(checks)==9 and all(x.startswith('PASS ')for x in checks)
s={'complete':True,'clean_patch_application':True,'patch_matches_delivered_source':True,'original_checkout_unchanged':True,'ocaml_regressions_passed':9,'logical_queries_replayed':273,'unique_binary_query_calls':r['unique_binary_query_calls'],'changed_outputs':3,'unchanged_outputs':270,'all21_supplied_unchanged':True,'all126_handbook_unchanged':True,'changed_queries':[{'source':x['source'],'task_id':x['task_id'],'model':x['model'],'repeat':x['repeat'],'query':x['query']}for x in changed],'status_interpretation':'Semantic query rejection makes the pipeline unavailable. It is not a detected candidate-program error.','projected_compact_gpt_a03_cost_per_repeat':{'previously_accepted_to_unavailable':43,'previously_rejected_to_unavailable':36,'already_unavailable':31},'scope':'Narrow guard for unused description prefix in DeleteFile/DeleteDir explicit-at branches only; no query repair or general descriptor audit.'}
(H/'summary.json').write_text(json.dumps(s,indent=2)+'\n');print(json.dumps(s))
