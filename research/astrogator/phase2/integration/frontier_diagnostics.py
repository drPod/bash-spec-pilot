#!/usr/bin/env python3
"""Run inside pinned lab container; JSONL stdout contains real FQL diagnostics."""
import argparse
import json
from pathlib import Path
import sys
sys.path.insert(0,'/suite/scripts')
import upstream_eval as u
import evaluate_effects as e

ROOT=Path('/suite')
p=argparse.ArgumentParser(); p.add_argument('--run',default='phase2/integration/frontier'); args=p.parse_args()
originals={r['id']:r for r in json.loads((ROOT/'benchmarks/original.json').read_text())}
gold={k:e.probe(v['formal_query']) for k,v in originals.items()}
for file in sorted((ROOT/args.run).glob('*/fql-*.json')):
    r=json.loads(file.read_text()); task=r['task']; text=r.get('extracted','')
    generated=e.probe(text) if r['status']=='ok' else {'status':'generation_error'}
    stages=u.probe(text) if r['status']=='ok' else {'returncode':None,'stages':{}}
    reference=gold[task['task_id']]
    diff=e.differences(reference['effects'],generated['effects']) if generated.get('status')=='ok' else None
    print(json.dumps({'path':str(file.relative_to(ROOT)),'task_id':task['task_id'],'repeat':task['repeat'],
        'model':r['model'],'arm':args.run,'generation_status':r['status'],'query':text,'diagnostics':stages,
        'reference':reference,'generated':generated,'differences':diff,'effect_match':diff==[] if diff is not None else False}),flush=True)
