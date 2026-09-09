#!/usr/bin/env python3
"""Extract the original (already-checked, in-repository) proof body for each
evaluation-expanded task's target theorem, for use ONLY as the checker's positive control
and for recording expected_check.txt. Never shown to a model attempt."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
LIBC = HERE.parents[1]
SOURCE = LIBC / 'phase5/integration/lean/CalculusNested.lean'
LINES = SOURCE.read_text().splitlines(keepends=True)

TARGET_LINES = {
    'nested_frame': (250, 288),
    'nested_add_attrs': (295, 336),
    'nested_remove_frame': (339, 347),
}


def span(a, b):
    return ''.join(LINES[a - 1:b])


def main():
    out_dir = HERE / 'originals'
    out_dir.mkdir(exist_ok=True)
    for key, (a, b) in TARGET_LINES.items():
        text = span(a, b)
        idx = text.index(':=')
        proof = text[idx + 2:]
        if proof.startswith('\n'):
            proof = proof[1:]
        (out_dir / f'{key}.proof.lean').write_text(proof)
        print(key, '->', repr(proof[:40]))


if __name__ == '__main__':
    main()
