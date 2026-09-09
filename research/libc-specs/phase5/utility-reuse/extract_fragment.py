#!/usr/bin/env python3
"""Byte-extract the simple_cat fragment from the pinned coreutils cat.c.

Writes src/tu/simple_cat.frag.c, then checks (1) the bytes equal the recorded
byte range of cat.c, (2) a C-token sequence of the fragment equals the token
sequence of that region, (3) the region starts at the function's doc comment
and ends at its closing brace. Records everything in src/tu/FRAGMENT.json.
No rewriting: the output is a verbatim slice.
"""
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
CAT = HERE / 'src/pinned/coreutils/cat.c'
OUT = HERE / 'src/tu/simple_cat.frag.c'
META = HERE / 'src/tu/FRAGMENT.json'
FIRST_LINE, LAST_LINE = 152, 182  # 1-based, inclusive: doc comment .. closing brace

TOKEN = re.compile(
    r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|'
    r'[A-Za-z_][A-Za-z_0-9]*|0[xX][0-9a-fA-F]+[uUlL]*|\d+[uUlL]*|'
    r'->|\+\+|--|<<=|>>=|<<|>>|<=|>=|==|!=|&&|\|\||[-+*/%&|^!~<>=?:;,.(){}\[\]#]',
    re.S)


def tokens(text):
    return [t for t in TOKEN.findall(text) if not t.startswith(('/*', '//'))]


def main():
    data = CAT.read_bytes()
    assert hashlib.sha256(data).hexdigest() == \
        'f52880ce866aa8f95d5830851054755d9d58e0e750905632e2db0a0378726983'
    lines = data.split(b'\n')
    start = sum(len(l) + 1 for l in lines[:FIRST_LINE - 1])
    end = sum(len(l) + 1 for l in lines[:LAST_LINE])
    frag = data[start:end]
    assert frag.startswith(b'/* Plain cat.'), frag[:40]
    assert frag.rstrip(b'\n').endswith(b'}'), frag[-20:]
    assert b'simple_cat (char *buf, idx_t bufsize)' in frag
    OUT.write_bytes(frag)
    again = OUT.read_bytes()
    assert again == data[start:end]
    toks_frag = tokens(again.decode())
    toks_src = tokens(data[start:end].decode())
    assert toks_frag == toks_src and toks_frag[0] == 'static' and toks_frag[-1] == '}'
    meta = {
        'source': 'src/pinned/coreutils/cat.c',
        'source_sha256': hashlib.sha256(data).hexdigest(),
        'coreutils_commit': '9530a14420fc1a267e90d45e8a0d710c3668382d',
        'lines_inclusive': [FIRST_LINE, LAST_LINE],
        'byte_range_half_open': [start, end],
        'fragment_bytes': len(frag),
        'fragment_sha256': hashlib.sha256(frag).hexdigest(),
        'token_count': len(toks_frag),
        'tokens_equal_to_source_region': toks_frag == toks_src,
        'first_tokens': toks_frag[:6],
        'last_tokens': toks_frag[-6:],
    }
    META.write_text(json.dumps(meta, indent=2) + '\n')
    print(json.dumps(meta, indent=2))


if __name__ == '__main__':
    main()
