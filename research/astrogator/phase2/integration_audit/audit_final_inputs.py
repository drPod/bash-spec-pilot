#!/usr/bin/env python3
"""Independent final figure, mechanism and local manifest checks."""
import csv
import hashlib
import json
from pathlib import Path
from datetime import datetime,timezone
R=Path(__file__).resolve().parents[2];P=R/'phase2';H=Path(__file__).resolve().parent

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def main():
 issues=[];details={}
 def check(ok,message):
  if not ok:issues.append(message)
 s=read(P/'end_to_end/all-summary.json');t=read(P/'integration/translation-summary.json')
 for folder,script in [('figures-paper','plot_paper_contribution.py'),('figures-pipeline','plot_pipeline.py'),('figures-all-checks','plot_checks.py'),('figures-dsl-checks','plot_checks.py'),('figures','plot_evaluation.py')]:
  b=P/'evaluation'/folder;m=read(b/'manifest.json')
  hashes=m['input_sha256'] if isinstance(m['input_sha256'],dict) else {m['source']:m['input_sha256']}
  for p,h in hashes.items():check(sha(Path(p) if Path(p).is_absolute() else P/'evaluation'/p)==h,'Figure input changed: '+p)
  check(sha(P/'evaluation'/script)==m['script_sha256'],'Figure script changed: '+script)
  for p,h in m['files'].items():check(sha(b/p)==h,'Figure artifact changed: '+str(b/p))
  details[folder]={'inputs':hashes,'artifacts':len(m['files'])}
 models={'gpt6':'gpt-6-astra','opus55':'claude-opus-5-5'}
 with (P/'evaluation/figures-paper/paper-contribution.csv').open() as f:
  rows=list(csv.DictReader(f))
  check(len(rows)==12,'Paper figure must contain12 model/guide/repeat rows')
  for row in rows:
   a=s['arms'][row['guide']+'-all']['models'][row['model']][row['repeat']]
   b=t['arms'][row['guide']+'/'+models[row['model']]]['per_repeat'][row['repeat']]
   for k in ['parsed','lowered','effect_match']:check(int(row[k])==b[k],'Translation figure count '+str(row))
   for k,v in a['reference_decided'].items():check(int(row[k])==v,'Paired figure count '+str(row))
 with (P/'evaluation/figures-pipeline/pipeline-stages.csv').open() as f:
  rows=list(csv.DictReader(f));check(len(rows)==14,'Pipeline figure rows: two controls and12 conditions')
  for row in rows:
   if row['model']=='supplied_query_control':
    check([int(row[k]) for k in ['accept','reject','unavailable']]==[900,628,710],'Control figure counts')
    continue
   a=s['arms'][row['guide']]['models'][row['model']][row['repeat']]
   check(int(row['accept'])==a['statuses'].get('accepted_with_possible_residuals',0),'Pipeline accepts')
   check(int(row['reject'])==a['statuses'].get('verification_rejected',0),'Pipeline rejects')
   check(int(row['unavailable'])==2238-a['decisions'],'Pipeline unavailable')
 b=P/'end_to_end';f=read(b/'a03-runtime-frozen.json');x=read(b/'a03-runtime-results.json');m=read(b/'a03-mechanism.json')
 check(sha(R/f['candidate']['path'])==f['candidate']['sha256'],'a03 candidate changed')
 check(sha(b/'a03_runtime.py')==f['driver_sha256'],'a03 runtime driver changed')
 check(x['frozen_sha256']==sha(b/'a03-runtime-frozen.json'),'a03 runtime frozen hash')
 check(m['frozen']==f and m['runtime']==x,'a03 mechanism joined source')
 check(len(x['results'])==2,'a03 fixture count')
 check(all(c['returncode']==0 and c['before']['root_is_directory'] and not c['after']['root_exists'] for c in x['results']),'a03 operational counterexample')
 check(m['compact_verifier']['status']=='accepted_with_possible_residuals','a03 compact acceptance')
 check(m['supplied_verifier']['status']=='verification_rejected','a03 supplied rejection')
 check(len(m['handbook'])==6 and all(q['verifier']['status']=='verification_rejected' for q in m['handbook']),'a03 six handbook rejections')
 details['a03']={'runtime_cases':2,'selected_after_disagreement':True,'compact_acceptance_is_conditional':True}
 manifests={}
 for p in P.rglob('*MANIFEST*.json'):
  data=read(p)
  if not isinstance(data,dict) or not all(isinstance(v,str) and len(v)==64 for v in data.values()):continue
  missing=[];excluded=[];mismatch=[]
  for name,h in data.items():
   q=p.parent/name
   if any(part in ('__pycache__','.cache','.venv') for part in Path(name).parts):excluded.append(name)
   if not q.exists():missing.append(name)
   elif sha(q)!=h:mismatch.append(name)
  manifests[str(p.relative_to(R))]={'files':len(data),'missing':missing,'packaging_excluded':excluded,'mismatched':mismatch,'historical_snapshot_manifest':'archive' in p.parts}
  check((not missing or 'archive' in p.parts) and not excluded and not mismatch,'Manifest issue: '+str(p.relative_to(R)))
 for record in read(H/'python-source-review.json')['records']:
  check(sha(R/record['source'])==record['source_sha256'],'Reviewed Python source changed: '+record['source'])
 amendment=read(P/'integration/python-concurrency-amendment.json')
 check(amendment['new_workers']==3 and amendment['per_container_cpu']==.5 and amendment['per_container_memory']=='320m','Concurrency resource amendment changed')
 details['python_concurrency']={'workers':3,'per_container_cpu':.5,'per_container_memory':'320m','interrupted_uncommitted_containers':len(amendment['interrupted_containers'])}
 guard=read(P/'description_guard/summary.json')
 replay=read(P/'description_guard/replay.json')
 changed=[row for row in replay['rows'] if not row['identical_diagnostics']]
 check(guard['complete'] and len(replay['rows'])==273 and len(changed)==3,'Description guard replay counts')
 check(all(row['source']=='compact-all' and row['task_id']=='a03' and row['model']=='gpt6' and row['original_lowered'] and not row['patched_lowered'] for row in changed),'Description guard changed unexpected queries')
 check(guard['all21_supplied_unchanged'] and guard['all126_handbook_unchanged'],'Description guard compatibility')
 details['description_guard']={'compiled_regressions':guard['ocaml_regressions_passed'],'paired_queries':273,'changes_to_unavailable':3,'main_verifier_results_unchanged':True}
 common=read(P/'evaluation/common-all-checks.json')
 for name,h in common['input_sha256'].items():check(sha(R/name)==h,'Common-cohort input changed: '+name)
 arm_sources={name:read(P/'integration'/directory/'summary.json') for name,directory in [('dsl','generated-tests'),('python','python-tests')]}
 resolved={name:{row['sample_id'] for row in source['samples'] if row['labels']['strict_integrity']!='unresolved'} for name,source in arm_sources.items()}
 expected=resolved['dsl'] & resolved['python']
 check(len(expected)==416 and common['common_programs']==416,'Common cohort size')
 by_arm={name:{row['sample_id']:row for row in source['samples']} for name,source in arm_sources.items()}
 for variant,rows in common['samples'].items():
  check(len(rows)==416 and {row['sample_id'] for row in rows}==expected,'Common cohort identities: '+variant)
  label_variant='new_fixture_original_oracle' if variant=='original' else variant
  for row in rows:
   for arm,source in by_arm.items():
    original=source[row['sample_id']]
    check(row['local_label']==original['labels'][label_variant],'Common cohort label mismatch: '+row['sample_id'])
    for method in ('gpt6-r0','gpt6-r1','opus55-r0','opus55-r1'):
     check(row[arm+'_'+method]==original[method],'Generated-test verdict mismatch: '+row['sample_id'])
 with (P/'evaluation/figures-all-checks/matched-checks.csv').open() as f:
  for row in csv.DictReader(f):
   metrics=common['metrics']['strict_integrity'][row['method']]
   for key,value in metrics.items():
    expected_value='' if value is None else str(value)
    check(row[key]==expected_value,'Common-cohort figure count: '+row['method']+'/'+key)
 details['common_check_cohort']={'programs':416,'dsl_resolved':len(resolved['dsl']),'python_resolved':len(resolved['python']),'identities_and_all_generated_verdicts_verified':True}
 result={'checked_at':datetime.now(timezone.utc).isoformat(),'issues':issues,'figures_and_mechanism':details,'local_manifests':manifests}
 (H/'final-inputs-audit.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));return bool(issues)
if __name__=='__main__':raise SystemExit(main())
