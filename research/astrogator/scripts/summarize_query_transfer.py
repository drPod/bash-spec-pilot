#!/usr/bin/env python3
"""Summarize decision changes, without assigning correctness to either query."""
from collections import Counter, defaultdict
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    path = ROOT / 'reports/generated-query-verifier.jsonl'
    records = [json.loads(line) for line in path.read_text().splitlines()]
    ids = [r['sample_id'] for r in records]
    if len(set(ids)) != len(ids): raise RuntimeError('Duplicate sample results')
    groups = defaultdict(list)
    for r in records: groups[r['task_id']].append(r)
    summary = {'observed': len(records), 'expected': 2310, 'complete': len(records) == 2310,
               'counts': dict(Counter(r['status'] for r in records)), 'tasks': {},
               'limitations': ['Outcome changes are not correctness measurements.',
                   'Generated-query invalidity is pipeline failure, not code rejection.',
                   'Supplied p17 query uses declared acc240 domain substitution; generated queries are unmodified.',
                   'Repair arm has one final query per task, including retained seed outputs.']}
    for task, rows in sorted(groups.items()):
        transitions = Counter((r['supplied_query_status'], r['status']) for r in rows)
        summary['tasks'][task] = {'n': len(rows), 'transitions': [
            {'supplied': a, 'generated': b, 'count': n} for (a, b), n in sorted(transitions.items())]}
    (ROOT / 'reports/generated-query-transfer.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps({k: v for k, v in summary.items() if k != 'tasks'}, indent=2))


if __name__ == '__main__': main()
