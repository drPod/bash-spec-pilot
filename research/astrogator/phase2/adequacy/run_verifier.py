#!/usr/bin/env python3
import hashlib,json,re,sys,tempfile
from pathlib import Path
import yaml
sys.path.insert(0,'/suite/scripts')
from upstream_eval import verify,probe
ROOT=Path('/suite'); HERE=ROOT/'phase2/adequacy'
for b in json.loads((HERE/'frozen-design.json').read_text())['cases']:
 for query_name,query in b['queries'].items():
  stages=probe(query)
  for program_name,path in b['programs'].items():
   plays=yaml.safe_load((ROOT/path).read_text())
   for p in plays:p.pop('gather_facts',None)
   code=yaml.safe_dump(plays,sort_keys=False)
   with tempfile.NamedTemporaryFile(mode='w',suffix='.yml') as f:
    f.write(code);f.flush();r=verify(query,f.name)
   clean=re.sub(r'\x1b\[[0-9;]*m','',r['stdout'])
   # Keep residual text verbatim. No heuristic claim that its presence implies unsafety.
   print(json.dumps({'task_id':b['task_id'],'query_name':query_name,'query':query,'program_name':program_name,'code_sha256':hashlib.sha256((ROOT/path).read_bytes()).hexdigest(),'normalized_code_sha256':hashlib.sha256(code.encode()).hexdigest(),'normalization':'remove gather_facts only','query_diagnostics':stages,'clean_stdout':clean,**r}),flush=True)
