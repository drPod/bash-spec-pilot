#!/usr/bin/env python3
import json,sys,tempfile
from pathlib import Path
import yaml
ROOT=Path('/suite');H=ROOT/'phase2/permission_semantics';A=ROOT/'phase2/adequacy'
sys.path.insert(0,'/suite/scripts');import upstream_eval as u
u.BIN=H/'.cache/bin'
base_call=u.call
constant_modes='--off' not in sys.argv
def guarded_call(argv,*args,**kwargs):
 if constant_modes and argv[0]==str(u.BIN/'verify.exe'):
  argv=list(argv);argv.insert(3,'--constant-modes')
 return base_call(argv,*args,**kwargs)
u.call=guarded_call
def run(task,qn,pn,q,path):
 plays=yaml.safe_load(path.read_text())
 for p in plays:p.pop('gather_facts',None)
 with tempfile.NamedTemporaryFile(mode='w',suffix='.yml')as f:
  yaml.safe_dump(plays,f,sort_keys=False);f.flush()
  print(json.dumps({'task_id':task,'query_name':qn,'program_name':pn,**u.verify(q,f.name)}),flush=True)
if len(sys.argv)>1 and sys.argv[1]=='corpus':
 sys.argv=['upstream_eval.py','corpus'];u.main()
else:
 for b in json.loads((A/'frozen-design.json').read_text())['cases']:
  for qname,q in b['queries'].items():
   for pname,path in b['programs'].items():run(b['task_id'],qname,pname,q,ROOT/path)
 for b in json.loads((A/'mode-design.json').read_text())['cases']:
  q=(ROOT/'benchmarks/expanded'/b['task_id']/'query.fql').read_text()
  run(b['task_id'],'mode_panel',b['mode'],q,ROOT/b['path'])
