#!/usr/bin/env python3
"""Byte-extract head_bytes (head.c) and wc_lines (wc.c) fragments.

Mirrors utility-reuse/extract_fragment.py: verbatim byte slice, checked against
the pinned source hash, the recorded line range, and the exact fragment hash
already recorded by the Pi source-selection review (CASE-BRIEF.md) so this
script cannot silently drift from the frozen selection. No rewriting.
"""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
TARGETS = [
    {
        # CASE-BRIEF.md (Pi source-selection review) records lines 774-796
        # inclusive for head_bytes and hashes that range to ebdb38f1...  Direct
        # inspection of the pinned head.c (see STATUS.md) shows line 796 is
        # `return true;` and the function's closing brace is line 797: the
        # 774-796 range is missing brace and is not valid/compilable C (it
        # does not parse - clightgen rejects it, receipt case4-clightgen-1,
        # exit 2). This is an off-by-one in the frozen brief, not a rescoping:
        # the corrected range below is the complete, unedited function body
        # the brief itself describes in prose. frag_sha256 is therefore for
        # 774-797, distinct from (one line longer than) the brief's own hash.
        'name': 'head_bytes',
        'src': HERE / 'src/pinned/coreutils/head.c',
        'src_sha256': '484c3074adb5109c89c8de75384e2593e5eccf2988b998819d45cf1cf2af1310',
        'lines': (774, 797),
        'frag_sha256': 'ae9f42de06cf55ca1bfcc8720986b32f8c8d14b8063af8374dece0b886bbc4b7',
        'must_contain': 'head_bytes (char const *filename, int fd, uintmax_t bytes_to_write)',
    },
    {
        'name': 'xwrite_stdout',
        'src': HERE / 'src/pinned/coreutils/head.c',
        'src_sha256': '484c3074adb5109c89c8de75384e2593e5eccf2988b998819d45cf1cf2af1310',
        'lines': (176, 189),
        'frag_sha256': 'bb26b78f6b0df6e41c22497b27709f30225627f42326fa80fd85625ae8a5262c',
        'must_contain': 'xwrite_stdout (char const *buffer, size_t n_bytes)',
    },
    {
        'name': 'wc_lines',
        'src': HERE / 'src/pinned/coreutils/wc.c',
        'src_sha256': 'b659507f9873b5e92eacb112c32ee9eb172756d90e16e3a970b6275473a41816',
        'lines': (266, 330),
        'frag_sha256': '7d22d9fdfd6f97e3f149088c597840afc90f7912eba038fdf5941b94978c26fd',
        'must_contain': 'wc_lines (char const *file, int fd, uintmax_t *lines_out, uintmax_t *bytes_out)',
    },
]


def extract(t):
    data = t['src'].read_bytes()
    got = hashlib.sha256(data).hexdigest()
    assert got == t['src_sha256'], (t['name'], 'source hash mismatch', got)
    first, last = t['lines']
    lines = data.split(b'\n')
    start = sum(len(l) + 1 for l in lines[:first - 1])
    end = sum(len(l) + 1 for l in lines[:last])
    frag = data[start:end]
    assert t['must_contain'].encode() in frag, (t['name'], 'signature not in fragment')
    frag_hash = hashlib.sha256(frag).hexdigest()
    assert frag_hash == t['frag_sha256'], (t['name'], 'fragment hash mismatch vs frozen CASE-BRIEF', frag_hash)
    out = HERE / 'src/tu' / f"{t['name']}.frag.c"
    out.write_bytes(frag)
    again = out.read_bytes()
    assert again == frag
    return {
        'name': t['name'], 'source': str(t['src'].relative_to(HERE)),
        'source_sha256': got, 'lines_inclusive': list(t['lines']),
        'byte_range_half_open': [start, end], 'fragment_bytes': len(frag),
        'fragment_sha256': frag_hash,
    }


def main():
    meta = [extract(t) for t in TARGETS]
    (HERE / 'src/tu/FRAGMENTS.json').write_text(json.dumps(meta, indent=2) + '\n')
    print(json.dumps(meta, indent=2))


if __name__ == '__main__':
    main()
