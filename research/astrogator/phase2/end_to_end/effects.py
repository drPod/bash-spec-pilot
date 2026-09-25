#!/usr/bin/env python3
"""Independent actual semantic-AST diagnostics; no query repair or selection."""
import hashlib,json,sys
from pathlib import Path
sys.path.insert(0,'/suite/scripts');import evaluate_effects as e
H=Path('/suite/phase2/end_to_end');queries={}
for arm in sys.argv[1:]:
 cfg=json.loads((H/f'frozen-{arm}.json').read_text())
 for q in cfg['supplied_queries']+cfg['translations']:
  if q.get('generation_status','ok')=='ok':queries[q['query_sha256']]=q['query']
results={}
for sha,q in queries.items():
 try:r=e.probe(q)
 except Exception as ex:r={'status':'probe_error','error':repr(ex)}
 results[sha]={'query':q,**r}
(H/'effects.json').write_text(json.dumps({'binary_sha256':hashlib.sha256(e.BIN.read_bytes()).hexdigest(),'driver_sha256':hashlib.sha256(Path('/suite/scripts/evaluate_effects.py').read_bytes()).hexdigest(),'queries':results},indent=2)+'\n')
print('Semantic effect probes:',len(results))
