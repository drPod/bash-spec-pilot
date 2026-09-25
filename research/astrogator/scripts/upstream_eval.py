#!/usr/bin/env python3
"""Run actual upstream diagnostics inside lab image; stdout is JSONL only."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import time
import yaml

ROOT=Path('/suite')
UP=Path('/opt/astrogator')
BIN=UP/'_build/default/bin'
MODULES=sorted(str(p) for p in (UP/'modules').glob('*'))


def call(argv,timeout=15):
    start=time.monotonic()
    try:
        r=subprocess.run(argv,capture_output=True,text=True,timeout=timeout)
        return dict(returncode=r.returncode,stdout=r.stdout,stderr=r.stderr,seconds=round(time.monotonic()-start,4))
    except subprocess.TimeoutExpired:
        return dict(returncode=None,stdout='',stderr='timeout',seconds=round(time.monotonic()-start,4))


def probe(text):
    with tempfile.NamedTemporaryFile(mode='w',suffix='.fql') as f:
        f.write(text); f.flush()
        override=ROOT/'.cache/bin/fql_probe.exe'
        r=call([str(override if override.exists() else BIN/'fql_probe.exe'),f.name])
    stages={}
    for line in r['stdout'].splitlines():
        parts=line.split('\t',2)
        if len(parts)==3: stages[parts[0]]={'status':parts[1],'detail':parts[2]}
    return {**r,'stages':stages}


def verify(query,code):
    with tempfile.NamedTemporaryFile(mode='w',suffix='.fql') as f:
        f.write(query); f.flush()
        r=call([str(BIN/'verify.exe'),f.name,str(code),'--',*MODULES])
    r['status']={0:'accepted_with_possible_residuals',1:'module_parse_error',2:'module_lowering_error',
                 3:'query_lowering_error',4:'ansible_lowering_error',5:'verification_rejected',
                 6:'trivial_query',7:'heuristic_rejected',None:'timeout'}.get(r['returncode'],'exception')
    if 'Fatal error: exception' in r['stderr']:
        r['status']='uncaught_exception'
    return r


def main():
    p=argparse.ArgumentParser(); p.add_argument('mode',choices=['queries','corpus','expansion','translations','canonical']); a=p.parse_args()
    originals=json.loads((ROOT/'benchmarks/original.json').read_text())
    expanded=json.loads((ROOT/'benchmarks/expanded.json').read_text())
    def emit(r): print(json.dumps(r),flush=True)
    if a.mode=='queries':
        for b in originals+expanded:
            emit(dict(task_id=b['id'],source='supplied_normalized' if 'legacy_id' in b else 'authored_candidate',query=b['formal_query'],result=probe(b['formal_query'])))
        for b in originals:
            text=(UP/'playbooks/bench'/f"query{b['legacy_id'][1:]}.txt").read_text().strip()
            emit(dict(task_id=b['id'],source='upstream',query=text,result=probe(text),equals_supplied=text==b['formal_query']))
    elif a.mode=='corpus':
        by_id={b['id']:b for b in originals}
        for line in (ROOT/'data/manifest.jsonl').read_text().splitlines():
            r=json.loads(line); b=by_id[r['task_id']]
            if 'response' not in r['artifacts']:
                emit(dict(sample_id=r['sample_id'],task_id=b['id'],status='missing_processed')); continue
            # Declared evaluation-domain substitution, matching Aaron's processed data.
            query=b['formal_query'].replace('http://example.com/','http://acc240.com/') if b['legacy_id']=='p17' else b['formal_query']
            emit(dict(sample_id=r['sample_id'],task_id=b['id'],query_source='normalized_CSV_with_declared_p17_domain',
                      code_sha256=r['artifacts']['response']['sha256'],**verify(query,ROOT/r['artifacts']['response']['path'])))
    elif a.mode=='expansion':
        for b in expanded:
            for variant in ['reference','mutant']:
                path=ROOT/'benchmarks/expanded'/b['id']/f'{variant}.yml'
                original=path.read_text(); plays=yaml.safe_load(original)
                for play in plays: play.pop('gather_facts',None)
                with tempfile.NamedTemporaryFile(mode='w',suffix='.yml') as f:
                    yaml.safe_dump(plays,f,sort_keys=False); f.flush()
                    emit(dict(task_id=b['id'],variant=variant,
                              normalization='remove gather_facts: false for upstream parser; tasks unchanged; no explicit fact-dependent tasks',
                              **verify(b['formal_query'],f.name)))
    elif a.mode=='canonical':
        for row in json.loads((ROOT/'reports/grammar-coverage-v2.json').read_text())['results']:
            before=probe(row['original_query']); after=probe(row['canonical_query'])
            b=before['stages'].get('parse',{}); c=after['stages'].get('parse',{})
            emit(dict(task_id=row['task_id'],before=before,after=after,
                      same_parse_AST=b.get('status')=='ok' and c.get('status')=='ok' and b['detail']==c['detail']))
    else:
        by_id={b['id']:b for b in originals}
        for file in sorted((ROOT/'experiments').glob('*/fql-*/*.json')):
            r=json.loads(file.read_text()); text=file.with_suffix('.fql').read_text()
            gold=probe(by_id[r['task_id']]['formal_query']); generated=probe(text)
            g=gold['stages'].get('semantic',{}); q=generated['stages'].get('semantic',{})
            emit(dict(task_id=r['task_id'],shots=r['shots'],path=str(file.relative_to(ROOT)),
                      exact_semantic_AST_match=(g.get('status')=='ok' and q.get('status')=='ok' and g.get('detail')==q.get('detail')) if g.get('detail')!='unavailable:functional_value' and q.get('detail')!='unavailable:functional_value' else None,
                      exact_parse_AST_match=gold['stages'].get('parse',{}).get('detail')==generated['stages'].get('parse',{}).get('detail'),
                      finish_reason=r.get('finish_reason'),result=generated))


if __name__=='__main__': main()
