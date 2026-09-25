import pathlib,json,collections
p=pathlib.Path(__file__).parent;rows=[json.loads(l) for l in (p/'review-case-results-v3.jsonl').read_text().splitlines()]
assert len(rows)==20 and len({x['id'] for x in rows})==20
assert all(not x.get('infrastructure_error') for x in rows)
assert all(z['returncode']==0 for x in rows for z in x['iterations'])
def counts(group):
 out={}
 for version in ['v2','v3']:
  c=collections.Counter()
  for x in group:
   valid=x['expected_valid_under_declared_fixture_contract'];accepted=all(z[version]=='passed' for z in x['iterations']);c['valid_accept' if valid and accepted else 'valid_reject' if valid else 'contract_violation_accept' if accepted else 'contract_violation_reject']+=1
  out[version]=dict(c)
 return out
c=counts(rows);assert c['v3']=={'valid_accept':12,'contract_violation_reject':8},c
out={'cases':20,'successful_ansible_executions':sum(len(x['iterations']) for x in rows),'case_level_outcomes_under_declared_contract':c,'excluding_source_addition_interpretive_case':counts([x for x in rows if not x.get('interpretive_contract_case')]),'interpretive_case_ids':[x['id'] for x in rows if x.get('interpretive_contract_case')],'all_v3_expected_outcomes_match':True,'scope':'Purposive review-response cases; direct-directory and unchanged-source contracts are explicit interpretations, not independent human gold.'}
(p/'review-case-summary-v3.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
