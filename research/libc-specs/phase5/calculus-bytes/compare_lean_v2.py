#!/usr/bin/env python3
"""Structural comparison of the hand-transcribed `CalculusNested` Lean fragment's execution
(`integration/lean/NestedMain.lean`, run via the `nested-json` exe) against the ACTUAL pinned
OCaml interpreter's output for the same `fixtures/v2/nested_state.sc` functions
(`results/v2/nested_state__*.jsonl`, the real "run" record for each fn on the "unit" case).

Not byte-for-byte: the OCaml driver's JSON always carries the byte-relay root attributes
(delivered/input/lost/read_calls/write_calls/reads/writes) even when the program never touches
them, and its element lists are built by `assocSet`-to-front so sibling order need not match the
Lean side's. This script drops the byte-relay attrs, treats attribute maps and sibling element
lists as unordered, and requires exact agreement on: outcome, rc (continue only), every other
attribute value, and the full element subtree (name/arg/attrs/children) at every depth.

This is a concrete, checked correspondence for nine hand-picked programs from two fixtures
(a missing-parent failure, a path-order/nesting case, a full nested-attribute arithmetic case,
try/catch with an exception payload, try/finally, an uncaught raise, partial effects surviving a
raise, a `while` loop, and a 3-level-deep `exists`/`clear`/re-`touch` case), not a general
lowering-to-Lean pipeline and not a theorem about the OCaml source.
"""
import json
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
LEAN_EXE = Path.home() / '.cache/bash-spec-pilot/phase5-integration-lean/.lake/build/bin/nested-json'
BYTE_RELAY_ATTRS = {'delivered', 'input', 'lost', 'read_calls', 'write_calls', 'reads', 'writes'}


def normalize_elements(elements):
    out = {}
    for e in elements:
        key = (e['element'], e['arg'])
        assert key not in out, f'duplicate element {key}'
        out[key] = dict(attrs=dict(e['attrs']), elements=normalize_elements(e['elements']))
    return out


def parse_ocaml_exc_value(text):
    """OCaml's polymorphic printer for a `("TAG", payload)` exception value, e.g. '("E", 9)'."""
    m = re.fullmatch(r'\("([A-Za-z_][A-Za-z0-9_]*)", (-?\d+)\)', text)
    assert m, f'unrecognized exception value repr: {text!r}'
    return [m.group(1), int(m.group(2))]


def normalize_ocaml(rec):
    if rec['outcome'] == 'raise':
        return dict(outcome='raise', value=parse_ocaml_exc_value(rec['value']))
    if rec['outcome'] != 'continue':
        return dict(outcome=rec['outcome'])
    attrs = {k: v for k, v in rec['attrs'].items() if k not in BYTE_RELAY_ATTRS}
    return dict(outcome='continue', rc=rec['rc'], attrs=attrs,
                elements=normalize_elements(rec['elements']))


def normalize_lean(rec):
    if rec['outcome'] == 'raise':
        return dict(outcome='raise', value=rec['value'])
    if rec['outcome'] != 'continue':
        return dict(outcome=rec['outcome'])
    st = rec['state']
    return dict(outcome='continue', rc=rec['rc'], attrs=dict(st['attrs']),
                elements=normalize_elements(st['elements']))


def load_ocaml_run(fixture, entry):
    path = HERE / 'results' / 'v2' / f'{fixture}__{entry}.jsonl'
    recs = [json.loads(l) for l in path.read_text().splitlines() if l.strip()]
    runs = [r for r in recs if r.get('mode') == 'run']
    assert len(runs) == 1, (path, len(runs))
    return runs[0]


def main():
    out = subprocess.check_output([str(LEAN_EXE)], text=True)
    lean_recs = {json.loads(l)['lean_entry']: json.loads(l) for l in out.splitlines() if l.strip()}
    pairs = [('missing_parent', 'nested_state', 'missing_parent'),
             ('wrong_order_probe', 'nested_state', 'wrong_order_probe'),
             ('deep_set', 'nested_state', 'deep_set'),
             ('catch_scope', 'scope_ok', 'catch_scope'),
             ('finally_runs', 'scope_ok', 'finally_runs'),
             ('uncaught_is_raise', 'scope_ok', 'uncaught_is_raise'),
             ('partial_effects_survive_raise', 'scope_ok', 'partial_effects_survive_raise'),
             ('loop_let', 'scope_ok', 'loop_let'),
             ('deep3', 'nested_state', 'deep3'),
             ('deep_clear', 'nested_state', 'deep_clear'),
             ('cleared_then_read', 'nested_state', 'cleared_then_read')]
    problems = []
    for lean_name, fixture, entry in pairs:
        lean = normalize_lean(lean_recs[lean_name])
        ocaml = normalize_ocaml(load_ocaml_run(fixture, entry))
        status = 'OK' if lean == ocaml else 'MISMATCH'
        print(f'{lean_name:20s} {status}')
        if lean != ocaml:
            problems.append(dict(name=lean_name, lean=lean, ocaml=ocaml))
    result = dict(checked=len(pairs), problems=problems)
    (HERE / 'results' / 'v2' / 'compare_lean_v2.json').write_text(json.dumps(result, indent=1))
    if problems:
        print('PROBLEMS', json.dumps(problems, indent=1)[:4000])
        return 1
    print(f'checked={len(pairs)} problems=0 OK')
    return 0


if __name__ == '__main__':
    sys.exit(main())
