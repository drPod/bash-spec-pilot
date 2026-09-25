#!/usr/bin/env python3
"""Compare complete whole-task new-version observations without overwriting v1 labels."""
from collections import Counter
import hashlib
import json
from pathlib import Path
from analyze import HERE, ROOT, METHODS, enrich, stats


def label(cases, field):
    if len(cases) != 2: return 'pending'
    if any(r['status'] not in ('observed','execution_error') for r in cases): return 'unresolved'
    return 'passed_local_checks' if all(r['status']=='observed' and r['after'][field] for r in cases) else 'failed_local_checks_or_execution'


def main():
    frozen = json.loads((HERE/'revised-frozen.json').read_text())
    cases = [json.loads(s) for s in (HERE/'revised-execution.jsonl').read_text().splitlines()]
    index = {(r['sample_id'],r['scenario']):r for r in cases}; assert len(index)==len(cases)
    retry_path=HERE/'revised-infra-retries.jsonl'
    retries=[json.loads(s) for s in retry_path.read_text().splitlines()] if retry_path.exists() else []
    retry_keys=set()
    for retry in retries:
        key=retry['sample_id'],retry['scenario'];assert key not in retry_keys;retry_keys.add(key)
        original=index[key]
        assert original['status']=='harness_error' and 'runtime/cgo: pthread_create failed' in original.get('error','')
        assert retry['retry_of_sha256']==hashlib.sha256(json.dumps(original,sort_keys=True).encode()).hexdigest()
        index[key]=retry
    old = {r['sample_id']:r for r in json.loads((ROOT/'reports/four-task-comparison.json').read_text())['samples']}
    old_execution_path=ROOT/'experiments/four-task-full-v1/execution.jsonl'
    old_cases={(r['sample_id'],r['scenario']):r for r in map(json.loads,old_execution_path.read_text().splitlines())}
    case_transitions=Counter()
    for key,r in index.items():
        observed_status=('passed' if r['after']['old_oracle'] else 'oracle_rejected') if r['status']=='observed' else r['status']
        case_transitions[old_cases[key]['status']+' -> '+observed_status]+=1
    expected = sum(bool(r['response']) for r in frozen['samples'])*2
    samples = []
    for s in frozen['samples']:
        if not s['response']: continue
        observed = [index[s['sample_id'],sc] for sc in ('baseline','adversarial') if (s['sample_id'],sc) in index]
        for r in observed:
            if r['status']!='harness_error':
                assert r['candidate_sha256']==s['response']['sha256']
                assert r['runner_sha256']==frozen['source_sha256']['revised_case.py']
            assert r['image_id']==frozen['image_id']
        samples.append({'sample_id':s['sample_id'],'task_id':s['task_id'], 'original_label':old[s['sample_id']]['local_label'],
                        'new_fixture_old_oracle':label(observed,'old_oracle'),
                        'strict_integrity':label(observed,'strict_oracle' if s['task_id']=='a17' else 'old_oracle'),
                        'newline_sensitivity':label(observed,'strict_oracle' if s['task_id']=='a17' else 'single_final_newline_tolerant'),
                        'case_statuses':{r['scenario']:r['status'] for r in observed},
                        'structural_failure_scenarios':[r['scenario'] for r in observed if s['task_id']=='a17' and r.get('after',{}).get('shadow_and_passwd_integrity') is False]})
    complete = len(cases)==expected and all(s['strict_integrity'] not in ('pending','unresolved') for s in samples)
    fields = ('new_fixture_old_oracle','strict_integrity','newline_sensitivity')
    transitions = {f:dict(Counter(s['original_label']+' -> '+s[f] for s in samples)) for f in fields}
    metrics = {}
    if complete:
        revised = {s['sample_id']:s for s in samples}
        for field in fields:
            rows = enrich(list(old.values()))
            for r in rows:
                if r['sample_id'] in revised: r['local_label']=revised[r['sample_id']][field]
            metrics[field]={'methods':{m:stats(rows,m) for m in METHODS},
                            'local_label_counts':dict(Counter(r['local_label'] for r in rows)),
                            'by_task':{t:{m:stats([r for r in rows if r['task_id']==t],m) for m in METHODS}
                                       for t in ('a01','a02','a06','a17')}}
    result={'complete':complete,'observed_cases':len(cases),'expected_cases':expected,
            'reference_controls':len((HERE/'revised-controls.jsonl').read_text().splitlines()),
            'case_status_counts':dict(Counter(r['status'] for r in index.values())),
            'old_oracle_case_transitions':dict(case_transitions),
            'old_execution_sha256':hashlib.sha256(old_execution_path.read_bytes()).hexdigest(),
            'primary_case_status_counts':dict(Counter(r['status'] for r in cases)),
            'infrastructure_retries':len(retries),'retry_policy':'One retry only for Docker/Go startup pthread allocation failures; originals preserved.',
            'transitions':transitions,'changed_samples':{f:[s for s in samples if s[f]!=s['original_label']] for f in fields},
            'samples':samples,'metrics':metrics,
            'input_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in
                            [HERE/'revised-frozen.json',HERE/'revised-controls.jsonl',HERE/'revised-execution.jsonl']},
            'limitations':['Strict integrity is a revised interpretation requiring human review, not retroactive gold.',
                           'A valid crypt hash establishes hash verification before execution, not PAM/SSH login.',
                           'Numeric shadow aging fields and empty reserved field are checked; complete account-database consistency is not proved.',
                           'One-final-newline tolerance is an explicit sensitivity alternative, not a claim the task allows it.',
                           'a01/a02 labels remain from original run. All a06/a17 processed programs were selected before rerun.']}
    if retry_path.exists():result['input_sha256'][retry_path.name]=hashlib.sha256(retry_path.read_bytes()).hexdigest()
    (HERE/'revised-summary.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Whole-task oracle sensitivity', '',f'Complete: {complete}. Cases: {len(cases)}/{expected}; four reference controls.','',
           'All processed programs from a06 and a17 were selected before execution. The original observations remain unchanged. New a17 fixtures use a real SHA-512 crypt hash, establish a matching password before the baseline execution, and test both an unlocked and already-locked account.','',
           'The strengthened password check requires exactly one service shadow record with nine fields, one passwd record with seven fields, numeric-or-empty aging fields, an empty reserved field, an existing user, and a lock marker. These are declared conservative fixture constraints, not a complete validator of every permitted system configuration. The shadow manual describes the nine-field format and distinguishes disabling UNIX-password login from other authentication methods. [shadow(5)](https://man7.org/linux/man-pages/man5/shadow.5.html). This check does not establish full PAM/SSH authentication behavior.','',
           'a06 records exact bytes and separately allows one final newline when creating the new file. Preservation of the existing file remains exact. This alternative makes the interpretation sensitivity visible.','',
           '| Variant | Original pass → new fail | Original fail → new pass |', '|---|---:|---:|']
    for f in fields:
        c=transitions[f]
        lines.append(f"| {f} | {c.get('passed_local_checks -> failed_local_checks_or_execution',0)} | {c.get('failed_local_checks_or_execution -> passed_local_checks',0)} |")
    lines+=['','Changed sample identities, paired method tables, input hashes, and complete per-case observations are included in revised-summary.json and revised-execution.jsonl. No selectively relabeled disagreement is substituted into the original report.']
    (HERE/'ORACLE-SENSITIVITY.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({'complete':complete,'observed':len(cases),'expected':expected,'transitions':transitions},indent=2))


if __name__=='__main__':main()
