#!/usr/bin/env python3
"""Compile results.json from the job-directory receipts (attempts.jsonl, checks/*.json).

Raw model events, sessions and build logs stay outside the repository; this file carries
their hashes, durations, token usage, gate outcomes and the exact reject reasons.
"""
import argparse
import datetime
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
JOB = Path.home() / 'agent-jobs/astra-research/phase5/claude-resume/evaluation'


def usage(events: Path):
    last = None
    for line in events.read_text().splitlines():
        try:
            d = json.loads(line)
        except ValueError:
            continue
        if d.get('type') == 'message_end':
            u = d.get('message', {}).get('usage')
            if u:
                last = u
    return last and {k: last.get(k) for k in ('input', 'output', 'cacheRead', 'reasoning', 'totalTokens')}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--job', type=Path, default=JOB)
    args = ap.parse_args()
    manifest = json.loads((HERE / 'tasks/manifest.json').read_text())
    attempts = []
    for line in (args.job / 'attempts.jsonl').read_text().splitlines():
        a = json.loads(line)
        receipt = args.job / 'checks' / (a['name'] + '.json')
        chk = json.loads(receipt.read_text()) if receipt.exists() else None
        attempts.append(dict(
            name=a['name'], task=a['task'], condition=a['condition'], attempt=a['attempt'],
            model=a['model'], harness=a['harness'], wall_limit_seconds=a['wall_limit_seconds'],
            started_utc=a['started_utc'], model_elapsed_seconds=a['model_elapsed_seconds'],
            timed_out=a['timed_out'], block_found=a['block_found'],
            token_usage=usage(args.job / 'attempts' / a['name'] / 'events.jsonl'),
            first_pass=True, feedback_rounds=a['feedback_rounds'], interventions=a['interventions'],
            accepted=a['check']['accepted'], reject_reason=a['check'].get('reject_reason'),
            submission_sha256=chk and chk.get('submission_sha256'),
            build_log_sha256=chk and chk['gates'].get('build', {}).get('log_sha256'),
            build_errors=chk and chk['gates'].get('build', {}).get('errors'),
            axioms=chk and chk['gates'].get('axioms', {}).get('reported'),
            theorem_type_matches=chk and chk['gates'].get('theorem_type', {}).get('matches')))
    controls, rechecks = [], []
    for receipt in sorted((args.job / 'checks').glob('control2-*.json')):
        c = json.loads(receipt.read_text())
        controls.append(dict(name=c['name'], task=c['task'], condition=c['condition'],
                             accepted=c['accepted'], reject_reason=c['reject_reason'],
                             submission_sha256=c.get('submission_sha256')))
    for receipt in sorted((args.job / 'checks').glob('recheck-*.json')):
        c = json.loads(receipt.read_text())
        rechecks.append(dict(name=c['name'], accepted=c['accepted'], checked_utc=c['checked_utc'],
                             submission_sha256=c.get('submission_sha256'),
                             compiler_lock_wait=c.get('compiler_lock_wait'),
                             axioms=c['gates'].get('axioms', {}).get('reported'),
                             theorem_type_matches=c['gates'].get('theorem_type', {}).get('matches')))
    table = {}
    for a in attempts:
        key = f"{a['task']}/{a['condition']}"
        t = table.setdefault(key, dict(attempts=0, accepted=0, timed_out=0))
        t['attempts'] += 1
        t['accepted'] += a['accepted']
        t['timed_out'] += a['timed_out']
    out = dict(schema='phase5-evaluation-results/1',
               compiled_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds'),
               manifest_frozen_utc=manifest['frozen_utc'], lean=manifest['lean'],
               tasks={k: dict(theorem=v['theorem'], source=v['source'], source_sha256=v['source_sha256'],
                              removed_in_base=v['removed_in_base'],
                              templates={c: d['template_sha256'] for c, d in v['conditions'].items()})
                      for k, v in manifest['tasks'].items()},
               summary=table, attempts=attempts, checker_controls=controls,
               rechecks_under_shared_lock=rechecks,
               scope='Lean-to-Lean proof regeneration on frozen, already-checked phase2/phase3 theorems. '
                     'Not C, libc, OS, Bash parser, Coq/VST or cross-assistant evidence. Unpowered: '
                     'two fresh attempts per cell; no claim about model superiority or novelty.')
    (HERE / 'results.json').write_text(json.dumps(out, indent=2) + '\n')
    print(json.dumps(table, indent=1))


if __name__ == '__main__':
    main()
