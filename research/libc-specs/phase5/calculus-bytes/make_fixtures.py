#!/usr/bin/env python3
"""Generate the mutant fixtures and the case files for the calculus-bytes run.

Mutants are byte_relay_exec.sc with exactly one documented textual change each; the
script fails if a replacement does not apply exactly once. Case files list
`name<TAB>input_hex<TAB>reads<TAB>writes`. The phase3 corpus (ptrcheck.cases,
tier standard) minus its CLI-reject cases is the large case file; a small curated
file covers the handoff's named observations and feeds the Coq oracle.
"""
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1] / 'phase3' / 'validation'))
from ptrcheck.cases import build_cases, corpus_hash  # noqa: E402

BASE = (HERE / 'fixtures' / 'byte_relay_exec.sc').read_text()

MUTANTS = {
    # name: (old, new, what it controls)
    'mut_wrong_offset': (
        'let w = write_block(b, off, r);\n      if w <= 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 2;\n      }\n      off = off + w;\n    }\n  }\n}\n\n// Same relay',
        'let w = write_block(b, off + 1, r);\n      if w <= 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 2;\n      }\n      off = off + w;\n    }\n  }\n}\n\n// Same relay',
        'relay() retries from offset off+1: wrong bytes delivered / spurious status 2'),
    'mut_uninit_region': (
        'let w = write_block(b, off, r);\n      if w <= 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 2;\n      }\n      off = off + w;\n    }\n  }\n}\n\n// Same relay',
        'let w = write_block(b, off, b.cap);\n      if w <= 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 2;\n      }\n      off = off + w;\n    }\n  }\n}\n\n// Same relay',
        'relay() requests the whole capacity: source-level assert n <= b.len raises AssertionFailure for short chunks'),
    'mut_uninit_noassert': (
        '  assert off <= n;\n  assert n <= b.len;\n  let l = b.len;\n  assert l <= b.cap;\n  let req = slice(b.bytes, off, n);',
        '  let req = slice(b.bytes, off, b.cap);',
        'write_block() slices [off, cap) with no assert: the slice builtin rejects the uninitialized range -> interpreter Failure for short chunks'),
    'mut_bad_byte': (
        'delivered = append(delivered, single(33));',
        'delivered = append(delivered, single(256));',
        'mark() writes byte 256: builtin range check -> interpreter Failure'),
    'mut_status_swap': (
        '    if r < 0 { return 1; }\n    if r == 0 { return 0; }\n    let off = 0;\n    while off < r {\n      let w = write_block(b, off, r);\n      if w <= 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 2;',
        '    if r < 0 { return 2; }\n    if r == 0 { return 0; }\n    let off = 0;\n    while off < r {\n      let w = write_block(b, off, r);\n      if w <= 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 1;',
        'read error -> 2 and write failure -> 1 (the byte_relay_plain.sc style status confusion)'),
    'mut_zero_write_retry': (
        '      if w <= 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 2;\n      }\n      off = off + w;\n    }\n  }\n}\n\n// Same relay',
        '      if w < 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 2;\n      }\n      off = off + w;\n    }\n  }\n}\n\n// Same relay',
        'zero write is retried instead of failing (phase3 zero-retry mutant)'),
    'mut_no_fresh_block': (
        'fn relay() -> i64 {\n  clear block(0);\n  touch block(0);\n',
        'fn relay() -> i64 {\n',
        'relay() never creates block(0): attribute writes on a missing element -> interpreter Failure'),
}

NEGATIVES = {
    'neg_unknown_uninterp.sc': BASE.replace('uninterpreted single(b : u8) -> list::<u8>', 'uninterpreted single(b : u8) -> list::<u8>\nuninterpreted read_chunk(cap : u64) -> i64'),
    'neg_redeclared_local.sc': BASE.replace('    let off = 0;\n    while off < r {\n      let w = write_block(b, off, r);\n      if w <= 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 2;\n      }\n      off = off + w;\n    }\n  }\n}\n\n// Same relay',
                                             '    let off = 0;\n    while off < r {\n      let off = 0;\n      let w = write_block(b, off, r);\n      if w <= 0 {\n        lost = append(lost, slice(b.bytes, off, r));\n        return 2;\n      }\n      off = off + w;\n    }\n  }\n}\n\n// Same relay'),
    'neg_short_circuit_effect.sc': BASE.replace('  assert off <= n;\n  assert n <= b.len;', '  assert off <= n && n <= b.len;'),
    'neg_cast.sc': BASE.replace('  b.len = k;', '  b.len = k as u64;'),
    'neg_for_loop.sc': BASE.replace('fn mark() -> i64 {\n', 'fn mark() -> i64 {\n  for x in delivered { yield x; }\n'),
}


def main():
    fx = HERE / 'fixtures'
    for name, (old, new, note) in MUTANTS.items():
        if BASE.count(old) != 1:
            raise SystemExit(f'{name}: pattern occurs {BASE.count(old)} times')
        text = BASE.replace(old, new)
        header = f'// MUTANT {name}: {note}\n// Generated by make_fixtures.py from byte_relay_exec.sc; one change only.\n'
        (fx / f'{name}.sc').write_text(header + text)
    for name, text in NEGATIVES.items():
        if text == BASE:
            raise SystemExit(f'{name}: replacement did not apply')
        (fx / name).write_text(f'// NEGATIVE lowering fixture {name}: must be rejected by Lower with a reason.\n' + text)
    cases = [c for c in build_cases('standard') if not c.expect_reject]
    lines = ['# phase3 ptrcheck standard corpus minus CLI-reject cases; corpus_hash(all)=' + corpus_hash(build_cases('standard'))]
    for c in cases:
        lines.append('\t'.join([c.name, c.data.hex(), ','.join(map(str, c.reads)), ','.join(map(str, c.writes))]))
    (HERE / 'results' / 'cases_phase3_standard.tsv').write_text('\n'.join(lines) + '\n')

    every = bytes(range(256))
    curated = [
        ('input_a_late_read_error', b'abc', [3, -1], []),
        ('input_b_zero_write_pending', b'abcdef', [4], [2, 0]),
        ('nul255', bytes([0, 255, 10, 33]), [3], []),
        ('nul255_default', bytes([0, 255, 10, 33]), [], []),
        ('all256_default', every, [], []),
        ('all256_reverse_w1x5', every[::-1], [], [1] * 5),
        ('all256_werr_third_chunk', every, [], [32, 32, 5, -1]),
        ('all256_wzero_third_chunk', every, [], [32, 32, 5, 0]),
        ('all256_rerr_after_2', every, [32, 32, -1], []),
        ('nonfull_read_r31_n40', bytes(range(40)), [31], []),
        ('nonfull_read_r1_2_3_n10', bytes(range(10)), [1, 2, 3], []),
        ('offset_short_writes_w16_15_n32', bytes(range(200, 232)), [], [16, 15]),
        ('offset_short_writes_w1x8_n33', bytes(range(33)), [], [1] * 8),
        ('offset_w5_werr_n40', bytes(range(40)), [], [5, -1]),
        ('offset_w5_wzero_n40', bytes(range(40)), [], [5, 0]),
        ('wzero_first_n40', bytes(range(40)), [], [0]),
        ('rerr_first', bytes(range(40)), [-1], []),
        ('rerr_first_empty', b'', [-1], []),
        ('empty_default', b'', [], []),
        ('over_request_r33_w33_n33', bytes(range(33)), [33], [33]),
    ]
    lines = ['# curated handoff observations (calculus-bytes)']
    for n, d, r, w in curated:
        lines.append('\t'.join([n, d.hex(), ','.join(map(str, r)), ','.join(map(str, w))]))
    (HERE / 'results' / 'cases_curated.tsv').write_text('\n'.join(lines) + '\n')
    print(f'mutants={len(MUTANTS)} negatives={len(NEGATIVES)} phase3_cases={len(cases)} curated={len(curated)}')


if __name__ == '__main__':
    main()
