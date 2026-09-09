#!/usr/bin/env python3
"""Compare the pinned OCaml interpreter's fixture output with the Lean transcription.

Inputs: results/interp_ocaml.jsonl (from sc_fixtures.exe interp inside the container) and
results/interp_lean.jsonl (from the fragment-json Lean executable). Every Lean record must
have an OCaml record with the same name, command text, outcome, rc and stdout attribute.
Exit 0 only if all records agree and the expected case count is present. This is an
empirical agreement check between two executables, not a proof about either.
"""
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
EXPECTED_LEAN_CASES = 12  # 11 shell-fragment commands + the no-return control


def load(path):
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()]


def ocaml_view(rec):
    stdout = None
    for attr in rec.get('attrs', []):
        if 'stdout' in attr:
            stdout = attr['stdout']
    return (rec['name'], rec['command'], rec['outcome'], rec.get('rc'), stdout)


def lean_view(rec):
    return (rec['name'], rec['command'], rec['outcome'], rec.get('rc'), rec.get('stdout'))


def main():
    ocaml = {r['name']: ocaml_view(r) for r in load(HERE / 'results/interp_ocaml.jsonl')}
    lean = [lean_view(r) for r in load(HERE / 'results/interp_lean.jsonl')]
    problems = []
    if len(lean) != EXPECTED_LEAN_CASES:
        problems.append(f'expected {EXPECTED_LEAN_CASES} Lean records, found {len(lean)}')
    for view in lean:
        name = view[0]
        if name not in ocaml:
            problems.append(f'{name}: missing OCaml record')
        elif ocaml[name] != view:
            problems.append(f'{name}: OCaml {ocaml[name]} != Lean {view}')
    summary = {
        'lean_records': len(lean), 'ocaml_records': len(ocaml),
        'compared': len(lean), 'mismatches': len(problems),
        'ocaml_only_controls': sorted(set(ocaml) - {v[0] for v in lean}),
        'problems': problems,
    }
    print(json.dumps(summary, indent=2))
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main())
