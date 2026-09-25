import pathlib,json,yaml,shutil
p=pathlib.Path(__file__).parent;root=p.parents[1];d=p/'review-cases-v3';d.mkdir(exist_ok=True)
rows=json.loads((p/'review-case-design.json').read_text())
for row in rows:shutil.copy2(p/'review-cases'/f"{row['id']}.yml",d/f"{row['id']}.yml")
specs=[
('a53','extra_tracked','skip_reference',None,True),
('a53','extra_tracked','skip_flag_only',"import subprocess; subprocess.run(['git','-C','/work/checkout','update-index','--skip-worktree','other'],check=True)",True),
('a53','extra_tracked','skip_then_edit',"import subprocess,pathlib; subprocess.run(['git','-C','/work/checkout','update-index','--skip-worktree','other'],check=True); pathlib.Path('/work/checkout/other').write_text('undetected change')",False),
('a70','original','alias_reference',None,True),
('a70','original','destination_alias',"import pathlib,shutil,os; shutil.copy2('/work/dest/keep','/work/source/keep'); shutil.rmtree('/work/dest'); os.symlink('/work/source','/work/dest')",False),
('a70','original','source_extra',"import pathlib; pathlib.Path('/work/source/extra').write_text('new')",False)]
for task,fixture,name,script,valid in specs:
 cid=f'{task}-{fixture}-{name}';play=yaml.safe_load((root/'benchmarks/expanded'/task/'reference.yml').read_text())
 if script:play[0]['tasks'].append({'name':'Second review challenge','ansible.builtin.command':{'argv':['python3','-c',script]}})
 (d/f'{cid}.yml').write_text(yaml.safe_dump(play,sort_keys=False));rows.append({'id':cid,'task':task,'fixture':fixture,'name':name,'expected_valid_under_declared_fixture_contract':valid,'interpretive_contract_case':name=='source_extra'})
(p/'review-case-design-v3.json').write_text(json.dumps(rows,indent=2)+'\n')
s=(p/'container_review_cases.py').read_text().replace('review-case-design.json','review-case-design-v3.json').replace("('v1',p/'v1/patched-suite'),('v2',p/'patched-suite')", "('v2',p/'v2/patched-suite'),('v3',p/'patched-suite')").replace("p/'review-cases'", "p/'review-cases-v3'").replace("spec['name']=='reference' or spec['name']=='valid_0744'", "spec['expected_valid_under_declared_fixture_contract']").replace("['v1','v2']","['v2','v3']")
(p/'container_review_cases_v3.py').write_text(s)
s=(p/'run_review_cases.py').read_text().replace('review-case-results.jsonl','review-case-results-v3.jsonl').replace('review-case-design.json','review-case-design-v3.json').replace('container_review_cases.py','container_review_cases_v3.py').replace("x.get('v1'),x.get('v2')","x.get('v2'),x.get('v3')")
(p/'run_review_cases_v3.py').write_text(s)
