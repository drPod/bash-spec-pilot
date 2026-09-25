#!/usr/bin/env python3
"""Paired generated-check metrics; never infer a test verdict from oracle labels."""
from collections import Counter
import json
from pathlib import Path
import sys
from frontier import ROOT, save
from run_tests import DEST
sys.path.insert(0,str(ROOT/'phase2/evaluation'))
from analyze import stats

BAD={'fixture_error','harness_error','execution_timeout'}

def label(cases, variant):
    if len(cases)!=2 or any(c['status'] in BAD for c in cases): return 'unresolved'
    if any(c['status']=='execution_error' for c in cases): return 'failed_local_checks_or_execution'
    flags=[]
    for c in cases:
        ok=c.get('original_oracle') is True
        if variant=='strict_integrity' and c['task_id']=='a17': ok=c.get('observations',{}).get('strict_oracle') is True
        if variant=='newline_sensitivity':
            if c['task_id']=='a17': ok=c.get('observations',{}).get('strict_oracle') is True
            elif c['task_id']=='a06': ok=c.get('observations',{}).get('single_final_newline_tolerant') is True
        flags.append(ok)
    return 'passed_local_checks' if all(flags) else 'failed_local_checks_or_execution'

def verdict(cases,key,gate):
    if not gate['eligible']: return 'reference_gate_abstention'
    if len(cases)!=2 or any(c['status'] in BAD for c in cases): return 'execution_unavailable'
    if any(c['status']=='execution_error' for c in cases): return 'reject'
    tests=[c.get('generated_tests',{}).get(key,{}) for c in cases]
    if any(t.get('status')!='evaluated' for t in tests): return 'test_unavailable'
    return 'accept' if all(t['passed'] for t in tests) else 'reject'

def main():
    config=json.loads((DEST/'frozen.json').read_text()); gates=json.loads((DEST/'gates.json').read_text())
    for relative,expected in config['source_sha256'].items():
        assert __import__('hashlib').sha256((ROOT/relative).read_bytes()).hexdigest()==expected, 'Changed frozen source: '+relative
    for name,expected in config['check_sha256'].items():
        assert __import__('hashlib').sha256((DEST/'specifications'/name).read_bytes()).hexdigest()==expected, 'Changed generated test: '+name
    rows=[r for r in map(json.loads,(ROOT/'data/manifest.jsonl').read_text().splitlines()) if r['task_id'] in ['a01','a02','a06','a17'] and 'response' in r['artifacts']]
    cases={}; outputs={}
    import hashlib
    for p in sorted((DEST/'cases').glob('*.json')):
        r=json.loads(p.read_text()); key=(r['sample_id'],r['scenario']); assert key not in cases
        cases[key]=r; outputs[str(p.relative_to(ROOT))]=hashlib.sha256(p.read_bytes()).hexdigest()
    complete=len(cases)==2*len(rows)
    joined=[]; methods=[f'{m}-r{i}' for m in ['gpt6','opus55'] for i in range(2)]
    for row in rows:
        cs=[cases[(row['sample_id'],s)] for s in ['baseline','adversarial'] if (row['sample_id'],s) in cases]
        for c in cs:
            if c.get('candidate_sha256'): assert c['candidate_sha256']==row['artifacts']['response']['sha256']
        item={'sample_id':row['sample_id'],'task_id':row['task_id'],'code_sha256':row['artifacts']['response']['sha256'],
              'labels':{v:label(cs,v) for v in ['new_fixture_original_oracle','strict_integrity','newline_sensitivity']}}
        for method in methods:
            m,repeat=method.split('-'); key=f'{m}-{config.get("generation_mode","checks")}-{row["task_id"]}-{repeat}'
            item[method]=verdict(cs,key,gates[key])
        joined.append(item)
    result={'complete':complete,'expected_programs':len(rows),'expected_cases':len(rows)*2,'observed_cases':len(cases),
            'gates':gates,'case_statuses':dict(Counter(c['status'] for c in cases.values())),
            'metrics':{},'by_task':{},'unresolved_labels':{},'samples':joined,'output_sha256':outputs,
            'generation_mode':config.get('generation_mode','checks'),
            'limitations':['Python tests under a declared read-only static screen and bounded execution.' if config.get('generation_mode')=='python' else 'Declarative read-only check language, not unrestricted Python test generation.',
                'Known-good reference gate supplies additional information after generation.',
                'Execution errors reject independently of generated assertions; separate from semantic detection.',
                'Two complete independently generated test sets per model; no best-of-two selection.',
                'Password predicate can miss structural damage; strengthened oracle is deliberately separate.',
                'Tests and independent oracle inspect the same fresh execution, so paired labels need not equal older fixture labels.',
                'Four original tasks only; passing these checks does not prove universal correctness.']}
    if complete:
        for variant in ['new_fixture_original_oracle','strict_integrity','newline_sensitivity']:
            result['unresolved_labels'][variant]=sum(r['labels'][variant]=='unresolved' for r in joined)
            rs=[{**r,'local_label':r['labels'][variant]} for r in joined if r['labels'][variant]!='unresolved']
            result['metrics'][variant]={m:stats(rs,m) for m in methods}
            result['by_task'][variant]={t:{m:stats([r for r in rs if r['task_id']==t],m) for m in methods} for t in ['a01','a02','a06','a17']}
    save(DEST/'summary.json',result)
    lines=['# Frontier-generated '+('Python tests' if config.get('generation_mode')=='python' else 'declarative checks'),'',f'Complete: {complete}. {len(cases)}/{len(rows)*2} candidate-state executions; {sum(g["eligible"] for g in gates.values())}/16 check sets pass the reference gate.','',
        '| Label interpretation | Test set | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |','|---|---|---:|---:|---:|---:|---:|']
    for v,ms in result['metrics'].items():
        for m,s in ms.items(): lines.append(f'| {v} | {m} | {s["accepted_pass"]} | {s["accepted_fail"]} | {s["rejected_pass"]} | {s["rejected_fail"]} | {s["unavailable_pass"]+s["unavailable_fail"]} |')
    lines+=['', 'Completeness above means every selected candidate-state has a terminal record; it does not mean every execution produced a usable label.']
    for variant, count in result['unresolved_labels'].items():
        lines.append(f'- {variant}: {len(rows)-count}/{len(rows)} programs have resolved labels; {count} unresolved programs are excluded from that metric table, not counted as correct or incorrect.')
    lines+=['']+['- '+s for s in result['limitations']]
    (DEST/'RESULTS.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({'complete':complete,'cases':len(cases),'expected':len(rows)*2}))

if __name__=='__main__': main()
