#!/usr/bin/env python3
"""Task-stratified selective prediction analysis, preserving abstention and provenance.

Bootstrap intervals resample generator-model clusters, not individual programs.
They describe sensitivity within these four selected tasks; they do not establish
generalization to unseen task families. No independence-based significance tests.
"""
from collections import Counter, defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import random
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
METHODS = ('astrogator', 'astrogator_configured_heuristics', 'judge',
           'generated_checks_gated', 'always_accept', 'base_then_judge_on_abstention',
           'heuristics_then_judge_on_abstention')
BOOTSTRAPS = 2000
SEED = 251025


def rate(n, d): return n / d if d else None


def stats(rows, method):
    invalid=[r.get('local_label') for r in rows if r.get('local_label') not in ('passed_local_checks','failed_local_checks_or_execution')]
    if invalid:raise ValueError(f'Unresolved or missing labels must be reported separately, not scored as failures: {Counter(invalid)}')
    c = Counter(('pass' if r['local_label'] == 'passed_local_checks' else 'fail', r[method]) for r in rows)
    ap, af, rp, rf = c['pass', 'accept'], c['fail', 'accept'], c['pass', 'reject'], c['fail', 'reject']
    n = len(rows); passes = sum(v for (y, _), v in c.items() if y == 'pass'); fails = n-passes
    up, uf = passes-ap-rp, fails-af-rf
    return {'n': n, 'accepted_pass': ap, 'accepted_fail': af, 'rejected_pass': rp, 'rejected_fail': rf,
            'unavailable_pass': up, 'unavailable_fail': uf,
            'coverage': rate(ap+af+rp+rf, n), 'acceptance_rate': rate(ap+af, n),
            'accepted_failure_risk': rate(af, ap+af), 'decided_error_rate': rate(af+rp, ap+af+rp+rf),
            'failure_detection_recall': rate(rf, fails), 'passing_program_rejection_rate': rate(rp, passes),
            'failure_abstention_rate': rate(uf, fails),
            'deployment_block_rate_if_abstentions_block': rate(rp+rf+up+uf, n),
            'failures_blocked_if_abstentions_block': rate(rf+uf, fails),
            'pass_programs_blocked_if_abstentions_block': rate(rp+up, passes)}


def quantile(values, p):
    values = sorted(values)
    if not values: return None
    x = (len(values)-1)*p; i = int(x); j = min(i+1, len(values)-1)
    return values[i]*(j-x)+values[j]*(x-i) if i != j else values[i]


def cluster_intervals(rows, methods=METHODS, pairs=None):
    groups = defaultdict(list)
    for r in rows: groups[r['sample_id'].split('/')[0]].append(r)
    names = sorted(groups); rng = random.Random(SEED)
    measures = ('coverage', 'accepted_failure_risk', 'failure_detection_recall', 'passing_program_rejection_rate')
    dist = {m: {k: [] for k in measures} for m in methods}
    if pairs is None:
        pairs = [('astrogator', 'judge'), ('astrogator_configured_heuristics', 'judge'),
                 ('astrogator_configured_heuristics', 'astrogator')]
    paired = {a+' minus '+b: {k: [] for k in measures} for a,b in pairs}
    for _ in range(BOOTSTRAPS):
        sampled = [r for name in rng.choices(names, k=len(names)) for r in groups[name]]
        values = {m: stats(sampled, m) for m in methods}
        for m in methods:
            for k in measures:
                if values[m][k] is not None: dist[m][k].append(values[m][k])
        for a,b in pairs:
            for k in measures:
                if values[a][k] is not None and values[b][k] is not None:
                    paired[a+' minus '+b][k].append(values[a][k]-values[b][k])
    def summarize(d):
        return {m: {k: {'percentile_2_5': quantile(v,.025), 'percentile_97_5': quantile(v,.975),
                        'defined_resamples': len(v)} for k,v in ks.items()} for m,ks in d.items()}
    return {'seed': SEED, 'replicates': BOOTSTRAPS, 'clusters': names,
            'resampling_unit': 'Generator model: all its observed tasks and samples move together.',
            'scope': 'Descriptive stability within four selected tasks and eleven observed generator models. Not a task-generalization confidence interval. A degenerate zero-error interval is an empirical bootstrap artifact, not an upper bound on unseen failure risk.',
            'intervals': summarize(dist), 'paired_differences': summarize(paired)}


def residual_audit():
    ansi = re.compile(r'\x1b\[[0-9;]*m')
    rows = []
    for line in (ROOT/'reports/corpus-verifier.jsonl').read_text().splitlines():
        r = json.loads(line)
        if r['status'] != 'accepted_with_possible_residuals': continue
        text = ansi.sub('', r['stdout'])
        blocks = []
        for s in text.splitlines():
            m = re.match(r'^(.*?)\{ (\d+) branch \} assuming (.*?) and (.*?) performing (.*)$', s)
            if m:
                base, branches, initial, constraints, final = m.groups()
                blocks.append({'base': base.strip(), 'branches': int(branches),
                               'initial_state_difference': initial.strip(), 'constraints': constraints.strip(),
                               'final_state_difference': final.strip(),
                               'nonempty_initial': initial.strip() != '<>',
                               'nonempty_constraints': constraints.strip() != '',
                               'nonempty_final': final.strip() != '<>'})
        rows.append({'sample_id': r['sample_id'], 'task_id': r['task_id'], 'code_sha256': r['code_sha256'],
                     'printed_blocks': blocks, 'parser_found_blocks': bool(blocks),
                     'has_nonempty_printed_initial': any(x['nonempty_initial'] for x in blocks),
                     'has_nonempty_printed_constraints': any(x['nonempty_constraints'] for x in blocks),
                     'has_nonempty_printed_final': any(x['nonempty_final'] for x in blocks)})
    (HERE/'residual-audit.jsonl').write_text(''.join(json.dumps(r)+'\n' for r in rows))
    return {'accepted_programs': len(rows),
            **{k: sum(r[k] for r in rows) for k in ['parser_found_blocks', 'has_nonempty_printed_initial',
                                                   'has_nonempty_printed_constraints', 'has_nonempty_printed_final']},
            'interpretation': 'These fields expose the upstream printed unification differences. Nonempty does not by itself imply unsafe or unresolved; no discharge decision is inferred.',
            'upstream_source': {'commit': '7c62afa51986d87033af5112cdccd3b104b1c120',
                                'printer': 'bin/verify.ml:258-270', 'empty_diff': 'lib/fql/verifier.ml:string_of_merged_diff'}}


def enrich(rows):
    rows = [dict(r) for r in rows if r['local_label'] in ('passed_local_checks','failed_local_checks_or_execution')]
    for r in rows:
        r['always_accept'] = 'accept'
        for base, new in [('astrogator', 'base_then_judge_on_abstention'),
                          ('astrogator_configured_heuristics', 'heuristics_then_judge_on_abstention')]:
            r[new] = r[base] if r[base] in ('accept','reject') else r['judge']
    return rows


def main():
    source = ROOT/'reports/four-task-comparison.json'
    rows = enrich(json.loads(source.read_text())['samples'])
    tasks = sorted({r['task_id'] for r in rows})
    by_task = {t: {m: stats([r for r in rows if r['task_id']==t],m) for m in METHODS} for t in tasks}
    macro = {}
    for m in METHODS:
        macro[m] = {}
        for k in ('coverage','accepted_failure_risk','failure_detection_recall','passing_program_rejection_rate'):
            defined = [(t,by_task[t][m][k]) for t in tasks if by_task[t][m][k] is not None]
            macro[m][k] = {'mean': sum(v for _,v in defined)/len(defined) if defined else None,
                           'defined_tasks': [t for t,_ in defined]}
    failures = [r for r in rows if r['local_label']=='failed_local_checks_or_execution']
    execution_fail = [r for r in failures if 'execution_error' in r['scenario_statuses'].values()]
    behavior_only = [r for r in failures if 'execution_error' not in r['scenario_statuses'].values()]
    result = {'generated_at': datetime.now(timezone.utc).isoformat(),
              'verifier_mode':'Pinned upstream default permission semantics; heuristic flags are a separate named arm.',
              'input_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
              'script_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'processed_programs': len(rows), 'raw_attempts': 440, 'missing_processed': 18,
              'methods': {m: stats(rows,m) for m in METHODS}, 'by_task': by_task, 'task_macro': macro,
              'leave_one_task_out': {t: {m: stats([r for r in rows if r['task_id'] != t],m) for m in METHODS} for t in tasks},
              'failure_mechanisms': {'execution_failure': len(execution_fail), 'behavioral_only': len(behavior_only),
                                    'execution_failure_method_stats': {m:stats(execution_fail,m) for m in METHODS},
                                    'behavioral_only_method_stats': {m:stats(behavior_only,m) for m in METHODS}},
              'uncertainty': cluster_intervals(rows), 'residual_audit': residual_audit(),
              'limitations': ['Only four selected tasks; a01 contains zero local failures.',
                              'Local labels include exact-byte and password-marker choices; revised oracle sensitivity is separate.',
                              'Verifier ranges over OS contexts not matched by the Debian execution; disagreement is not automatically verifier error.',
                              'A verifier accept is conditional and may include printed differences; this report does not discharge them.',
                              'The judge is one small local model. Always-accept and fallback policies are analyses, not new model experiments.',
                              'Generated tests abstained after reference controls. No accuracy can be assigned.',
                              'Generator-cluster bootstrap avoids treating all programs as independent but cannot repair task selection or label validity.']}
    (HERE/'analysis.json').write_text(json.dumps(result,indent=2)+'\n')
    lines = ['# Evaluation corrected for coverage, task mix, and conditional verification','',
             'This is a reanalysis of the frozen 422-program, four-task development study, not new paper-wide accuracy evidence. All rates use the original local checks; new oracle observations are reported separately. Verifier mode: pinned upstream default permission semantics; heuristic flags define the separate named arm.','',
             '| Method | Decisions / 422 | Failed among accepted | Failures rejected / 139 | Failing programs unavailable | Passing programs rejected / 283 |',
             '|---|---:|---:|---:|---:|---:|']
    for m,s in result['methods'].items():
        lines.append(f"| {m} | {s['n']-s['unavailable_pass']-s['unavailable_fail']} | {s['accepted_fail']} / {s['accepted_pass']+s['accepted_fail']} | {s['rejected_fail']} | {s['unavailable_fail']} | {s['rejected_pass']} |")
    lines += ['', '## What changes the interpretation','',
              'The 74 verifier-unavailable programs all fail the local checks. Counting only decided programs hides this concentration: base verification rejects 56/139 failures, and configured heuristics reject 65/139. Blocking unavailable programs is a valid deployment policy, but is not evidence that the verifier proved them incorrect.', '',
              'The fallback policies use the already-recorded judge only when the verifier abstains; they are deterministic retrospective compositions. They expose whether extra decision coverage introduces accepted failures. No new inference calls or tuned thresholds are involved.', '',
              'All 110 a01 programs pass locally. Per-task tables, task-macro rates, and leave-one-task-out results are in analysis.json. Failure recall is undefined on a01 and is excluded, explicitly, from that macro average.', '',
              'The 2,000 paired bootstrap replicates resample the eleven generator-model clusters, retaining all programs from each sampled model. These descriptive intervals concern this fixed four-task suite. Four selected tasks cannot support a credible generalization interval over Ansible workloads; no significance claim is made.', '',
              'Configured heuristics additionally reject five Debian-local passes using www-data, which upstream metadata does not assume exists on RedHat. Those are environment-scope disagreements, not demonstrated false alarms. The remaining rejected local pass has a malformed shadow entry and is under revised-oracle review.', '',
              '## Residual reporting','',
              f"All {result['residual_audit']['accepted_programs']} accepted corpus records have printable unification output. See residual-audit.jsonl for initial differences, constraints, and final differences per printed branch. Their presence does not establish whether obligations are discharged. Treating VERIFIED as unconditional correctness is unsupported.", '',
              '## Reproduction','',
              '`python3 research/astrogator/phase2/evaluation/analyze.py`', '',
              'Inputs are byte-hashed in analysis.json. The source study is not modified.']
    (HERE/'EVALUATION.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({'programs': len(rows), 'methods': result['methods'], 'residuals': result['residual_audit']},indent=2))


if __name__ == '__main__': main()
