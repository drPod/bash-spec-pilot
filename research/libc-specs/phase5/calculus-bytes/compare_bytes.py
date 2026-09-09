#!/usr/bin/env python3
"""Compare pinned-interpreter observations with the phase3 reference pointer machine.

Inputs: the JSONL files produced by cb_main.exe `run` inside the container (copied to
results/interp/), and the case files they were run on. The oracle is
phase3/validation/ptrcheck/pointer_model.run_pointer_machine, the independently checked
reference of phase3 (Lean-validated on the same corpus). Compositions are derived from
single runs: `relay_seq_relay` re-runs the reference on the residual streams and
schedules; `relay_and_mark` / `relay_or_mark` append byte 0x21 under the phase3 shell
grammar's status rule. This is an empirical comparison of finite observations, not a
theorem about either program.

Exit 0 only if every positive record agrees and every mutant differs on at least one case
of some entry that exercises the mutated function (mut_bad_byte only changes mark()).
"""
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1] / 'phase3' / 'validation'))
from ptrcheck.pointer_model import run_pointer_machine  # noqa: E402

import os
# v2 (calculus-resume-2, 2026-09-07): the same checker can be pointed at a different output
# directory / summary file; defaults are the v1 baseline so the frozen results are untouched.
INTERP = Path(os.environ.get('CB_INTERP_DIR', HERE / 'results' / 'interp'))
# v2 extra positive suite: byte_relay_exec.sc with `assert off <= n && n <= b.len` (the v1
# negative fixture neg_short_circuit_effect.sc, accepted by the v2 short-circuit lowering)
EXTRA_POSITIVE = [(f, e) for f, e in [('curated_scassert_relay', 'relay'), ('curated_scassert_relay_and_mark', 'relay_and_mark')]
                  if os.environ.get('CB_V2')]
ENTRIES = ['relay', 'relay_caught', 'relay_seq_relay', 'relay_and_mark', 'relay_or_mark']
MUTANTS = ['mut_wrong_offset', 'mut_uninit_region', 'mut_uninit_noassert', 'mut_bad_byte',
           'mut_status_swap', 'mut_zero_write_retry', 'mut_no_fresh_block']


def load_cases(path):
    cases = {}
    for line in path.read_text().splitlines():
        if not line.strip() or line.startswith('#'):
            continue
        name, hexdata, reads, writes = line.split('\t')
        cases[name] = (bytes.fromhex(hexdata),
                       [int(x) for x in reads.split(',') if x], [int(x) for x in writes.split(',') if x])
    return cases


def reference(data, reads, writes):
    f = run_pointer_machine(data, reads, writes, 'ref')['final']
    return dict(status=f['status'], delivered=f['output_hex'], unread=f['unread_hex'], lost=f['pending_hex'],
                read_calls=f['read_calls'], write_calls=f['write_calls'])


def expected(entry, data, reads, writes):
    r1 = reference(data, reads, writes)
    if entry in ('relay', 'relay_caught'):
        return r1
    if entry == 'relay_seq_relay':
        r2 = reference(bytes.fromhex(r1['unread']), reads[r1['read_calls']:], writes[r1['write_calls']:])
        return dict(status=r2['status'], delivered=r1['delivered'] + r2['delivered'], unread=r2['unread'],
                    lost=r1['lost'] + r2['lost'], read_calls=r1['read_calls'] + r2['read_calls'],
                    write_calls=r1['write_calls'] + r2['write_calls'])
    if entry == 'relay_and_mark':
        if r1['status'] == 0:
            return dict(r1, delivered=r1['delivered'] + '21')
        return r1
    if entry == 'relay_or_mark':
        if r1['status'] != 0:
            return dict(r1, delivered=r1['delivered'] + '21', status=0)
        return r1
    raise ValueError(entry)


def observed(rec):
    if rec['outcome'] != 'continue':
        return None
    a = rec['attrs']
    return dict(status=rec['rc'], delivered=a['delivered']['hex'], unread=a['input']['hex'], lost=a['lost']['hex'],
                read_calls=a['read_calls'], write_calls=a['write_calls'])


def records(path):
    out, load_errors = [], []
    try:
        text = path.read_text()
    except OSError as e:
        return [], [f'read_error:{e}']
    for i, line in enumerate(text.splitlines(), 1):
        if not line.strip():
            continue
        try:
            d = json.loads(line)
        except json.JSONDecodeError as e:
            load_errors.append(f'line {i}: json:{e.msg}')
            continue
        if not isinstance(d, dict):
            load_errors.append(f'line {i}: not an object')
            continue
        if d.get('mode') == 'run':
            out.append(d)
    return out, load_errors


def _block_ok(rec):
    # block element: exactly one block(0) with cap 32 and len == |bytes| <= 32; the
    # final len must be the last chunk length (0 after EOF), which the reference exposes
    # only indirectly, so len/bytes consistency is what is checked here. Exact buffer
    # contents are not claimed.
    try:
        el = rec.get('elements', [])
        return (len(el) == 1 and el[0]['element'] == 'block' and el[0]['arg'] == '0'
                and el[0]['attrs']['cap'] == 32
                and el[0]['attrs']['len'] == el[0]['attrs']['bytes']['len'] <= 32)
    except (TypeError, KeyError, IndexError):
        return False


def check_file(path, entry, cases):
    recs, load_errors = records(path)
    agree, problems, blocks = 0, [], 0
    seen, duplicates = [], []
    expected_names = set(cases)
    for rec in recs:
        name = rec.get('name')
        if not isinstance(name, str):
            problems.append(dict(name=name, kind='malformed_name', outcome=rec.get('outcome'),
                                 expected=None, observed=None, block_ok=False))
            continue
        if name in seen:
            duplicates.append(name)
        seen.append(name)
        if name not in cases:
            problems.append(dict(name=name, kind='unexpected_name', outcome=rec.get('outcome'),
                                 expected=None, observed=None, block_ok=False))
            continue
        try:
            data, reads, writes = cases[name]
            exp = expected(entry, data, reads, writes)
            obs = observed(rec)
            block_ok = _block_ok(rec)
        except (KeyError, TypeError, ValueError) as e:
            problems.append(dict(name=name, kind='malformed_record', error=str(e),
                                 outcome=rec.get('outcome'), expected=None, observed=None,
                                 block_ok=False))
            continue
        if obs != exp or not block_ok:
            problems.append(dict(name=name, outcome=rec.get('outcome'), expected=exp, observed=obs,
                                 block_ok=block_ok, value=rec.get('value')))
        elif name not in duplicates:
            agree += 1
            blocks += 1
    seen_set = set(seen)
    missing = sorted(expected_names - seen_set)
    extra = sorted(seen_set - expected_names)
    integrity = []
    integrity.extend(load_errors)
    if duplicates:
        integrity.append('duplicate_names:' + ','.join(str(x) for x in duplicates))
    if missing:
        integrity.append('missing_names:' + ','.join(missing))
    if extra:
        integrity.append('extra_names:' + ','.join(str(x) for x in extra))
    if any(p.get('kind') == 'malformed_name' for p in problems):
        integrity.append('malformed_names:' + ','.join(
            repr(p.get('name')) for p in problems if p.get('kind') == 'malformed_name'))
    integrity_ok = not integrity and not any(
        p.get('kind') in ('malformed_record', 'unexpected_name', 'malformed_name') for p in problems)
    return dict(file=path.name, entry=entry, records=len(recs), agree=agree, block_ok=blocks,
                mismatches=len(problems), problems=problems, missing_names=missing, extra_names=extra,
                duplicate_names=duplicates, integrity=integrity, integrity_ok=integrity_ok)


def main():
    curated = load_cases(HERE / 'results' / 'cases_curated.tsv')
    phase3 = load_cases(HERE / 'results' / 'cases_phase3_standard.tsv')
    summary = dict(positive=[], mutants=[])
    ok = True
    for entry in ENTRIES:
        res = check_file(INTERP / f'curated_{entry}.jsonl', entry, curated)
        summary['positive'].append(res)
        ok &= res['integrity_ok'] and res['mismatches'] == 0 and res['records'] == len(curated)
    for entry in ('relay', 'relay_caught'):
        res = check_file(INTERP / f'phase3_{entry}.jsonl', entry, phase3)
        summary['positive'].append(res)
        ok &= res['integrity_ok'] and res['mismatches'] == 0 and res['records'] == len(phase3)
    # typed-literal variant of the same source (needs the private lexer patch to lex at all);
    # both declared files are required.
    for entry in ('relay', 'relay_and_mark'):
        path = INTERP / f'curated_typed_{entry}.jsonl'
        if not path.exists():
            summary['positive'].append(dict(file=path.name, entry=entry, records=0, agree=0, block_ok=0,
                                            mismatches=1, problems=[], missing_names=[], extra_names=[],
                                            duplicate_names=[], integrity=['absent_typed_suite'], integrity_ok=False))
            ok = False
            continue
        res = check_file(path, entry, curated)
        summary['positive'].append(res)
        ok &= res['integrity_ok'] and res['mismatches'] == 0 and res['records'] == len(curated)
    for fname, entry in EXTRA_POSITIVE:
        res = check_file(INTERP / f'{fname}.jsonl', entry, curated)
        summary['positive'].append(res)
        ok &= res['integrity_ok'] and res['mismatches'] == 0 and res['records'] == len(curated)
    for m in MUTANTS:
        detected_any = False
        full_set = True
        for entry in ('relay', 'relay_and_mark'):
            path = INTERP / f'{m}_{entry}.jsonl'
            lower_recs = []
            if os.environ.get('CB_V2') and path.exists():
                for l in path.read_text().splitlines():
                    try:
                        d = json.loads(l)
                    except json.JSONDecodeError:
                        continue
                    if isinstance(d, dict) and d.get('mode') == 'lower':
                        lower_recs.append(d)
            if lower_recs and lower_recs[0].get('outcome') == 'rejected':
                # v2: the mutant is rejected statically by the typed lowering (no run records);
                # recorded as detection with the reason, not as a missing suite
                summary['mutants'].append(dict(mutant=m, entry=entry, records=0, agree=0, differing=0,
                                               differing_outcomes={'rejected_at_lowering': 1},
                                               integrity_ok=True, integrity=[],
                                               example=dict(kind='rejected_at_lowering', reason=lower_recs[0].get('reason'),
                                                            line=lower_recs[0].get('line'), column=lower_recs[0].get('column'))))
                detected_any = True
                continue
            res = check_file(path, entry, curated)
            outcomes = {}
            for p in res['problems']:
                oc = p.get('outcome')
                outcomes[oc] = outcomes.get(oc, 0) + 1
            summary['mutants'].append(dict(mutant=m, entry=entry, records=res['records'], agree=res['agree'],
                                           differing=res['mismatches'], differing_outcomes=outcomes,
                                           integrity_ok=res['integrity_ok'], integrity=res['integrity'],
                                           example=res['problems'][0] if res['problems'] else None))
            # full expected case set required; detection is a field/outcome mismatch on that set
            full_set = full_set and res['integrity_ok'] and res['records'] == len(curated)
            field_diffs = [p for p in res['problems'] if p.get('kind') not in ('malformed_record', 'unexpected_name', 'malformed_name')]
            detected_any = detected_any or len(field_diffs) > 0
        ok &= full_set and detected_any
    for res in summary['positive']:
        res['problems'] = res['problems'][:5]
    summary['all_positive_agree_and_all_mutants_detected'] = ok
    # summary path resolved at call time (tests redirect HERE to a temp copy)
    summary_path = Path(os.environ['CB_SUMMARY']) if os.environ.get('CB_SUMMARY') else HERE / 'results' / 'compare_summary.json'
    summary_path.write_text(json.dumps(summary, indent=1) + '\n')
    for res in summary['positive']:
        print(f"{res['file']:34} {res['entry']:16} records={res['records']:4} agree={res['agree']:4} block_ok={res['block_ok']:4} mismatches={res['mismatches']}")
    for res in summary['mutants']:
        print(f"{res['mutant']:22} {res['entry']:16} records={res['records']:3} agree={res['agree']:3} differing={res['differing']:3} {res['differing_outcomes']}")
    print('OK' if ok else 'PROBLEMS')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
