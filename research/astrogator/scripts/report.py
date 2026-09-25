#!/usr/bin/env python3
"""Build review tables from measured artifacts; never substitute inferred labels."""
import collections
import html
import json
from pathlib import Path
import sys
from datetime import datetime,timezone
from validate_expansion import summarize
from llm_pilot import extract

ROOT=Path(__file__).resolve().parents[1]


def rows(path):
    p=ROOT/path
    return [json.loads(x) for x in p.read_text().splitlines()] if p.exists() else []


def judge(path):
    try:
        r=json.loads(path.read_text()); d=json.loads(extract(r['text']))
        return d['verdict'] if d['verdict'] in ['accept','reject','uncertain'] else 'invalid'
    except (OSError,ValueError,KeyError,TypeError): return 'invalid'


def decision(r):
    return {'accepted_with_possible_residuals':'accept','verification_rejected':'reject','heuristic_rejected':'reject'}.get(r['status'],'unsupported_or_error')


def test_decision(rs):
    if len(rs)!=2: return 'missing'
    tests=[r.get('generated_test',{}) for r in rs]
    if any(t.get('status')!='evaluated' for t in tests): return 'invalid_or_unavailable'
    if any(t.get('returncode',0) not in [0,1] for t in tests): return 'test_error'
    return 'accept' if all(t.get('passed') for t in tests) else 'reject'


def metrics(rs):
    c=collections.Counter((r['truth'],r['decision']) for r in rs)
    return dict(n=len(rs),correct=sum(r['truth']=='correct' for r in rs),incorrect=sum(r['truth']=='incorrect' for r in rs),
                true_accept=c['correct','accept'],false_reject=c['correct','reject'],
                false_accept=c['incorrect','accept'],true_reject=c['incorrect','reject'],
                unresolved=sum(r['decision'] not in ['accept','reject'] for r in rs))


def main():
    original=json.loads((ROOT/'benchmarks/original.json').read_text())
    expanded=json.loads((ROOT/'benchmarks/expanded.json').read_text())
    merged={}
    for file in ['reports/expansion-execution.jsonl','reports/expansion-execution-v2.jsonl']:
        for r in rows(file): merged[(r['task_id'],r['scenario'],r['variant'])]=r
    executed=summarize(list(merged.values()))
    (ROOT/'reports/expansion-final.json').write_text(json.dumps(executed,indent=2)+'\n')
    query_results=rows('reports/fql-queries.jsonl')
    qs={r['task_id']:r for r in query_results if r['source']!='upstream'}
    query_counts={source:dict(collections.Counter(r['result']['returncode'] for r in query_results if r['source']==source)) for source in ['supplied_normalized','authored_candidate','upstream']}
    translation=rows('reports/fql-translations.jsonl')
    arms={}
    for r in translation:
        name=r['path'].rsplit('/',1)[0].removeprefix('experiments/')
        a=arms.setdefault(name,dict(n=0,parse=0,semantic_codegen=0,exact_parse_AST=0,exact_semantic_AST=0,semantic_fingerprint_available=0,truncated=0))
        a['n']+=1; a['parse']+=r['result']['stages'].get('parse',{}).get('status')=='ok'
        a['semantic_codegen']+=r['result']['returncode']==0
        a['exact_parse_AST']+=r['exact_parse_AST_match']; a['exact_semantic_AST']+=r['exact_semantic_AST_match'] is True
        a['semantic_fingerprint_available']+=r['exact_semantic_AST_match'] is not None
        a['truncated']+=r.get('finish_reason')=='length'
    effects=rows('reports/fql-effect-comparison.jsonl')
    for a in arms.values(): a['canonical_effect_tree_match']=0
    for r in effects:
        name=r['path'].rsplit('/',1)[0].removeprefix('experiments/')
        if name in arms: arms[name]['canonical_effect_tree_match']+=r['canonical_effect_tree_match']
    corpus=rows('reports/corpus-verifier.jsonl'); corpus_by={r['sample_id']:r for r in corpus}
    corpus_counts=dict(collections.Counter(r['status'] for r in corpus))
    originals_exec=rows('reports/original-pilot-execution.jsonl'); by_sample=collections.defaultdict(list)
    for r in originals_exec: by_sample[r['sample_id']].append(r)
    comparison=[]
    for key,rs in sorted(by_sample.items()):
        if key.startswith('reference/'): continue
        if len(rs)!=2 or any(r['status'] in ['harness_error','fixture_error'] for r in rs): truth='unresolved'
        else: truth='correct' if all(r['status']=='passed' for r in rs) else 'incorrect'
        comparison.append(dict(sample_id=key,truth=truth,
            astrogator=decision(corpus_by[key]),astrogator_stage=corpus_by[key]['status'],
            judge=judge(ROOT/'experiments/original-pilot'/('judge-'+key.replace('/','-')+'.json')),
            generated_checks=test_decision(rs)))
    original_metrics={m:metrics([{'truth':r['truth'],'decision':r[m]} for r in comparison if r['truth']!='unresolved']) for m in ['astrogator','judge','generated_checks']}
    synthetic=[]; ver={(r['task_id'],r['variant']):r for r in rows('reports/expansion-verifier.jsonl')}
    generated=rows('reports/generated-tests-execution.jsonl')+rows('reports/generated-tests-schema-execution.jsonl')
    for ident in ['a22','a25','a35','a41','a50','a55']:
        for variant in ['reference','mutant']:
            truth='correct' if variant=='reference' else 'incorrect'
            rr=dict(task_id=ident,variant=variant,truth=truth,
                astrogator=decision(ver[ident,variant]),
                judge=judge(ROOT/'experiments/qwen-local-pilot/judge-0shot'/f'{ident}-{variant}.json'))
            for kind in sorted({r['test_kind'] for r in generated}):
                rr[kind]=test_decision([r for r in generated if r['task_id']==ident and r['variant']==variant and r['test_kind']==kind])
            synthetic.append(rr)
    methods=['astrogator','judge',*sorted({r['test_kind'] for r in generated})]
    synthetic_metrics={m:metrics([{'truth':r['truth'],'decision':r[m]} for r in synthetic]) for m in methods}
    summary=dict(generated_at=datetime.now(timezone.utc).isoformat(),original_tasks=len(original),new_tasks=len(expanded),
                 runtime=executed,query_counts=query_counts,fql_arms=arms,corpus_verifier=corpus_counts,
                 original_comparison=comparison,original_metrics=original_metrics,
                 synthetic_comparison=synthetic,synthetic_metrics=synthetic_metrics)
    paired=json.loads((ROOT/'reports/four-task-comparison.json').read_text())
    summary.update(four_task_metrics=paired['metrics'], four_task_complete=all(paired[k] for k in
        ['execution_complete','judge_complete','heuristic_complete','generated_checks_complete']),
        heuristic_corpus=json.loads((ROOT/'reports/heuristic-summary.json').read_text()),
        query_transfer=json.loads((ROOT/'reports/generated-query-transfer.json').read_text()))
    (ROOT/'reports/summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    lines=['# Astrogator resubmission: working results','',
      f"**{len(original)+len(expanded)} task records; {executed['reference_validated']}/{len(expanded)} new reference solutions validated; {executed['mutants_killed']}/{len(expanded)} selected wrong variants caught.**",'',
      'This package covers all three requested workstreams. It is a reproducible development study, not a publication-ready claim of general accuracy. The current model experiments use a local quantized Qwen2.5-1.5B-Instruct model; one sample per condition.','',
      '## 1. Benchmark expansion','',
      f"The original 21 tasks are preserved. The {len(expanded)} additions span {len({b['family'] for b in expanded})} families and include a reference playbook, candidate FQL, two initial-state scenarios, independent state checks, and one deliberate semantic fault each.",
      f"References pass in {executed['reference_validated']*2} task/scenario combinations, with two executions per passing combination. Each of {executed['mutants_killed']} selected wrong variants fails in at least one scenario. Runtime validation is Debian 13 / Ansible core 2.19.11 only.",'',
      '| Family | New tasks |','|---|---:|']
    for k,v in sorted(collections.Counter(b['family'] for b in expanded).items()): lines.append(f'| {k} | {v} |')
    new_lowered=sum(qs[b['id']]['result']['returncode']==0 for b in expanded)
    lines += ['',f'**FQL support is a separate gate:** all 21 supplied queries pass the parser, semantic analyzer and module-language code generator; {new_lowered}/{len(expanded)} new candidate queries do. Lowering is not proof that a query captures all stated obligations. The other candidates expose capability gaps rather than silently counting as supported Astrogator benchmarks.',
      '', 'Notable gaps include links, regex replacement/removal, supplemental-membership updates, generic package/service knowledge, service enablement, scheduling, and archives. Existing FQL also leaves many preservation and negative-action obligations to residual review.',
      '', '[Browse every task and its status](review.html). [Raw execution results](expansion-execution.jsonl), [environment-fix and additional-task results](expansion-execution-v2.jsonl), [FQL diagnostics](fql-queries.jsonl).','',
      '## 2. Natural language → FQL','',
      '| Run / condition | N | Parsed | Semantic + codegen | Exact parsed AST match | Normalized effect match |','|---|---:|---:|---:|---:|---:|']
    for name,a in sorted(arms.items()): lines.append(f"| {name} | {a['n']} | {a['parse']} | {a['semantic_codegen']} | {a['exact_parse_AST']} | {a['canonical_effect_tree_match']} |")
    lines += ['', '**Grammar audit:** v1 admits only 17/21 canonical reference queries and excludes a11, a16, a18, a19. Its constrained results are development observations. Corrected v2 admits all 21, with canonical formatting independently checked to preserve the actual parser AST. Coverage of these references does not prove equivalence to the parser grammar.',
      '', '**Diagnostic retry:** the v2 repair arm retains four valid seed outputs and makes 17 additional calls with actual machine diagnostics, no reference FQL. Its 21 records are final task outputs, not 21 fresh calls. It raises lowering success from 4 to 6, while normalized semantic effect matches remain 1. The retry also uses a larger token budget, so this is not a feedback-only ablation.',
      '', 'Normalized effect matches use a readable upstream semantic-AST serializer with eleven positive/negative controls. They are a proxy, not a proof of semantic equivalence or independent intent fidelity. [Inspect the actual effects and differences](fql-effect-comparison.jsonl).',
      '', '**Larger comparison:** all 844 state executions for the frozen 422-program slice are complete, with 283 programs passing both local checks and 139 failing execution or a check. Eight reference controls pass. All judge and configured heuristic outputs are complete. [Full paired comparison](COMPARISON.md) includes per-task results, coverage, and the environment/oracle disagreements.']
    lines += ['', '**Matched retrieval/grammar result:** the expanded retrieval pool gives 13/21 parsed, 9/21 lowered, and 7/21 normalized effect matches. Adding v2 constraints to the same prompts gives 21/21 parsed, with the other counts unchanged. Original-only retrieval gives 6/21 effect matches; the one-match difference is exploratory, not a reliable gain estimate.',
      '', '**Configured heuristic sweep:** 183 of the base verifier’s 909 accepts become heuristic rejections; 726 remain accepted with possible residuals. Other stage counts are unchanged. Exact flags and metadata hashes are recorded. [Paired comparison and environment-scope caveats](COMPARISON.md).',
      '', '**End-to-end transfer is complete:** repaired queries were applied to all 2,238 processed programs. Invalid generated queries block 1,590; the six lowered queries cover 648. Relative to supplied queries, 125 programs change from acceptance to rejection and three change the other way. These are outcome changes, not accuracy. [Concrete semantic differences and transfer results](TRANSLATION-REVIEW.md).',
      '', '**Generated-check reference gate:** one of four new task-level check sets is invalid; the other three reject known-good reference states. This gated arm abstains across the four-task slice, with no candidate test executions and no test accuracy estimate. The gate uses reference information after generation and is separate from ungated baselines. [Control evidence](../experiments/four-task-tests-v1/gates.json).',
      '', '[Review local-oracle disagreements before interpreting comparison labels](DISAGREEMENTS.md).']
    lines += ['', 'The earlier three-shot demonstrations exclude the target task family; revised three-shot runs also use distinct demonstration families. Retrieval arms instead allow same-family examples and exclude the target task ID. Original-only and expanded-pool retrieval use the same four-shot format and token budget. Expanded candidate demos are not independently reviewed gold. A conservative GBNF subset constrains the final arm; all outputs still go through the actual upstream parser. Early six-task runs are development runs and are not pooled with the revised full sweep.',
      '', '**Finding:** syntactic validity and intent preservation are different. In the early pilot, the generated `if os is Debian then reboot` passed lowering but omitted “if it is needed.” In the full constrained run, the one unparsable output hit the token limit mid-string; constraints do not guarantee a complete output within a finite token budget. Exact AST match is a useful reproducible proxy, not a complete semantic-equivalence metric. The current outputs require requirement-level review before being designated correct translations.',
      '', '[Every request and response](../experiments/). [Machine-readable translation checks](fql-translations.jsonl).','',
      '## 3. Error-detection comparisons','',
      '### Full supplied corpus: actual verifier rerun','',
      '| Outcome | Count |','|---|---:|']
    for k,v in sorted(corpus_counts.items()): lines.append(f'| {k} | {v} |')
    lines += ['', 'These are outcomes, **not accuracy**. Acceptance may carry residual assumptions/actions. The pinned upstream revision differs from the historical paper version; no heuristics were enabled. The 72 missing processed files remain explicit.',
      '', '### Complete four-task slice: 422 processed programs', '',
      'The base verifier accepts 282 local passes and 9 local failures, rejects 1 local pass and 56 local failures, and cannot lower 74 programs. With configured heuristics, the counts are 277, 0, 6, and 65 respectively, with the same 74 unsupported inputs. Five additional local-pass rejections involve www-data and the upstream Red Hat metadata; the remaining rejected local pass exposes a narrow shadow-file oracle.', '',
      'The small-model judge accepts 270 local passes and 129 local failures, and rejects 13 local passes and 10 local failures. All four newly generated task-level check sets fail the reference gate, so that arm abstains for all 422 candidates. These are local-check agreement counts, not universal correctness or frontier-model results.', '',
      '[Paired tables, per-task breakdowns, CSV, and scope caveats](COMPARISON.md).', '',
      '### Earlier eight-program development pilot','',
      'Fixed selection: sample index 0 for gpt-5-mini and starcoder on directory creation, directory deletion, conditional file creation, and password disabling. All four supplied references pass both local initial states. Labels below are only for this declared environment and oracle.',
      '', '| Sample | Local label | Astrogator | LLM judge | Generated checks |','|---|---|---|---|---|']
    for r in comparison: lines.append(f"| {r['sample_id']} | {r['truth']} | {r['astrogator']} | {r['judge']} | {r['generated_checks']} |")
    lines += ['', 'The StarCoder conditional-file candidate adds a newline through `echo`; the local oracle follows the reference’s exact `beginning` bytes. Astrogator cannot lower its shell module. Treat this as a scoped disagreement, not evidence of general superiority.',
      '', '### Six controlled task/reference/mutant pairs','',
      '| Method | Correct accepted | Correct rejected | Incorrect accepted | Incorrect rejected | Unresolved |','|---|---:|---:|---:|---:|---:|']
    for name,m in synthetic_metrics.items(): lines.append(f"| {name} | {m['true_accept']} | {m['false_reject']} | {m['false_accept']} | {m['true_reject']} | {m['unresolved']} |")
    lines += ['', 'Each method sees six correct references and six selected wrong variants. Unsupported formal features and invalid test artifacts remain unresolved, not automatic semantic rejections. Generated Python tests and generated declarative checks are distinct baselines; schema-constrained checks are a separate development arm. Tests receive no reference solution or independent oracle.',
      '', '**Finding:** generated tests must themselves be validated. The small model sometimes checks the initial state instead of the required final state, asserts incompatible conditions, or tries to execute Ansible again. Rejecting a good reference is a test-quality failure, not evidence that the reference is wrong.',
      '', '### Concrete specification-review cases', '',
      'The base verifier accepts both the reference and selected wrong variant on a25 (overwriting an initialized config), a44 (removing a home that should remain), a46 (destroying a retained password hash), a61 (changing an existing group GID), a64 (recursively changing child ownership), a68 (creating a cache without its marker), and a70 (copying the enclosing directory rather than its contents). Independent execution checks distinguish each pair. These are specification/model/residual-review cases, not a claim that the formal verifier is unsound. The candidate query may omit an obligation, and the verifier may report extra effects or assumptions. All residual traces are retained in `expansion-verifier.jsonl`.',
      '', '## Reproducibility and limits','',
      '- Upstream: `counc009/state_based`, commit `7c62afa51986d87033af5112cdccd3b104b1c120`; source archive retained.',
      '- Three explicit OCaml String compatibility shims; 678 bounded checks against an independent Python oracle pass. No verifier algorithm or module model was changed.',
      '- Original source files remain byte-identical. CSV normalization and the p17 domain substitution are documented. File index 0 maps to response number 10.',
      '- Eight processed files fail plain PyYAML construction; most involve custom tags. These are not automatically YAML syntax failures or invalid Ansible.',
      '- The expanded verifier adapter removes only `gather_facts: false`, unsupported by the upstream parser; all task bodies remain unchanged. The as-given failures are retained.',
      '- Early package fixtures lacked python3-apt; these failures were fixed in the image and rerun. A stopped-daemon zombie issue was fixed using Docker init. Raw failed runs remain available.',
      '- No human-independent review, multi-OS execution, frontier-model comparison, or original full-corpus accuracy claim is complete.',
      '', '[Reproduce the work](../README.md). [Full protocol](../experiments/protocol.md). [Machine-readable summary](summary.json).','']
    (ROOT/'reports/RESULTS.md').write_text('\n'.join(lines))
    build_html(expanded,qs,executed,arms,corpus_counts,comparison)
    print(json.dumps({'new_references_validated':executed['reference_validated'],'new_mutants_killed':executed['mutants_killed'],'new_queries_lowered':new_lowered,'translation_outputs':len(translation)}))


def build_html(tasks,qs,executed,arms,corpus,comparison):
    cards=[]
    for b in tasks:
        ident=b['id']; d=ROOT/'benchmarks/expanded'/ident
        runtime=executed['tasks'].get(ident,{}).get('reference_validated',False)
        lowered=qs[ident]['result']['returncode']==0
        code=(d/'reference.yml').read_text(); checks=(d/'check.py').read_text()
        cards.append(f'''<details data-family="{html.escape(b['family'])}" data-supported="{str(lowered).lower()}"><summary><b>{ident}</b> {html.escape(b['title'])}<span>{'runtime ✓' if runtime else 'runtime pending'} · {'FQL lowered' if lowered else 'FQL gap'}</span></summary><p>{html.escape(b['natural_language'])}</p><p class="muted">Family: {html.escape(b['family'])} · Selected fault: {html.escape(b['fault'])}</p><h4>Candidate FQL — not a reviewed gold specification</h4><pre>{html.escape(b['formal_query'])}</pre><h4>Actual parser / analyzer output</h4><pre>{html.escape(qs[ident]['result']['stdout'])}</pre><h4>Reference playbook</h4><pre>{html.escape(code)}</pre><h4>Independent state checks</h4><pre>{html.escape(checks)}</pre></details>''')
    options=''.join(f'<option>{html.escape(f)}</option>' for f in sorted({b['family'] for b in tasks}))
    doc='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Astrogator research review</title><style>
body{font:16px/1.6 system-ui,sans-serif;background:#f4f5f7;color:#162536;margin:0}main{max-width:1080px;margin:0 auto;padding:48px 24px}h1{font-size:40px;line-height:1.15;margin:10px 0}h2{margin-top:40px}p{max-width:850px}.eyebrow{color:#235e65;font-weight:700;letter-spacing:.1em;font-size:13px}.metrics{display:flex;gap:16px;flex-wrap:wrap;margin:28px 0}.metric{background:white;border:1px solid #dce2e8;padding:20px;flex:1;min-width:180px}.metric b{display:block;font-size:34px}.muted{color:#5c6c79}.notice{border-left:4px solid #bf8b32;background:#fffaed;padding:14px 20px}details{margin:10px 0;background:white;border:1px solid #dce2e8;padding:16px}summary{cursor:pointer}summary b{color:#235e65;margin-right:12px}summary span{float:right;font-size:12px;color:#5c6c79}pre{background:#f0f3f6;padding:16px;white-space:pre-wrap;font-size:13px;overflow-wrap:anywhere}select,input{padding:10px;border:1px solid #aebdc8;border-radius:4px;margin-right:10px;font:inherit}a{color:#176c79}footer{margin:30px 0;color:#5c6c79}details[hidden]{display:none}@media(max-width:650px){summary span{float:none;display:block}h1{font-size:30px}}</style><main>
<div class="eyebrow">ASTROGATOR · RESUBMISSION WORKING ARTIFACT</div><h1>Broader tasks. Measured translation.<br>Inspectable comparisons.</h1>
<p>All three workstreams share source identities, explicit initial states, and independently executed checks. This review page is self-contained; every task below includes its reference and oracle.</p>
<div class="metrics"><div class="metric"><b>70</b>task records: 21 supplied + 49 new</div><div class="metric"><b>VALIDATED</b>new references validated in two states</div><div class="metric"><b>2,238</b>supplied processed programs checked</div></div>
<p class="notice">Runtime validation is not formal-language coverage. “FQL lowered” means the candidate passed upstream parsing, semantic analysis, and module-language code generation; it does not establish full intent fidelity. Model results use a small local quantized model and are exploratory.</p>
<p><a href="RESULTS.md">Results and comparison tables</a> · <a href="summary.json">Machine-readable measurements</a> · <a href="../experiments/protocol.md">Protocol and limitations</a></p>
<h2>Inspect the benchmark additions</h2><p class="muted">Filter by family or capability. Open a task to review its intended behavior, candidate query, reference, and state checks.</p>
<input id="search" placeholder="Search task or behavior" aria-label="Search tasks"><select id="family" aria-label="Filter family"><option value="">All families</option>OPTIONS</select><select id="support" aria-label="Filter FQL status"><option value="">All FQL statuses</option><option value="true">FQL lowered</option><option value="false">FQL gap</option></select><p id="count"></p><section id="tasks">CARDS</section>
<footer>Prepared locally on 2026-09-24. Source and measured outputs are retained; no results have been sent or published.</footer></main><script>
const all=[...document.querySelectorAll('details')];function filter(){const q=document.querySelector('#search').value.toLowerCase(),f=document.querySelector('#family').value,s=document.querySelector('#support').value;let n=0;for(const d of all){d.hidden=!(d.textContent.toLowerCase().includes(q)&&(!f||d.dataset.family===f)&&(!s||d.dataset.supported===s));if(!d.hidden)n++}document.querySelector('#count').textContent=n+' tasks shown'}for(const id of ['search','family','support'])document.getElementById(id).addEventListener('input',filter);filter();</script></html>'''
    doc=doc.replace('VALIDATED',str(executed['reference_validated'])).replace('OPTIONS',options).replace('CARDS','\n'.join(cards))
    (ROOT/'reports/review.html').write_text(doc)


if __name__=='__main__': main()
