#!/usr/bin/env python3
"""Join frozen candidates by identity and bytes; retain abstentions and pending work."""
import collections
import csv
from datetime import datetime, timezone
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LABELS = {'passed_local_checks': 'pass', 'failed_local_checks_or_execution': 'fail'}


def metrics(rows, method):
    eligible = [r for r in rows if r['local_label'] in LABELS]
    counts = collections.Counter((LABELS[r['local_label']], r[method]) for r in eligible)
    decided = sum(n for (_, d), n in counts.items() if d in ('accept', 'reject'))
    agree = counts['pass', 'accept'] + counts['fail', 'reject']
    return {'execution_labeled': len(eligible), 'decided': decided,
            'decision_coverage': decided / len(eligible) if eligible else None,
            'agreement_on_decided': agree / decided if decided else None,
            'accepted_local_pass': counts['pass', 'accept'],
            'rejected_local_pass': counts['pass', 'reject'],
            'accepted_local_fail': counts['fail', 'accept'],
            'rejected_local_fail': counts['fail', 'reject'],
            'other_decisions': dict(collections.Counter(r[method] for r in eligible
                                       if r[method] not in ('accept', 'reject')))}


def prediction(path, sha):
    if not path.exists(): return 'pending'
    r = json.loads(path.read_text())
    if r['code_sha256'] != sha: raise ValueError('Judge candidate hash mismatch')
    if r.get('error'): return 'request_error'
    if r.get('finish_reason') == 'length': return 'truncated'
    try:
        d = json.loads(r['text'])
        if set(d) != {'verdict', 'reason'} or not isinstance(d['reason'], str): return 'invalid'
        return d['verdict'] if d['verdict'] in ('accept', 'reject', 'uncertain') else 'invalid'
    except (ValueError, KeyError, TypeError): return 'invalid'


def generated_decision(sample, sha, gates):
    task = sample['task_id']; sid = sample['sample_id']
    gate = gates.get(task, {}).get('status')
    if gate is None: return 'pending'
    if gate != 'eligible': return 'test_' + gate
    records = []
    for scenario in ('baseline', 'adversarial'):
        path = ROOT / 'experiments/four-task-tests-v1' / (sid.replace('/', '-') + '-' + scenario + '.json')
        if not path.exists(): return 'pending'
        r = json.loads(path.read_text())
        if r.get('input_sha256', {}).get('candidate', sha) != sha:
            raise ValueError('Generated-test candidate hash mismatch')
        records.append(r)
    if any(r['status'] in ('harness_error', 'fixture_error', 'execution_timeout') for r in records):
        return 'execution_unresolved'
    if any(r['status'] == 'execution_error' for r in records): return 'reject'
    if any(r.get('generated_test', {}).get('status') != 'evaluated' for r in records): return 'invalid_test'
    return 'accept' if all(r['generated_test'].get('passed') is True for r in records) else 'reject'


def main():
    execution = ROOT / 'experiments/four-task-full-v1'
    frozen = json.loads((execution / 'frozen-inputs.json').read_text())
    summary = json.loads((execution / 'summary.json').read_text())
    labels = {r['sample_id']: r for r in summary['samples']}
    verifier = {r['sample_id']: r for r in map(json.loads,
                 (ROOT / 'reports/corpus-verifier.jsonl').read_text().splitlines())}
    gate_path = ROOT / 'experiments/four-task-tests-v1/gates.json'
    gates = json.loads(gate_path.read_text()) if gate_path.exists() else {}
    heuristic_path = ROOT / 'reports/corpus-heuristic-verifier.jsonl'
    heuristics = {r['sample_id']: r for r in map(json.loads, heuristic_path.read_text().splitlines())} if heuristic_path.exists() else {}
    methods = ('astrogator', 'astrogator_configured_heuristics', 'judge', 'generated_checks_gated')
    rows = []
    for sample in frozen['samples']:
        sid = sample['sample_id']
        row = {**labels[sid], **{m: 'missing_processed' for m in methods}}
        if sample['response']:
            sha = sample['response']['sha256']
            v = verifier[sid]
            if v['code_sha256'] != sha: raise ValueError('Verifier candidate hash mismatch')
            row.update(code_sha256=sha, astrogator_stage=v['status'],
                       astrogator={'accepted_with_possible_residuals': 'accept',
                                   'verification_rejected': 'reject'}.get(v['status'], 'unsupported_or_error'),
                       judge=prediction(ROOT / 'experiments/four-task-judge-v1' /
                                        (sid.replace('/', '-') + '.json'), sha),
                       generated_checks_gated=generated_decision(sample, sha, gates))
            h = heuristics.get(sid)
            if h is None: row['astrogator_configured_heuristics'] = 'pending'
            else:
                if h['code_sha256'] != sha: raise ValueError('Heuristic candidate hash mismatch')
                row['astrogator_configured_heuristics'] = {
                    'accepted_with_possible_residuals': 'accept', 'verification_rejected': 'reject',
                    'heuristic_rejected': 'reject'}.get(h['status'], 'unsupported_or_error')
                row['heuristic_stage'] = h['status']
        rows.append(row)
    common = [r for r in rows if all(r[m] in ('accept', 'reject') for m in ('astrogator', 'judge'))]
    result = {'generated_at': datetime.now(timezone.utc).isoformat(),
              'execution_complete': summary['complete'],
              'judge_complete': not any(r['judge'] == 'pending' for r in rows),
              'generated_checks_complete': not any(r['generated_checks_gated'] == 'pending' for r in rows),
              'heuristic_complete': not any(r['astrogator_configured_heuristics'] == 'pending' for r in rows),
              'generated_check_gates': gates,
              'observed_execution_cases': summary['observed_cases'],
              'expected_execution_cases': summary['expected_cases'],
              'local_label_counts': dict(collections.Counter(r['local_label'] for r in rows)),
              'judge_counts': dict(collections.Counter(r['judge'] for r in rows)),
              'metrics': {m: metrics(rows, m) for m in methods},
              'metrics_by_task': {task: {m: metrics([r for r in rows if r['task_id'] == task], m)
                                        for m in methods} for task in frozen['tasks']},
              'common_decision_subset': {m: metrics(common, m) for m in ('astrogator', 'judge')},
              'limitations': ['Two initial states on Debian; local checks are not universal correctness.',
                  'Base verifier accepts may carry residual obligations; heuristics disabled.',
                  'Unsupported outputs are abstentions, not automatic rejections.',
                  'Generated checks have a known-good reference gate: a separate advantage over an ungated baseline.',
                  'Configured heuristics use pinned upstream metadata, not reconstructed local-container facts; disagreements need context review.',
                  'Partial runs are ordered, nonrandom prefixes; do not rank methods from interim results.',
                  'Four tasks are not representative of all 21 tasks or all Ansible workloads.'],
              'samples': rows}
    (ROOT / 'reports/four-task-comparison.json').write_text(json.dumps(result, indent=2) + '\n')
    with (ROOT / 'reports/four-task-comparison.csv').open('w', newline='') as f:
        fields = ['sample_id', 'task_id', 'local_label', *methods]
        writer = csv.DictWriter(f, fieldnames=fields, extrasaction='ignore')
        writer.writeheader(); writer.writerows(rows)
    lines = ['# Four-task paired comparison', '',
        f"Execution complete: **{result['execution_complete']}**. Judge complete: **{result['judge_complete']}**. Configured heuristic sweep complete for this slice: **{result['heuristic_complete']}**.", '',
        'Labels mean passing or failing the declared local checks/execution, not universal correctness. Missing processed files are excluded from the table; uncertain, unsupported, invalid, and pending method outcomes remain unavailable decisions.', '',
        '| Method | Accept local pass | Reject local pass | Accept local fail | Reject local fail | Unavailable |',
        '|---|---:|---:|---:|---:|---:|']
    for method, m in result['metrics'].items():
        lines.append(f"| {method} | {m['accepted_local_pass']} | {m['rejected_local_pass']} | {m['accepted_local_fail']} | {m['rejected_local_fail']} | {m['execution_labeled']-m['decided']} |")
    lines += ['', 'Do not rank methods from incomplete ordered prefixes. The JSON includes per-task results and a common-decision subset for the base verifier and judge, plus explicit coverage and stage counts. All 110 directory-creation candidates pass the local check, so pooled totals can obscure performance on the harder tasks.', '',
              '[Oracle and specification disagreements](DISAGREEMENTS.md) · [Execution audit](four-task-execution-audit.json) · [Machine-readable results](four-task-comparison.json) · [CSV](four-task-comparison.csv)', '',
              *['- ' + note for note in result['limitations']], '']
    (ROOT / 'reports/COMPARISON.md').write_text('\n'.join(lines))
    print(json.dumps({k: v for k, v in result.items() if k != 'samples'}, indent=2))


if __name__ == '__main__': main()
