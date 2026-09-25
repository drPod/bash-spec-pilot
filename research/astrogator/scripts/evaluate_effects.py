#!/usr/bin/env python3
"""Inspect semantic effects and field-level differences, including KB choices."""
import json
from pathlib import Path
import subprocess
import tempfile

ROOT=Path('/suite')
BIN=ROOT/'.cache/bin/fql_json.exe'
if not BIN.exists(): BIN=Path('/opt/astrogator/_build/default/bin/fql_json.exe')


def probe(text):
    with tempfile.NamedTemporaryFile(mode='w',suffix='.fql') as f:
        f.write(text); f.flush()
        r=subprocess.run([str(BIN),f.name],capture_output=True,text=True,timeout=10)
    try: return json.loads(r.stdout)
    except ValueError: return {'status':'driver_error','stdout':r.stdout,'stderr':r.stderr}


def differences(expected,actual,path='$'):
    if type(expected) is not type(actual):
        return [{'path':path,'expected':expected,'actual':actual}]
    if isinstance(expected,dict):
        result=[]
        for key in sorted(set(expected)|set(actual)):
            if key not in expected or key not in actual:
                result.append({'path':path+'.'+key,'expected':expected.get(key),'actual':actual.get(key),
                               'missing_in':'reference' if key not in expected else 'generated'})
            else: result+=differences(expected[key],actual[key],path+'.'+key)
        return result
    if isinstance(expected,list):
        if len(expected)!=len(actual): return [{'path':path,'expected':expected,'actual':actual,'reason':'different action/list count'}]
        return [d for i,(a,b) in enumerate(zip(expected,actual)) for d in differences(a,b,f'{path}[{i}]')]
    return [] if expected==actual else [{'path':path,'expected':expected,'actual':actual}]


def main():
    gold={b['id']:probe(b['formal_query']) for b in json.loads((ROOT/'benchmarks/original.json').read_text())}
    assert len(gold)==21 and all(r['status']=='ok' for r in gold.values()),gold
    for file in sorted((ROOT/'experiments').glob('*/fql-*/*.json')):
        r=json.loads(file.read_text()); generated=probe(file.with_suffix('.fql').read_text()); expected=gold[r['task_id']]
        delta=differences(expected['effects'],generated['effects']) if generated['status']=='ok' else None
        print(json.dumps({'path':str(file.relative_to(ROOT)),'task_id':r['task_id'],
                          'reference':expected,'generated':generated,
                          'canonical_effect_tree_match':delta==[] if delta is not None else False,
                          'differences':delta}),flush=True)


if __name__=='__main__': main()
