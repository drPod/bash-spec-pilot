#!/usr/bin/env python3
"""Aggregate attempts.jsonl into results.json: per (task, condition, model) acceptance counts,
timing, token/cost where available, and a flat list of every non-accepted reason seen. Run
after the matrix (or a partial matrix) finishes; safe to run repeatedly."""
import json
import statistics
from collections import defaultdict
from pathlib import Path

JOB = Path.home() / 'agent-jobs/astra-research/phase5/claude-resume/evaluation-artifact-4'
HERE = Path(__file__).resolve().parent


def main():
    rows = [json.loads(l) for l in (JOB / 'attempts.jsonl').read_text().splitlines() if l.strip()]
    cells = defaultdict(list)
    for r in rows:
        cells[(r['task'], r['condition'], r['model'])].append(r)
    summary = dict(schema='phase5-evaluation-expanded-results/1', total_attempts=len(rows), cells={})
    for (task, cond, model), attempts in sorted(cells.items()):
        accepted = [a for a in attempts if a['check'].get('accepted')]
        reasons = [a['check'].get('reject_reason') for a in attempts if not a['check'].get('accepted')]
        times = []
        cost = 0.0
        cost_known = 0
        for a in attempts:
            r0 = a['rounds'][0] if a.get('rounds') else None
            if r0 and r0.get('model_elapsed_seconds') is not None:
                times.append(r0['model_elapsed_seconds'])
            if r0 and r0.get('cost_usd'):
                cost += r0['cost_usd']
                cost_known += 1
        key = f'{task}|{cond}|{model}'
        summary['cells'][key] = dict(
            task=task, condition=cond, model=model, attempts=len(attempts),
            accepted=len(accepted), acceptance_rate=round(len(accepted) / len(attempts), 3) if attempts else None,
            reject_reasons=reasons,
            model_seconds_mean=round(statistics.mean(times), 1) if times else None,
            model_seconds=times,
            cost_usd_total=round(cost, 4) if cost_known else None,
            feedback_rounds_used=[a['feedback_rounds_used'] for a in attempts],
        )
    (JOB / 'results.json').write_text(json.dumps(summary, indent=2) + '\n')
    (HERE / 'RESULTS-SUMMARY.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(f"{len(rows)} attempts across {len(cells)} cells")
    for key, c in summary['cells'].items():
        print(f"  {key}: {c['accepted']}/{c['attempts']} accepted"
              + (f", mean {c['model_seconds_mean']}s" if c['model_seconds_mean'] else ''))


if __name__ == '__main__':
    main()
