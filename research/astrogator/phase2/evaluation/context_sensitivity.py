#!/usr/bin/env python3
"""Paired no-context/context sensitivity on the same frozen identity-only subset."""
import argparse
import hashlib
import json
from collections import Counter
from analyze import HERE,stats
from frontier_comparison import paired


def main():
    ap=argparse.ArgumentParser();ap.add_argument('--arm',required=True);args=ap.parse_args()
    assert '/' not in args.arm
    paths=[HERE/'frontier-comparison.json',HERE/(args.arm+'-comparison.json')]
    original,context=[json.loads(p.read_text()) for p in paths]
    assert all(original['complete'].values()) and all(context['complete'].values())
    a={r['sample_id']:r for r in original['samples']};b={r['sample_id']:r for r in context['samples']}
    assert set(a)==set(b) and len(a)==86
    revised=json.loads((HERE/'revised-summary.json').read_text());assert revised['complete']
    changed={r['sample_id']:r for r in revised['samples']}
    rows=[]
    for sid,r in a.items():
        assert r['code_sha256']==b[sid]['code_sha256']
        rows.append({'sample_id':sid,'task_id':r['task_id'],'local_label':r['local_label'],
                     'code_sha256':r['code_sha256'],**{m+'_'+v:d[m] for m in ('gpt6','opus55') for v,d in [('original',r),('context',b[sid])]}})
    variants={'original':rows}
    for field in ('strict_integrity','newline_sensitivity'):
        variants[field]=[{**r,'local_label':changed[r['sample_id']][field] if r['sample_id'] in changed else r['local_label']} for r in rows]
    methods=[m+'_'+v for m in ('gpt6','opus55') for v in ('original','context')]
    result={'processed_programs':86,'selection':'Same frozen indices 0/1 identity subset; no outcome-based selection.',
            'input_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
            'metrics':{v:{m:stats(rs,m) for m in methods} for v,rs in variants.items()},
            'paired':{v:{m:paired(rs,m+'_original',m+'_context') for m in ('gpt6','opus55')} for v,rs in variants.items()},
            'decision_transitions':{m:dict(Counter(r[m+'_original']+' -> '+r[m+'_context'] for r in rows)) for m in ('gpt6','opus55')},
            'changed_samples':{m:[r for r in rows if r[m+'_original']!=r[m+'_context']] for m in ('gpt6','opus55')},
            'limitations':['One independent call per condition and program; changes may reflect both context and sampling variability.',
                           'This is a context sensitivity analysis, not a causal estimate of prompt context benefit.',
                           'The same 86 programs are a subset of the primary 422 cohort, not independent evidence.',
                           'Explicit infrastructure context still does not reveal oracle implementation or resolve every natural-language ambiguity.']}
    (HERE/'context-sensitivity.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Environment-context sensitivity','',
           'The same 86 identity-selected programs are judged with and without explicit execution-environment context. This subset is nested within the 422-program primary cohort. Each condition has one fresh call, so changes cannot be attributed solely to context rather than sampling variation.','',
           '| Original local labels: method/condition | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |',
           '|---|---:|---:|---:|---:|---:|']
    for m,s in result['metrics']['original'].items():lines.append(f"| {m} | {s['accepted_pass']} | {s['accepted_fail']} | {s['rejected_pass']} | {s['rejected_fail']} | {s['unavailable_pass']+s['unavailable_fail']} |")
    lines+=['','Paired discordances, every changed identity, and revised-oracle label sensitivities are in context-sensitivity.json.']
    (HERE/'CONTEXT-SENSITIVITY.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({'programs':86,'transitions':result['decision_transitions']},indent=2))


if __name__=='__main__':main()
