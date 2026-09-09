#!/usr/bin/env python3
"""Compare Lean pointer events with the independent Python/C reference.

Probe-only initialized-prefix and snapshot metadata is checked separately, not attributed to Lean."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import time

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT/'validation'))
from ptrcheck.cases import build_cases, corpus_hash, corpus_manifest
from ptrcheck.exec_bounded import Scratch, run_bounded
from ptrcheck.pointer_model import run_pointer_machine


def projection(doc):
    f = doc['final']
    return dict(output=list(bytes.fromhex(f['output_hex'])),
        remaining=list(bytes.fromhex(f['unread_hex'])), pending=list(bytes.fromhex(f['pending_hex'])),
        status=f['status'], read_calls=f['read_calls'], write_calls=f['write_calls'],
        events=[dict(kind=e['kind'], block=e['block'], offset=e['offset'], request=e['request'],
                     action=e['action'], result=e['result'], bytes=list(bytes.fromhex(e['bytes_hex'])))
                for e in doc['events']])


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--model', required=True, type=Path)
    ap.add_argument('--tier', choices=['quick', 'standard'], default='standard')
    ap.add_argument('--out', type=Path, default=Path.home()/'.cache/bash-spec-pilot/phase3-lean-validation')
    args = ap.parse_args()
    out = args.out.expanduser().resolve()
    repo = ROOT.parents[2]
    if out == repo or repo in out.parents:
        ap.error('output must stay outside the source repository')
    out.mkdir(parents=True, exist_ok=True)
    model = args.model.expanduser().resolve()
    scratch = Scratch(out/'scratch')
    env = dict(os.environ, LEAN_NUM_THREADS='1', LEAN_STACK_SIZE_KB='16384')
    cases = build_cases(args.tier)
    rows = []
    start = time.monotonic()
    with (out/'per_case.jsonl').open('w') as log:
        for case in cases:
            result = run_bounded([str(model), *case.schedule_argv()], case.data, scratch,
                wall=10, as_bytes=3221225472, cpu_seconds=10, env=env)
            row = dict(name=case.name, reject=case.expect_reject, status=result.status,
                       timed_out=result.timed_out, seconds=result.wall,
                       peak_rss_kib=result.maxrss_kb, stderr_hex=result.stderr.hex())
            if case.expect_reject:
                row['passed'] = result.status == 64 and result.stdout == b'' and not result.timed_out
            else:
                expected = projection(run_pointer_machine(case.data, case.reads, case.writes, case.name))
                try:
                    actual = json.loads(result.stdout)
                except (ValueError, UnicodeDecodeError):
                    actual = {'invalid_output_hex': result.stdout.hex()}
                row.update(expected=expected, actual=actual,
                    passed=result.status == 0 and result.stderr == b'' and not result.timed_out and actual == expected)
            rows.append(row)
            log.write(json.dumps(row, sort_keys=True)+'\n')
            log.flush()
            if result.timed_out or result.status < 0 or (not case.expect_reject and result.status != 0):
                raise RuntimeError('Model runtime failure; stopping immediately: '+case.name)
    record = dict(passed=all(r['passed'] for r in rows), count=len(rows),
        valid=sum(not r['reject'] for r in rows), rejected=sum(r['reject'] for r in rows),
        mismatches=[r['name'] for r in rows if not r['passed']], corpus_sha256=corpus_hash(cases),
        corpus_manifest=corpus_manifest(cases), executable=str(model),
        executable_sha256=hashlib.sha256(model.read_bytes()).hexdigest(),
        elapsed_seconds=time.monotonic()-start,
        projection='kind/block/offset/request/action/result/bytes and final bytes/status/counters; no C/Lean initialized-metadata comparison',
        scope='Finite differential evidence, not C-to-Lean preservation')
    (out/'results.json').write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps({k:record[k] for k in ['passed','count','valid','rejected','mismatches','corpus_sha256','elapsed_seconds']}))
    if not record['passed']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
