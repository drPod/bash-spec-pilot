import json,pathlib,collections,hashlib
p=pathlib.Path(__file__).parent
rows=[json.loads(x) for x in (p/'program-results.jsonl').read_text().splitlines()]
assert len(rows)==32
assert len({(x['task'],x['scenario'],x['variant']) for x in rows})==32
assert all('infrastructure_error' not in x for x in rows)
assert all(z['execution_returncode']==0 for x in rows for z in x['runs'])
refs=[x for x in rows if x['variant']=='reference'];challenges=[x for x in rows if x['variant']=='challenge']
assert all(len(x['runs'])==2 and all(z['strengthened']=='pass' for z in x['runs']) for x in refs)
assert all(len(x['runs'])==1 and x['runs'][0]['strengthened']=='reject' for x in challenges)
summary={'tasks':8,'container_cases':32,'successful_ansible_executions':sum(len(x['runs']) for x in rows),'reference_cases':len(refs),'all_reference_cases_pass_supplemental_checks_twice':True,'challenge_cases':len(challenges),'challenge_cases_rejected_by_supplemental_check':len(challenges),'original_fixture_challenges_accepted_by_old_oracle':sum(x['scenario']=='original' and x['runs'][0]['old']=='pass' for x in challenges),'additional_fixture_challenges_accepted_by_old_oracle':sum(x['scenario']=='heldout' and x['runs'][0]['old']=='pass' for x in challenges),'reference_cases_rejected_by_fixture_specific_old_oracle':[{'task':x['task'],'scenario':x['scenario']} for x in refs if x['runs'][0]['old']=='reject'],'methodological_scope':'Purposively selected oracle-adequacy counterexamples. No random-sample prevalence, independent human gold, authentication proof, or Astrogator soundness claim.'}
(p/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
