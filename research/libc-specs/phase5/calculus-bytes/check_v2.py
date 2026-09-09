#!/usr/bin/env python3
"""Check the v2 semantics fixtures (calculus-resume-2, 2026-09-07) against hand-derived
expectations, and the v2 negative fixtures against the requirement that the lowering
REJECTS them (with a reason, at a position).

Inputs (produced inside the container by cb_main.exe v2, copied to results/v2/):
  results/v2/<fixture>__<fn>.jsonl   one `run` record per fn on cases/cases_unit.tsv
  results/v2/lower_negatives.jsonl   `lower` records for fixtures/v2/neg/*.sc
  results/v2/lower_positives.jsonl   `lower` records for the positive v2 fixtures

Expectations are the adapter's documented semantics (MAPPING.md, section v2). They were
derived by hand from the source text before the run; nothing here reads the OCaml output
to define the expectation. Exit 0 only if every expectation holds. Finite observations
only: no theorem about the OCaml program is implied.
"""
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
V2 = HERE / 'results' / 'v2'

# (fixture, fn) -> expected (outcome, rc-or-None[, raised tag])
EXPECT = {
    # nested_state.sc: parent/sibling preservation through set_attr / pos_elem / neg_elem
    ('nested_state', 'deep_set'): ('continue', 7 + 90 + 1000 + 100000 + 2000000 + 700000000),
    ('nested_state', 'deep_clear'): ('continue', 9 + 1000 + 100000 + 2000000),
    ('nested_state', 'deep_touch_keeps'): ('continue', 7 + 700 + 10000),
    ('nested_state', 'deep3'): ('continue', 60 + 400 + 3000 + 50000 + 800000),
    ('nested_state', 'missing_parent'): ('failure', None),
    ('nested_state', 'cleared_then_read'): ('failure', None),
    ('nested_state', 'wrong_order_probe'): ('continue', 1),
    # short_circuit.sc: `bump`/`bump_false` are helpers called by the other fns' action calls
    # (each first sets `count = 0`, a precondition `bump` relies on but does not establish
    # itself); run_v2_units.sh calls every grep-matched fn directly on a fresh state, so calling
    # a helper directly (with `count` unset) is expected to fail at its `count = count + 1` read.
    ('short_circuit', 'bump'): ('failure', None),
    ('short_circuit', 'bump_false'): ('failure', None),
    ('short_circuit', 'sc_skip_trap_and'): ('continue', 0),
    ('short_circuit', 'sc_skip_trap_or'): ('continue', 1),
    ('short_circuit', 'sc_eval_trap_and'): ('failure', None),
    ('short_circuit', 'sc_eval_trap_or'): ('failure', None),
    ('short_circuit', 'sc_action_skipped'): ('continue', 0),
    ('short_circuit', 'sc_action_taken'): ('continue', 1),
    ('short_circuit', 'sc_or_action_skipped'): ('continue', 0),
    ('short_circuit', 'sc_or_action_taken'): ('continue', 1),
    ('short_circuit', 'sc_left_to_right'): ('continue', 2),
    ('short_circuit', 'sc_nested_or_and'): ('continue', 3),
    ('short_circuit', 'sc_relay_style_assert'): ('continue', 1),
    ('short_circuit', 'sc_assert_fails_skips_trap'): ('raise', None, 'AssertionFailure'),
    ('short_circuit', 'sc_not_and'): ('continue', 1),
    # finite_ints.sc (63-bit carrier, trapping): `u8_param(b : byte)` is called by
    # `u8_param_ok`/`u8_param_trap` with an actual byte argument; run_v2_units.sh's direct call
    # binds it to the generic `unit` case's `()` argument instead, a `byte`/`unit` type
    # mismatch that is expected to fail at parameter binding.
    ('finite_ints', 'u8_param'): ('failure', None),
    ('finite_ints', 'carrier_max'): ('continue', 4611686018427387903),
    ('finite_ints', 'overflow_add'): ('failure', None),
    ('finite_ints', 'overflow_sub'): ('failure', None),
    ('finite_ints', 'overflow_mul'): ('failure', None),
    ('finite_ints', 'overflow_neg'): ('failure', None),
    ('finite_ints', 'div_trunc'): ('continue', -3),
    ('finite_ints', 'mod_sign'): ('continue', -1),
    ('finite_ints', 'div_zero'): ('failure', None),
    ('finite_ints', 'u8_ok'): ('continue', 255),
    ('finite_ints', 'u8_overflow_runtime'): ('failure', None),
    ('finite_ints', 'u8_local_annot'): ('continue', 255),
    ('finite_ints', 'u8_local_annot_trap'): ('failure', None),
    ('finite_ints', 'u8_param_ok'): ('continue', 255),
    ('finite_ints', 'u8_param_trap'): ('failure', None),
    ('finite_ints', 'u64_negative_trap'): ('failure', None),
    ('finite_ints', 'ret_u8_trap'): ('failure', None),
    ('finite_ints', 'ret_u8_ok'): ('continue', 255),
    ('finite_ints', 'typed_literal_widths'): ('continue', 255 - 128 + 65535),
    ('finite_ints', 'big_attr'): ('continue', -4611686018427387904),
    ('finite_ints', 'char_lit'): ('continue', 33),
    # scope_ok.sc
    ('scope_ok', 'branch_lets'): ('continue', 6),
    ('scope_ok', 'loop_let'): ('continue', 6),
    ('scope_ok', 'catch_scope'): ('continue', 4),
    ('scope_ok', 'finally_runs'): ('continue', 11),
    ('scope_ok', 'uncaught_is_raise'): ('raise', None, 'E'),
    ('scope_ok', 'partial_effects_survive_raise'): ('continue', 6),
}

# nested_state deep_set: exact final state tree expected (root attrs v, a(1){v,b(2){v,w},b(3){v}}, a(2){v})
DEEP_SET_TREE = {
    'attrs': {'v': 100},
    'elements': {
        ('a', '1'): {'attrs': {'v': 10},
                     'elements': {('b', '2'): {'attrs': {'v': 7, 'w': 70}, 'elements': {}},
                                  ('b', '3'): {'attrs': {'v': 9}, 'elements': {}}}},
        ('a', '2'): {'attrs': {'v': 20}, 'elements': {}},
    },
}
DEEP_CLEAR_TREE = {
    'attrs': {'v': 100},
    'elements': {
        ('a', '1'): {'attrs': {'v': 10}, 'elements': {('b', '3'): {'attrs': {'v': 9}, 'elements': {}}}},
        ('a', '2'): {'attrs': {'v': 20}, 'elements': {}},
    },
}
# deep3: 3 levels (a(1).b(2).a(3)); a(1).b(2).a(3) is `clear`ed then `touch`ed again, so its
# final attrs are EMPTY (a fresh element), not the v=5/w=8 it held before the clear.
DEEP3_TREE = {
    'attrs': {'v': 3},
    'elements': {
        ('a', '1'): {'attrs': {'v': 4},
                     'elements': {('b', '2'): {'attrs': {'v': 6},
                                                'elements': {('a', '3'): {'attrs': {}, 'elements': {}}}}}},
    },
}
DRIVER_ATTRS = {'input', 'delivered', 'lost', 'reads', 'writes', 'read_calls', 'write_calls'}

NEGATIVES_MUST_REJECT = [
    'neg_bool_and_int', 'neg_dup_alias', 'neg_literal_range', 'neg_scope_after_block',
    'neg_unknown_type_int', 'neg_shadow', 'neg_cond_int', 'neg_eq_list', 'neg_uninterp_shape',
    'neg_i64_literal_carrier', 'neg_arg_type', 'neg_attr_literal_range', 'neg_arith_cond', 'neg_sc_rhs_int',
]


def tree(rec_state):
    """Normalize a cb_main state JSON into the comparable tree (driver attrs dropped at root)."""
    attrs = {k: v for k, v in rec_state['attrs'].items() if k not in DRIVER_ATTRS}
    elems = {}
    for el in rec_state.get('elements', []):
        elems[(el['element'], el['arg'])] = tree(el)
    return {'attrs': attrs, 'elements': elems}


def load_runs(path):
    recs = [json.loads(l) for l in path.read_text().splitlines() if l.strip()]
    lower = [r for r in recs if r.get('mode') == 'lower']
    runs = [r for r in recs if r.get('mode') == 'run']
    return lower, runs


def main():
    problems = []
    checked = 0
    hashes = {}
    for (fixture, fn), exp in sorted(EXPECT.items()):
        path = V2 / f'{fixture}__{fn}.jsonl'
        if not path.exists():
            problems.append(f'{fixture}.{fn}: missing {path.name}')
            continue
        lower, runs = load_runs(path)
        if len(lower) != 1 or lower[0].get('outcome') != 'lowered':
            problems.append(f'{fixture}.{fn}: not lowered: {lower[:1]}')
            continue
        hashes[fixture] = {f['name']: f['calculus_md5'] for f in lower[0]['fns']}
        if len(runs) != 1 or runs[0].get('name') != 'unit':
            problems.append(f'{fixture}.{fn}: expected exactly one unit run record, got {len(runs)}')
            continue
        r = runs[0]
        outcome, rc = exp[0], exp[1]
        if r.get('outcome') != outcome:
            problems.append(f'{fixture}.{fn}: outcome {r.get("outcome")!r} (value={r.get("value")!r}), expected {outcome!r}')
            continue
        if outcome == 'continue' and r.get('rc') != rc:
            problems.append(f'{fixture}.{fn}: rc {r.get("rc")!r}, expected {rc!r}')
            continue
        if outcome == 'raise' and not str(r.get('value', '')).startswith(f'("{exp[2]}"'):
            problems.append(f'{fixture}.{fn}: raised {r.get("value")!r}, expected tag {exp[2]}')
            continue
        if fixture == 'nested_state' and fn == 'deep_set' and tree(r) != DEEP_SET_TREE:
            problems.append(f'{fixture}.{fn}: final state tree {tree(r)!r} != expected {DEEP_SET_TREE!r}')
            continue
        if fixture == 'nested_state' and fn == 'deep_clear' and tree(r) != DEEP_CLEAR_TREE:
            problems.append(f'{fixture}.{fn}: final state tree {tree(r)!r} != expected {DEEP_CLEAR_TREE!r}')
            continue
        if fixture == 'nested_state' and fn == 'deep3' and tree(r) != DEEP3_TREE:
            problems.append(f'{fixture}.{fn}: final state tree {tree(r)!r} != expected {DEEP3_TREE!r}')
            continue
        # touching an already-present element is add_if_absent: the tree is unchanged from
        # deep_set's (touch is not a second, resetting construction).
        if fixture == 'nested_state' and fn == 'deep_touch_keeps' and tree(r) != DEEP_SET_TREE:
            problems.append(f'{fixture}.{fn}: final state tree {tree(r)!r} != expected {DEEP_SET_TREE!r}')
            continue
        checked += 1
    # negatives: every one rejected by the lowering with a reason and position
    negpath = V2 / 'lower_negatives.jsonl'
    rejected = {}
    if negpath.exists():
        for l in negpath.read_text().splitlines():
            if not l.strip():
                continue
            d = json.loads(l)
            rejected[Path(d['file']).stem] = d
    for n in NEGATIVES_MUST_REJECT:
        d = rejected.get(n)
        if d is None:
            problems.append(f'{n}: no lower record')
        elif d.get('outcome') != 'rejected' or not d.get('reason') or 'line' not in d:
            problems.append(f'{n}: expected rejected-with-reason, got {d}')
        else:
            checked += 1
    summary = dict(checked=checked, problems=problems, calculus_md5=hashes,
                   negatives={n: (rejected.get(n) or {}).get('reason') for n in NEGATIVES_MUST_REJECT})
    (V2 / 'check_v2_summary.json').write_text(json.dumps(summary, indent=1) + '\n')
    for p in problems:
        print('PROBLEM', p)
    print(f'checked={checked} problems={len(problems)}', 'OK' if not problems else 'PROBLEMS')
    return 0 if not problems else 1


if __name__ == '__main__':
    sys.exit(main())
