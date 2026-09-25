import json,sys,tempfile
from pathlib import Path
import yaml
sys.path.insert(0,'/suite/scripts');import upstream_eval as u
R=Path('/suite');H=R/'phase2/permission_semantics';u.BIN=H/'.cache/bin'
plays=yaml.safe_load((R/'benchmarks/expanded/a32/reference.yml').read_text());plays[0].pop('gather_facts');plays[0]['tasks'][0]['ansible.builtin.file'].pop('mode')
q=(R/'benchmarks/expanded/a32/query.fql').read_text();base=u.call
for flag in [False,True]:
 def call(argv,*a,**kw):
  if flag and argv[0]==str(u.BIN/'verify.exe'):
   argv=list(argv);argv.insert(3,'--constant-modes')
  return base(argv,*a,**kw)
 u.call=call
 with tempfile.NamedTemporaryFile(mode='w',suffix='.yml')as f:
  yaml.safe_dump(plays,f,sort_keys=False);f.flush();r=u.verify(q,f.name)
 print(json.dumps({'task_id':'a32','variant':'reference_without_mode','constant_modes':flag,**r}),flush=True)
