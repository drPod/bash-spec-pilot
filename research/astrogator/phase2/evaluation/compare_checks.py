#!/usr/bin/env python3
"""Compare all methods on the identical known-label intersection for generated checks."""
import argparse
from collections import Counter
import hashlib
import json
from analyze import HERE,ROOT,stats

LABELS={'passed_local_checks','failed_local_checks_or_execution'}
VARIANTS={'original':'new_fixture_original_oracle','strict_integrity':'strict_integrity','newline_sensitivity':'newline_sensitivity'}


def main():
    ap=argparse.ArgumentParser();ap.add_argument('--include-python',action='store_true');args=ap.parse_args()
    paths={'frontier':HERE/'frontier-full-comparison.json','extra':HERE/'additional-baselines.json',
           'dsl':ROOT/'phase2/integration/generated-tests/summary.json','revised':HERE/'revised-summary.json'}
    if args.include_python:paths['python']=ROOT/'phase2/integration/python-tests/summary.json'
    sources={k:json.loads(p.read_text()) for k,p in paths.items()}
    assert all(sources['frontier']['complete'].values()) and all(sources['extra']['complete'].values()) and sources['revised']['complete']
    arms=['dsl']+(['python'] if args.include_python else [])
    for arm in arms:
        assert sources[arm]['complete']
        for name,digest in sources[arm]['output_sha256'].items():assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==digest
    indices={k:{r['sample_id']:r for r in sources[k]['samples']} for k in ('frontier','extra',*arms)}
    revised={r['sample_id']:r for r in sources['revised']['samples']}
    complete_ids=set(indices['frontier'])
    excluded={}
    for arm in arms:
        assert set(indices[arm])==set(indices['frontier'])
        known={sid for sid,r in indices[arm].items() if all(r['labels'].get(v) in LABELS for v in VARIANTS.values())}
        excluded[arm]=sorted(set(indices[arm])-known);complete_ids &= known
    base_methods=('native_syntax','astrogator','astrogator_configured_heuristics','debian_metadata_heuristics','judge','gpt6','opus55')
    check_methods=[arm+'_'+m for arm in arms for m in ('gpt6-r0','gpt6-r1','opus55-r0','opus55-r1')]
    variants={v:[] for v in VARIANTS}
    for sid in sorted(complete_ids):
        f=indices['frontier'][sid];e=indices['extra'][sid]
        for arm in arms:assert f['code_sha256']==indices[arm][sid]['code_sha256']
        assert f['code_sha256']==e['code_sha256']
        for variant,label_field in VARIANTS.items():
            expected=f['local_label'] if variant=='original' or sid not in revised else revised[sid][variant]
            for arm in arms:assert indices[arm][sid]['labels'][label_field]==expected,(sid,variant,'independent label disagreement')
            r={'sample_id':sid,'task_id':f['task_id'],'code_sha256':f['code_sha256'],'local_label':expected}
            for m in base_methods:r[m]=(e if m in ('native_syntax','debian_metadata_heuristics') else f)[m]
            for arm in arms:
                for m in ('gpt6-r0','gpt6-r1','opus55-r0','opus55-r1'):r[arm+'_'+m]=indices[arm][sid][m]
            variants[variant].append(r)
    methods=(*base_methods,*check_methods)
    result={'complete':True,'common_programs':len(complete_ids),'original_programs':422,'excluded_by_arm':excluded,
            'cohort_rule':'Intersection of all programs with resolved labels in each included generated-check execution; every method restricted to the identical IDs.',
            'verifier_mode':'Pinned upstream default permission semantics; configured heuristics named separately.',
            'metrics':{v:{m:stats(rs,m) for m in methods} for v,rs in variants.items()},
            'by_task':{v:{t:{m:stats([r for r in rs if r['task_id']==t],m) for m in methods} for t in ('a01','a02','a06','a17')} for v,rs in variants.items()},
            'label_counts':{v:dict(Counter(r['local_label'] for r in rs)) for v,rs in variants.items()},
            'gates':{arm:sources[arm].get('gates',{}) for arm in arms},'samples':variants,'input_sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths.values()},
            'limitations':['Reference gates use known-good code after generation; no best-of-two candidate-based selection.',
                           'Generated postcondition checks reuse researcher-authored initial-state fixtures; automatic fixture synthesis is not evaluated.',
                           'An execution error rejects under an execution-plus-checks policy, even if no generated assertion executes.',
                           'The complete-case intersection differs from the full 422-program primary cohort; exclusion identities are explicit.',
                           'All resolved test-run labels were checked against the separate oracle study; no discrepancy is silently substituted.',
                           'Repeated test generations share programs and are not independent datasets.']}
    prefix='common-all-checks' if args.include_python else 'common-dsl-checks'
    (HERE/(prefix+'.json')).write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Generated checks on a matched comparison cohort','',
           f"Every method is restricted to the same **{len(complete_ids)} programs** with resolved execution labels in all included check arms. The separate primary judge/verifier table retains 422 programs. Excluded identities: "+'; '.join(arm+': '+(', '.join(ids) or 'none') for arm,ids in excluded.items()),'',
           'Verifier mode: pinned upstream default permission semantics. Check repetitions are shown separately; reference gates supply additional information after generation. These are generated postcondition checks on shared researcher-authored fixtures.','',
           '| Strict-integrity labels: method | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |',
           '|---|---:|---:|---:|---:|---:|']
    for m,s in result['metrics']['strict_integrity'].items():lines.append(f"| {('Qwen 2.5 1.5B judge' if m == 'judge' else m)} | {s['accepted_pass']} | {s['accepted_fail']} | {s['rejected_pass']} | {s['rejected_fail']} | {s['unavailable_pass']+s['unavailable_fail']} |")
    lines+=['','All resolved generated-check execution labels match the independent label source under each declared interpretation. This is a consistency check, not proof that either oracle captures all intended behavior. Original and final-newline sensitivity tables are included in the JSON.']
    if args.include_python:
        lines+=['','Python gate abstentions are distinct from the four unresolved execution-timeout programs excluded above. Opus r0 is unavailable on205resolved programs because a06r0 and a17r0 are ineligible; Opus r1 is unavailable on106because a17r1 is ineligible. These are conservative runner restrictions: a06r0 writes only stdout/stderr but triggers the generic forbidden-call gate; the a17 checks use variables in otherwise read-only getent arguments, rejected by literal-argument validation. The exact-source review found no explicit tested-state mutation. Thus these counts are compatibility limits of this frozen test runner, not demonstrated semantic failures of the generated tests. The gates were not relaxed after outcomes.']
    (HERE/(prefix.upper()+'.md')).write_text('\n'.join(lines)+'\n')
    print(json.dumps({'common_programs':len(complete_ids),'excluded':excluded,'arms':arms},indent=2))


if __name__=='__main__':main()
