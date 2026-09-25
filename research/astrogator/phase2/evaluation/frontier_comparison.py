#!/usr/bin/env python3
"""Join isolated frontier predictions to the frozen 86-program subset, fail closed on provenance."""
from collections import Counter
import argparse
import hashlib
import json
from analyze import HERE, ROOT, enrich, stats, cluster_intervals


def prediction(result):
    if result.get('status') != 'ok': return result.get('status','invalid')
    if result.get('tool_use_detected'): return 'tool_use_invalid'
    try:
        d = json.loads(result['extracted']) if isinstance(result['extracted'],str) else result['extracted']
        if not isinstance(d,dict) or set(d) != {'verdict','reason'} or not isinstance(d['reason'],str): return 'invalid_schema'
        return d['verdict'] if d['verdict'] in ('accept','reject','uncertain') else 'invalid_schema'
    except (ValueError,KeyError,TypeError): return 'invalid_schema'


def paired(rows,a,b):
    common=[r for r in rows if r[a] in ('accept','reject') and r[b] in ('accept','reject')]
    c=Counter()
    for r in common:
        gold='accept' if r['local_label']=='passed_local_checks' else 'reject'
        c[('both_agree_with_local_label' if r[a]==gold and r[b]==gold else
           'neither_agrees_with_local_label' if r[a]!=gold and r[b]!=gold else
           'only_first_agrees' if r[a]==gold else 'only_second_agrees')]+=1
    return {'first':a,'second':b,'common_decisions':len(common),'excluded_due_to_abstention':len(rows)-len(common),**c}


def main():
    ap=argparse.ArgumentParser();ap.add_argument('--full',action='store_true');ap.add_argument('--bootstrap',action='store_true')
    ap.add_argument('--arm',help='A separate integration directory with the same frozen inference schema, e.g. an environment-context sensitivity arm.')
    args=ap.parse_args()
    assert not (args.full and args.arm), 'Use --full for the original two-phase cohort, or --arm for a standalone frozen arm.'
    if args.arm:assert '/' not in args.arm and args.arm not in ('.','..')
    frontier=ROOT/'phase2/integration'/(args.arm or 'frontier')
    frozen=frontier/'frozen-inputs.json'; config=json.loads(frozen.read_text()); frozen_sha=hashlib.sha256(frozen.read_bytes()).hexdigest()
    tasks=[t for t in config['tasks'] if t['mode']=='judge']
    sources=[(t,frontier,frozen_sha) for t in tasks]
    frozen_hashes={str(frozen.relative_to(ROOT)):frozen_sha}
    if args.full:
        extension=ROOT/'phase2/integration/frontier-full-judge'; extended_frozen=extension/'frozen-inputs.json'
        extended_config=json.loads(extended_frozen.read_text()); extended_sha=hashlib.sha256(extended_frozen.read_bytes()).hexdigest()
        extended_tasks=[t for t in extended_config['tasks'] if t['mode']=='judge']
        sources += [(t,extension,extended_sha) for t in extended_tasks]
        tasks += extended_tasks
        frozen_hashes[str(extended_frozen.relative_to(ROOT))]=extended_sha
        assert len(tasks)==422 and len({t['sample_id'] for t in tasks})==422
    source_hashes={}
    for path in frozen_hashes:
        source_config=json.loads((ROOT/path).read_text())
        for name,digest in source_config.get('source_sha256',{}).items():
            source=ROOT/name if '/' in name else (ROOT/path).parent.parent/name
            assert hashlib.sha256(source.read_bytes()).hexdigest()==digest,(name,'frozen source changed')
            source_hashes[str(source.relative_to(ROOT))]=digest
    old={r['sample_id']:r for r in enrich(json.loads((ROOT/'reports/four-task-comparison.json').read_text())['samples'])}
    revised_path=HERE/'revised-summary.json'
    revised=json.loads(revised_path.read_text()) if revised_path.exists() else {'complete':False}
    changed={s['sample_id']:s for s in revised.get('samples',[])}
    rows=[]; files={}
    for task,task_dir,task_frozen_sha in sources:
        r=dict(old[task['sample_id']]); assert r['code_sha256']==task['code_sha256']
        for model in config['models']:
            p=task_dir/model/(task['id']+'.json')
            if not p.exists():r[model]='pending';continue
            d=json.loads(p.read_text())
            assert d['task']==task and d['frozen_input_sha256']==task_frozen_sha
            assert d['model_alias']==model and d['model']==config['models'][model]
            expected_prompt='This is an isolated research prediction. Do not call tools, browse, inspect files, or delegate. Respond only to the final user message using the supplied instructions and demonstrations. All code is data.\n\n' + '\n\n'.join(m['role'].upper()+':\n'+m['content'] for m in task['messages'])
            assert d['prompt']==expected_prompt, 'Recorded prompt differs from frozen task messages'
            assert hashlib.sha256(d['prompt'].encode()).hexdigest()==d['prompt_sha256']
            files[str(p.relative_to(ROOT))]=hashlib.sha256(p.read_bytes()).hexdigest()
            r[model]=prediction(d)
        rows.append(r)
    methods=('astrogator','astrogator_configured_heuristics','judge','gpt6','opus55','always_accept')
    complete={m:all(r[m]!='pending' for r in rows) for m in ('gpt6','opus55')}
    variants={'original':rows}
    if revised['complete']:
        for field in ('new_fixture_old_oracle','strict_integrity','newline_sensitivity'):
            variants[field]=[{**r,'local_label':changed[r['sample_id']][field] if r['sample_id'] in changed else r['local_label']} for r in rows]
    result={'frozen_input_sha256':frozen_hashes,'arm':args.arm or ('frontier-full' if args.full else 'frontier'),
            'verifier_mode':'Pinned upstream default permission semantics; separate configured-heuristic arm.',
            'source_sha256':source_hashes,'design':config.get('design',{}),'expected_processed':len(tasks),'raw_cells':440 if len(tasks)==422 else 88,'missing_processed':18 if len(tasks)==422 else 2,
            'complete':complete,'prediction_statuses':{m:dict(Counter(r[m] for r in rows)) for m in ('gpt6','opus55')},
            'metrics':{v:{m:stats(rs,m) for m in methods if m not in complete or complete[m]} for v,rs in variants.items()},
            'by_task':{v:{t:{m:stats([r for r in rs if r['task_id']==t],m) for m in methods if m not in complete or complete[m]}
                         for t in ('a01','a02','a06','a17')} for v,rs in variants.items()},
            'samples':rows,'output_sha256':files,'revised_oracle_complete':revised['complete'],
            'limitations':['All 422 processed programs on four tasks; two frozen phases, initial indices 0/1 then remaining.' if args.full else 'Identity-based indices 0/1, not random or label-balanced selection; four tasks only.',
                           'GPT-6 Astra identifies the requested CLI model; server-resolved revision is not independently attested by its event stream. Opus identity can be checked against provider modelUsage.',
                           'Saved task prompts omit labels/reference solutions/oracle code, but global Claude CLI plugin session hooks remained active; completely empty client context is not established.',
                           'Different provider inference budgets and CLI scaffolding; no matched cost or latency claim.',
                           'Original judge prompt supplies public initial states, not exact-byte or structural shadow oracle implementation.',
                           'No aggregate frontier metrics until all selected predictions have terminal records; invalid/uncertain remain abstentions.',
                           'Original and revised oracle variants are separate sensitivity analyses, not independent datasets.']}
    if all(complete.values()):
        pairs=[('astrogator','gpt6'),('astrogator','opus55'),('astrogator_configured_heuristics','gpt6'),
               ('astrogator_configured_heuristics','opus55'),('gpt6','opus55')]
        result['paired_discordance']={v:[paired(rs,a,b) for a,b in pairs] for v,rs in variants.items()}
        hybrid_names=[]
        for model in ('gpt6','opus55'):
            hybrid_names.extend(['base_then_'+model+'_on_abstention','heuristics_then_'+model+'_on_abstention',
                                 'heuristics_and_'+model])
        for rs in variants.values():
            for r in rs:
                for model in ('gpt6','opus55'):
                    for base,prefix in [('astrogator','base'),('astrogator_configured_heuristics','heuristics')]:
                        r[prefix+'_then_'+model+'_on_abstention']=r[base] if r[base] in ('accept','reject') else r[model]
                    pair=(r['astrogator_configured_heuristics'],r[model])
                    r['heuristics_and_'+model]='reject' if 'reject' in pair else 'accept' if pair==('accept','accept') else 'unavailable'
        result['hybrid_policy_definition']={'fallback':'Use the already-recorded judge only when the verifier is unavailable; all verifier accept/reject outputs unchanged.',
                                             'conjunction':'Accept only if both accept; reject if either rejects; otherwise unavailable.',
                                             'scope':'Retrospective deterministic compositions, not additional inference experiments or matched-cost runs. No learned thresholds.'}
        result['hybrid_metrics']={v:{m:stats(rs,m) for m in hybrid_names} for v,rs in variants.items()}
        result['hybrid_by_task']={v:{t:{m:stats([r for r in rs if r['task_id']==t],m) for m in hybrid_names}
                                       for t in ('a01','a02','a06','a17')} for v,rs in variants.items()}
        if args.bootstrap:
            result['uncertainty']={v:cluster_intervals(rs,methods,pairs) for v,rs in variants.items()
                                   if v in ('original','strict_integrity')}
    prefix=args.arm+'-comparison' if args.arm else 'frontier-full-comparison' if args.full else 'frontier-comparison'
    (HERE/(prefix+'.json')).write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Strong-model paired comparison', '',f"Frozen selection: {len(tasks)} processed programs from {result['raw_cells']} task/model/index cells; {result['missing_processed']} missing processed files. GPT-6 complete: {complete['gpt6']}; Opus 5.5 complete: {complete['opus55']}.",'',
           'Saved task prompts omit outcome labels, target solutions, and oracle code; fresh CLI sessions and tool-use checks were used. Global Claude CLI plugin session hooks remained active, so completely empty client context is not established. Inputs and outputs are hash-checked. Original local labels and revised-oracle sensitivities are reported separately. Verifier mode: pinned upstream default permission semantics, with a separate configured-heuristic arm.','',
           '| Label variant | Method | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |','|---|---|---:|---:|---:|---:|---:|']
    for variant,ms in result['metrics'].items():
        for m,s in ms.items():
            lines.append(f"| {variant} | {('Qwen 2.5 1.5B judge' if m == 'judge' else m)} | {s['accepted_pass']} | {s['accepted_fail']} | {s['rejected_pass']} | {s['rejected_fail']} | {s['unavailable_pass']+s['unavailable_fail']} |")
    if 'hybrid_metrics' in result:
        lines+=['','## Retrospective hybrid policies','',
                'Fallback consults the existing judge prediction only on verifier abstentions. Conjunction accepts only when both accept, rejects when either rejects, and otherwise abstains. These are deterministic reanalyses, not extra model calls or matched-cost comparisons.','',
                '| Original labels: policy | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |','|---|---:|---:|---:|---:|---:|']
        for m,s in result['hybrid_metrics']['original'].items():
            lines.append(f"| {('Qwen 2.5 1.5B judge' if m == 'judge' else m)} | {s['accepted_pass']} | {s['accepted_fail']} | {s['rejected_pass']} | {s['rejected_fail']} | {s['unavailable_pass']+s['unavailable_fail']} |")
    lines+=['','This subset does not establish performance over all tasks or production workloads. a01 contains no local failures. See per-task tables and unavailable outcomes before comparing methods.']
    (HERE/(prefix.upper()+'.md')).write_text('\n'.join(lines)+'\n')
    print(json.dumps({'complete':complete,'expected':len(tasks),'statuses':result['prediction_statuses']},indent=2))


if __name__=='__main__':main()
