import pathlib,json,collections
p=pathlib.Path(__file__).parent;rows=[json.loads(l) for l in (p/'review-case-results.jsonl').read_text().splitlines()]
assert len(rows)==14 and len({x['id'] for x in rows})==14
assert all(not x.get('infrastructure_error') for x in rows)
assert all(z['returncode']==0 for x in rows for z in x['iterations'])
counts={}
for version in ['v1','v2']:
 c=collections.Counter()
 for x in rows:
  expected=x['expected_valid_under_declared_fixture_contract'];actual=all(z[version]=='passed' for z in x['iterations']);c['valid_accept' if expected and actual else 'valid_reject' if expected else 'invalid_accept' if actual else 'invalid_reject']+=1
 counts[version]=dict(c)
assert counts['v2']=={'valid_accept':9,'invalid_reject':5},counts
out={'cases':14,'successful_ansible_executions':sum(len(x['iterations']) for x in rows),'case_level_confusion':counts,'oracle_v2_all_expected_outcomes_match':True,'scope':'Targeted review-response panel under declared fixture contracts; not prevalence or gold correctness estimates.'}
(p/'review-case-summary.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
