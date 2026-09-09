#!/usr/bin/env python3
"""Freeze a deterministic independent-reference corpus outside source sync."""
import argparse
from collections import Counter
import hashlib
import itertools
import json
from pathlib import Path
import random
import sys
import time
from unicode_oracle import ROWS, decode_first


def vectors():
    for n in (1, 2):
        for values in itertools.product(range(256), repeat=n):
            yield 'exhaustive_length_' + str(n), bytes(values), None
    # Python supplies an independent standard encoder and the expected scalar.
    # Agreement here checks all valid scalar encodings, not malformed-input policy.
    for scalar in range(0x110000):
        if not 0xD800 <= scalar <= 0xDFFF:
            data = chr(scalar).encode('utf-8')
            yield 'all_unicode_scalars', data, (len(data), scalar)
    for row in ROWS:
        choices = [sorted({max(0, lo-1), lo, min(lo+1, hi), hi, min(255, hi+1)})
                   for lo, hi in row]
        for values in itertools.product(*choices):
            data = bytes(values)
            for n in range(1, len(data)+1):
                yield 'row_boundaries_and_truncations', data[:n], None
            yield 'legal_or_illegal_prefix_with_suffix', data + b'\xff\x00', None
    rng = random.Random(5192026)
    for _ in range(4096):
        yield 'seeded_arbitrary_bytes', rng.randbytes(rng.randrange(1, 9)), None
    for data in (b'\x00', b'\xe2\x82', b'\xe0\x9f', b'\xed\xa0',
                 b'\xf4\x90', b'\xc2\xa2\xff', b'A'*32):
        yield 'explicit_regressions', data, None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path,
                        default=Path.home()/'.cache/bash-spec-pilot/phase5-utf8-vectors')
    args = parser.parse_args()
    out = args.out.expanduser().resolve()
    if (out/'manifest.json').exists():
        parser.error('use a fresh output directory to preserve the frozen corpus')
    out.mkdir(parents=True, exist_ok=True)
    counts = Counter(); started = time.monotonic()
    with (out/'input.hex').open('w') as source, (out/'expected.txt').open('w') as expected:
        for group, data, independent in vectors():
            result = decode_first(data)
            if independent is not None and result != independent:
                raise AssertionError((group, data.hex(), result, independent))
            source.write(data.hex()+'\n')
            expected.write(f'{result[0]} {result[1]}\n')
            counts[group] += 1
    sources = [Path(__file__), Path(__file__).with_name('unicode_oracle.py')]
    manifest = {
        'counts': dict(counts), 'total': sum(counts.values()),
        'duplicates': 'groups intentionally overlap; counts are cases, not unique byte strings',
        'python_version': sys.version, 'random_seed': 5192026,
        'source_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in sources},
        'files': {name: hashlib.sha256((out/name).read_bytes()).hexdigest()
                  for name in ['input.hex', 'expected.txt']},
        'generation_seconds': time.monotonic()-started,
        'scope': 'Independent-reference test corpus; no C result or formal theorem claimed by generation.',
    }
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(manifest, indent=2))


if __name__ == '__main__':
    main()
