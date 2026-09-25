import copy,json
from pathlib import Path
import yaml
H=Path(__file__).resolve().parent;ROOT=H.parents[1]
rows=[]
for task,modes in {'a23':['u=rwX,g=rwXs','u=rwX,g=rwXs,o='],'a47':['u=rwX','u=rwX,g=,o=']}.items():
 for i,mode in enumerate(modes):
  plays=yaml.safe_load((ROOT/'benchmarks/expanded'/task/'reference.yml').read_text());plays[0]['tasks'][-1]['ansible.builtin.file']['mode']=mode
  p=H/'review-cases'/task/f'case{i}.yml';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(yaml.safe_dump(plays,sort_keys=False))
  rows.append({'task_id':task,'program_name':mode,'path':str(p.relative_to(ROOT))})
plays=yaml.safe_load((ROOT/'benchmarks/expanded/a32/reference.yml').read_text());first=copy.deepcopy(plays[0]['tasks'][0]);first['ansible.builtin.file']['mode']='a+x';plays[0]['tasks'].insert(0,first)
p=H/'review-cases/a32/history.yml';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(yaml.safe_dump(plays,sort_keys=False));rows.append({'task_id':'a32','program_name':'add_execute_then_conditional_X','path':str(p.relative_to(ROOT))})
(H/'review-design.json').write_text(json.dumps(rows,indent=2)+'\n')
