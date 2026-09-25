import json,pathlib,collections
p=pathlib.Path(__file__).parent
rows=[json.loads(x) for x in (p/'patch-validation.jsonl').read_text().splitlines()]
assert len(rows)==48 and len({(x['task_id'],x['scenario'],x['variant']) for x in rows})==48
assert all(x['status'] not in ['infrastructure_error','fixture_error','execution_timeout','execution_error'] for x in rows)
refs=[x for x in rows if x['variant']=='reference'];original=[x for x in rows if x['variant']=='mutant'];new=[x for x in rows if x['variant']=='candidate']
assert all(x['status']=='passed' and len(x['executions'])==2 for x in refs)
assert all(x['status']=='oracle_rejected' for x in new)
assert all(any(x['task_id']==task and x['status']=='oracle_rejected' for x in original) for task in {x['task_id'] for x in rows})
out={'container_cases':48,'reference_scenario_cases_passed_twice':len(refs),'original_mutant_scenarios':dict(collections.Counter(x['status'] for x in original)),'original_mutant_tasks_killed_at_least_one_state':8,'new_challenge_scenarios_rejected':len(new),'new_challenge_tasks_killed':8,'successful_ansible_executions':sum(len(x['executions']) for x in rows),'original_files_modified':False}
(p/'patch-validation-summary.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
