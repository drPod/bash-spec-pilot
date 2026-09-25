#!/usr/bin/env python3
import json,sys,tempfile
from pathlib import Path
import yaml
sys.path.insert(0,'/suite/scripts');import upstream_eval as u
ROOT=Path('/suite');HERE=ROOT/'phase2/adequacy'
u.BIN=HERE/'.cache/bin'
def run(task,qname,pname,q,path):
 plays=yaml.safe_load((ROOT/path).read_text())
 for p in plays:p.pop('gather_facts',None)
 with tempfile.NamedTemporaryFile(mode='w',suffix='.yml') as f:
  yaml.safe_dump(plays,f,sort_keys=False);f.flush()
  print(json.dumps({'task_id':task,'query_name':qname,'program_name':pname,**u.verify(q,f.name)}),flush=True)
for b in json.loads((HERE/'frozen-design.json').read_text())['cases']:
 for qname,q in b['queries'].items():
  for pname,path in b['programs'].items():run(b['task_id'],qname,pname,q,path)
for b in json.loads((HERE/'mode-design.json').read_text())['cases']:
 q=(ROOT/'benchmarks/expanded'/b['task_id']/'query.fql').read_text()
 run(b['task_id'],'mode_panel',b['mode'],q,b['path'])
