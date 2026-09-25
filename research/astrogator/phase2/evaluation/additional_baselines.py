#!/usr/bin/env python3
"""Join native syntax checks and a metadata-only ablation without changing old labels."""
from collections import Counter
import hashlib
import json
from analyze import HERE, ROOT, enrich, stats


def load(path):return [json.loads(s) for s in path.read_text().splitlines()] if path.exists() else []


def main():
    rows=enrich(json.loads((ROOT/'reports/four-task-comparison.json').read_text())['samples'])
    index={r['sample_id']:r for r in rows}
    syntax=load(HERE/'syntax-baseline.jsonl');controls=[r for r in syntax if r['kind']=='reference']
    sources={'native_syntax':[r for r in syntax if r['kind']=='candidate'],
             'debian_metadata_heuristics':load(HERE/'debian-heuristics.jsonl')}
    complete={}
    mapping={'syntax_pass':'accept','syntax_reject':'reject','accepted_with_possible_residuals':'accept',
             'verification_rejected':'reject','heuristic_rejected':'reject','ansible_lowering_error':'unsupported_or_error'}
    for method,observations in sources.items():
        by_id={r['sample_id']:r for r in observations};assert len(by_id)==len(observations)
        assert set(by_id)<=set(index)
        for sid,r in by_id.items():assert r['code_sha256']==index[sid]['code_sha256']
        complete[method]=set(by_id)==set(index)
        if method=='native_syntax' and complete[method]:
            assert len(controls)==4 and all(r['status']=='syntax_pass' for r in controls)
        for r in rows:r[method]=mapping.get(by_id[r['sample_id']]['status'],'unavailable') if r['sample_id'] in by_id else 'pending'
    methods=('astrogator','astrogator_configured_heuristics','judge',*sources)
    variants={'original':rows}
    revised_path=HERE/'revised-summary.json'
    revised=json.loads(revised_path.read_text()) if revised_path.exists() else {'complete':False}
    if revised['complete']:
        changed={s['sample_id']:s for s in revised['samples']}
        for f in ('strict_integrity','newline_sensitivity'):
            variants[f]=[{**r,'local_label':changed[r['sample_id']][f] if r['sample_id'] in changed else r['local_label']} for r in rows]
    result={'complete':complete,'expected_programs':422,'observed':{m:len(rs) for m,rs in sources.items()},
            'verifier_mode':'Pinned upstream default permission semantics; only heuristic metadata scope changes.',
            'native_reference_controls':len(controls),'source_statuses':{m:dict(Counter(r['status'] for r in rs)) for m,rs in sources.items()},
            'metrics':{v:{m:stats(rs,m) for m in methods if m not in complete or complete[m]} for v,rs in variants.items()},
            'by_task':{v:{t:{m:stats([r for r in rs if r['task_id']==t],m) for m in methods if m not in complete or complete[m]}
                         for t in ('a01','a02','a06','a17')} for v,rs in variants.items()},
            'changed_by_debian_metadata':[{'sample_id':r['sample_id'],'task_id':r['task_id'],'original_label':r['local_label'],
                                          'all_os_metadata':r['astrogator_configured_heuristics'],'debian_metadata':r['debian_metadata_heuristics']}
                                         for r in rows if complete['debian_metadata_heuristics'] and r['astrogator_configured_heuristics']!=r['debian_metadata_heuristics']],
            'samples':rows,'input_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in
                                          [HERE/'syntax-baseline.jsonl',HERE/'debian-heuristics.jsonl'] if p.exists()},
            'runner_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in
                              [HERE/'syntax_baseline.py',HERE/'debian_heuristics.py']},
            'image_id':json.loads((HERE/'revised-frozen.json').read_text())['image_id'],
            'limitations':['Syntax pass is not semantic correctness; it is a conventional tooling baseline.',
                           'The metadata ablation restricts heuristic rows to Debian while verifier OS branches remain unchanged.',
                           'Debian metadata comes from upstream, not the execution-container account database.',
                           'Initial ablation failed on an empty metadata file; failed prefix and error log preserved. The corrected run preserves empty files exactly.']}
    (HERE/'additional-baselines.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Conventional-tool baseline and metadata-scope ablation','',
           f"Native syntax-check complete: {complete['native_syntax']}; Debian-metadata ablation complete: {complete['debian_metadata_heuristics']}.",'',
           'Ansible syntax-check uses the same processed programs and lab image, with four reference controls. Passing means only that this conventional check accepted the playbook. Verifier mode is pinned upstream default permission semantics. The second arm changes only heuristic metadata scope from all supplied distributions to Debian rows; it does not remove OS branches from verification.','',
           '| Label variant | Method | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |','|---|---|---:|---:|---:|---:|---:|']
    for variant,ms in result['metrics'].items():
        for m,s in ms.items():lines.append(f"| {variant} | {m} | {s['accepted_pass']} | {s['accepted_fail']} | {s['rejected_pass']} | {s['rejected_fail']} | {s['unavailable_pass']+s['unavailable_fail']} |")
    if complete['debian_metadata_heuristics']:
        lines+=['',f"Metadata-only changes: {len(result['changed_by_debian_metadata'])}. Identities and directions are in additional-baselines.json."]
    (HERE/'ADDITIONAL-BASELINES.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({k:result[k] for k in ['complete','observed','source_statuses','changed_by_debian_metadata']},indent=2))


if __name__=='__main__':main()
