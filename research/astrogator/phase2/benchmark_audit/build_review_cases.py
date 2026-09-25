import pathlib,json,yaml
p=pathlib.Path(__file__).parent;root=p.parents[1];d=p/'review-cases';d.mkdir(exist_ok=True)
specs=[
('a24','original','reference',None,True),('a24','original','symlink',"import shutil,os; shutil.rmtree('/work/spool'); os.symlink('/tmp','/work/spool')",False),
('a68','original','reference',None,True),('a68','original','symlink',"import shutil,os; shutil.rmtree('/work/cache'); os.symlink('/tmp','/work/cache')",False),
('a53','original','reference',None,True),('a53','original','dirty_version',"from pathlib import Path; Path('/work/checkout/version').write_bytes(Path('/fixtures/repo/version').read_bytes())",False),
('a53','untracked','reference',None,True),
('a53','extra_tracked','reference',None,True),('a53','extra_tracked','dirty_other',"from pathlib import Path; Path('/work/checkout/other').write_text('changed')",False),
('a70','empty_dirs','reference',None,True),('a70','empty_dirs','omit_empty',"import shutil; shutil.rmtree('/work/dest/empty')",False),
('a70','overlap','reference',None,True),
('a32','executable','reference',None,True),('a32','executable','valid_0744',"import os; os.chmod('/work/tree/run',0o744)",True)]
rows=[]
for task,fixture,name,script,valid in specs:
 cid=f'{task}-{fixture}-{name}';play=yaml.safe_load((root/'benchmarks/expanded'/task/'reference.yml').read_text())
 if script:play[0]['tasks'].append({'name':'Independent review challenge','ansible.builtin.command':{'argv':['python3','-c',script]}})
 (d/f'{cid}.yml').write_text(yaml.safe_dump(play,sort_keys=False));rows.append({'id':cid,'task':task,'fixture':fixture,'name':name,'expected_valid_under_declared_fixture_contract':valid})
(p/'review-case-design.json').write_text(json.dumps(rows,indent=2)+'\n')
