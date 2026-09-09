#!/usr/bin/env python3
"""Integrity negative tests for compare_bytes (temp copies under /tmp; original baselines untouched)."""
import io
import json
import shutil
import sys
import tempfile
import unittest.mock
from pathlib import Path

HERE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(HERE))
import compare_bytes as cb  # noqa: E402

BASELINE_SUMMARY_SHA = 'de34e271f22a94aca308ccd02497e345f70ce5c7c6e32a654009a8f38f3af4de'


def _one_case_map():
    curated = cb.load_cases(HERE / 'results' / 'cases_curated.tsv')
    name = next(iter(curated))
    return {name: curated[name]}, name, curated


def _continue_rec(name, entry, data, reads, writes, extra=None):
    exp = cb.expected(entry, data, reads, writes)
    rec = {
        'mode': 'run',
        'name': name,
        'outcome': 'continue',
        'rc': exp['status'],
        'attrs': {
            'delivered': {'hex': exp['delivered']},
            'input': {'hex': exp['unread']},
            'lost': {'hex': exp['lost']},
            'read_calls': exp['read_calls'],
            'write_calls': exp['write_calls'],
        },
        'elements': [{'element': 'block', 'arg': '0',
                      'attrs': {'cap': 32, 'len': 0, 'bytes': {'len': 0, 'hex': ''}}}],
    }
    if extra:
        rec.update(extra)
    return rec


def _write_jsonl(recs):
    td = Path(tempfile.mkdtemp(prefix='cb-integrity-', dir='/tmp'))
    p = td / 'suite.jsonl'
    p.write_text(''.join(json.dumps(r) + '\n' for r in recs))
    return p


def _sim_pre_fix_check_file(path, entry, cases):
    """SIMULATION of pre-fix checker (count + mismatches only). Not a recorded baseline run."""
    recs = []
    for line in path.read_text().splitlines():
        if line.strip():
            d = json.loads(line)
            if d['mode'] == 'run':
                recs.append(d)
    agree, problems, blocks = 0, [], 0
    for rec in recs:
        data, reads, writes = cases[rec['name']]
        exp = cb.expected(entry, data, reads, writes)
        obs = cb.observed(rec)
        el = rec.get('elements', [])
        block_ok = (len(el) == 1 and el[0]['element'] == 'block' and el[0]['arg'] == '0'
                    and el[0]['attrs']['cap'] == 32
                    and el[0]['attrs']['len'] == el[0]['attrs']['bytes']['len'] <= 32)
        if obs != exp or not block_ok:
            problems.append(rec['name'])
        else:
            agree += 1
            blocks += 1
    return dict(records=len(recs), agree=agree, mismatches=len(problems), problems=problems)


def _copy_suite_to_tmp():
    root = Path(tempfile.mkdtemp(prefix='cb-main-suite-', dir='/tmp'))
    shutil.copytree(HERE / 'results', root / 'results')
    return root


def _run_main_on_copy(root, extra_patch=None):
    buf = io.StringIO()
    kw = {'HERE': root, 'INTERP': root / 'results' / 'interp'}
    if extra_patch:
        kw.update(extra_patch)
    with unittest.mock.patch.multiple(cb, **kw):
        with unittest.mock.patch('sys.stdout', buf):
            rc = cb.main()
    return rc, buf.getvalue()


def _sha256(path):
    import hashlib
    return hashlib.sha256(path.read_bytes()).hexdigest()


def test_duplicate_replacing_missing():
    _, n1, full = _one_case_map()
    names = list(full)
    n2 = names[1]
    cases2 = {n1: full[n1], n2: full[n2]}
    rec = _continue_rec(n1, 'relay', *full[n1])
    path = _write_jsonl([rec, rec])  # two of n1, omit n2
    sim = _sim_pre_fix_check_file(path, 'relay', cases2)
    assert sim['records'] == 2 and sim['mismatches'] == 0, sim  # simulated hole only
    new = cb.check_file(path, 'relay', cases2)
    assert not new['integrity_ok']
    assert n2 in new['missing_names']
    assert n1 in new['duplicate_names']


def test_missing_case():
    _, n1, full = _one_case_map()
    names = list(full)
    n2 = names[1]
    cases2 = {n1: full[n1], n2: full[n2]}
    rec = _continue_rec(n1, 'relay', *full[n1])
    path = _write_jsonl([rec])
    new = cb.check_file(path, 'relay', cases2)
    assert not new['integrity_ok'] and n2 in new['missing_names']


def test_unexpected_case():
    cases, n1, full = _one_case_map()
    rec = _continue_rec(n1, 'relay', *full[n1])
    rec2 = dict(rec, name='not_a_case')
    path = _write_jsonl([rec, rec2])
    new = cb.check_file(path, 'relay', cases)
    assert not new['integrity_ok']
    assert 'not_a_case' in new['extra_names']


def test_absent_typed_suite_required():
    """Real main() against a temp copy with one typed file removed."""
    root = _copy_suite_to_tmp()
    typed = root / 'results' / 'interp' / 'curated_typed_relay.jsonl'
    assert typed.exists()
    typed.unlink()
    orig_summary = HERE / 'results' / 'compare_summary.json'
    before = orig_summary.read_bytes()
    rc, out = _run_main_on_copy(root)
    assert orig_summary.read_bytes() == before
    assert rc != 0
    assert 'PROBLEMS' in out
    written = json.loads((root / 'results' / 'compare_summary.json').read_text())
    files = [p.get('file') for p in written['positive']]
    assert 'curated_typed_relay.jsonl' in files
    hit = [p for p in written['positive'] if p.get('file') == 'curated_typed_relay.jsonl'][0]
    assert hit.get('integrity_ok') is False
    assert 'absent_typed_suite' in hit.get('integrity', [])
    assert written.get('all_positive_agree_and_all_mutants_detected') is False


def test_truncated_mutant_via_main():
    """Real main() with one mutant file truncated; all other suite files present."""
    root = _copy_suite_to_tmp()
    curated = cb.load_cases(HERE / 'results' / 'cases_curated.tsv')
    n1 = next(iter(curated))
    rec = _continue_rec(n1, 'relay', *curated[n1])
    rec['rc'] = 99
    rec['attrs'] = dict(rec['attrs'], delivered={'hex': 'ff'})
    mutant_path = root / 'results' / 'interp' / 'mut_wrong_offset_relay.jsonl'
    assert mutant_path.exists()
    mutant_path.write_text(json.dumps(rec) + '\n')
    orig_summary = HERE / 'results' / 'compare_summary.json'
    before = orig_summary.read_bytes()
    rc, out = _run_main_on_copy(root)
    assert orig_summary.read_bytes() == before
    assert rc != 0
    assert 'PROBLEMS' in out
    written = json.loads((root / 'results' / 'compare_summary.json').read_text())
    hits = [m for m in written['mutants'] if m.get('mutant') == 'mut_wrong_offset' and m.get('entry') == 'relay']
    assert hits, written['mutants']
    hit = hits[0]
    assert hit.get('integrity_ok') is False
    assert hit.get('records') != len(curated)
    assert written.get('all_positive_agree_and_all_mutants_detected') is False


def test_malformed_json():
    td = Path(tempfile.mkdtemp(prefix='cb-integrity-', dir='/tmp'))
    p = td / 'bad.jsonl'
    p.write_text('{not json\n')
    new = cb.check_file(p, 'relay', {'x': (b'', [], [])})
    assert not new['integrity_ok']
    assert any('json' in s for s in new['integrity'])


def test_malformed_record():
    cases, n1, full = _one_case_map()
    rec = {'mode': 'run', 'name': n1, 'outcome': 'continue'}  # missing attrs/rc
    path = _write_jsonl([rec])
    new = cb.check_file(path, 'relay', cases)
    assert new['mismatches'] > 0
    assert any(p.get('kind') == 'malformed_record' for p in new['problems'])
    assert new['agree'] == 0
    assert not new['integrity_ok']


def test_malformed_name_unhashable():
    cases, n1, full = _one_case_map()
    rec_ok = _continue_rec(n1, 'relay', *full[n1])
    rec_list = dict(rec_ok, name=[])
    rec_dict = dict(rec_ok, name={'k': 1})
    rec_none = dict(rec_ok, name=None)
    path = _write_jsonl([rec_ok, rec_list, rec_dict, rec_none])
    new = cb.check_file(path, 'relay', cases)
    kinds = [p.get('kind') for p in new['problems']]
    assert kinds.count('malformed_name') == 3, new['problems']
    assert not new['integrity_ok']
    assert any('malformed_names:' in s for s in new['integrity'])
    assert new['agree'] == 1


def test_missing_mode_fails_exact_set():
    _, n1, full = _one_case_map()
    names = list(full)
    n2 = names[1]
    cases2 = {n1: full[n1], n2: full[n2]}
    rec1 = _continue_rec(n1, 'relay', *full[n1])
    rec2 = _continue_rec(n2, 'relay', *full[n2])
    rec2.pop('mode')
    path = _write_jsonl([rec1, rec2])
    new = cb.check_file(path, 'relay', cases2)
    assert n2 in new['missing_names']
    assert not new['integrity_ok']
    assert new['records'] == 1


def test_failure_outcome_still_mismatch():
    cases, n1, full = _one_case_map()
    rec = _continue_rec(n1, 'relay', *full[n1], extra={'outcome': 'Failure', 'value': 'boom'})
    path = _write_jsonl([rec])
    new = cb.check_file(path, 'relay', cases)
    assert new['integrity_ok']
    assert new['mismatches'] == 1
    assert new['problems'][0]['observed'] is None


def test_frozen_positive_and_mutants_via_main():
    orig_summary = HERE / 'results' / 'compare_summary.json'
    before = orig_summary.read_bytes()
    assert _sha256(orig_summary) == BASELINE_SUMMARY_SHA
    root = _copy_suite_to_tmp()
    rc, out = _run_main_on_copy(root)
    assert orig_summary.read_bytes() == before
    assert _sha256(orig_summary) == BASELINE_SUMMARY_SHA
    assert rc == 0, out[-500:]
    assert 'OK' in out.splitlines()[-1]
    written = json.loads((root / 'results' / 'compare_summary.json').read_text())
    nrec = sum(p['records'] for p in written['positive'])
    assert nrec == 2046, nrec
    mutants = {m['mutant'] for m in written['mutants']}
    assert mutants == set(cb.MUTANTS)
    assert written['all_positive_agree_and_all_mutants_detected'] is True


if __name__ == '__main__':
    tests = [v for k, v in list(globals().items()) if k.startswith('test_')]
    failed = []
    for fn in tests:
        try:
            fn()
            print('PASS', fn.__name__)
        except Exception as e:
            failed.append((fn.__name__, e))
            print('FAIL', fn.__name__, type(e).__name__, e)
    sys.exit(1 if failed else 0)
