#!/usr/bin/env python3
"""Deterministic translation of CompCert's Clight `f_relay` record (as printed in relay.v by
clightgen 3.15) into a Lean 4 term of type `ClightSubset.Func`.

Fail-closed: any constructor, type, operator, identifier or shape outside the small supported
subset aborts with a non-zero exit and NO output file. Constructor-for-constructor: the emitted
Lean constructors are named after the Clight ones (`Ssequence` -> `.ssequence`, ...). `Swhile`
is emitted as the Lean definition `swhile` which is CompCert's own definition of `Swhile`.

Usage: clight_to_lean.py RELAY_V OUT.lean
Output is a pure function of the input bytes (no randomness, no dict-order dependence).
"""
import hashlib, re, sys
from pathlib import Path

class Unsupported(Exception):
    pass

TOK = re.compile(r"\(|\)|::|,|[A-Za-z_][A-Za-z0-9_'.%]*|-?[0-9]+|\S")

def tokenize(text):
    for m in TOK.finditer(text):
        yield m.group(0)

def parse(tokens):
    """S-expression with Coq list sugar `a :: b :: nil` and pairs `(a, b)`."""
    def read(i):
        t = tokens[i]
        if t == '(':
            items, i = [], i + 1
            while tokens[i] != ')':
                if tokens[i] in ('::', ','):
                    items.append(tokens[i]); i += 1; continue
                item, i = read(i)
                items.append(item)
            i += 1
            # infix `::` list
            if '::' in items:
                parts, cur = [], []
                for x in items:
                    if x == '::':
                        parts.append(cur); cur = []
                    else:
                        cur.append(x)
                parts.append(cur)
                elems = []
                for p in parts[:-1]:
                    if len(p) != 1: raise Unsupported(f'bad list element {p}')
                    elems.append(p[0])
                tail = parts[-1]
                if tail != ['nil']: raise Unsupported(f'list must end in nil: {tail}')
                return ('LIST', elems), i
            if ',' in items:
                if items.count(',') != 1: raise Unsupported('bad pair')
                k = items.index(',')
                a, b = items[:k], items[k + 1:]
                if len(a) != 1 or len(b) != 1: raise Unsupported('bad pair arity')
                return ('PAIR', a[0], b[0]), i
            return tuple(items), i
        if t in (')', '::', ','): raise Unsupported(f'unexpected {t}')
        return t, i + 1
    node, i = read(0)
    if i != len(tokens): raise Unsupported('trailing tokens')
    return node

IDENTS = {'_buf': 'buf', '_n': 'n', '_w': 'w', '_off': 'off', "_t'1": "t'1", "_t'2": "t'2",
          '_read': 'read', '_write': 'write'}

def ident(x):
    if x not in IDENTS: raise Unsupported(f'ident {x}')
    return f'"{IDENTS[x]}"'

def ty(node):
    if node in ('tint', 'tlong', 'tulong', 'tuchar', 'tvoid'): return '.' + node
    if isinstance(node, tuple) and node and node[0] == 'tptr' and len(node) == 2:
        return f'(.tptr {ty(node[1])})'
    if isinstance(node, tuple) and node and node[0] == 'tarray' and len(node) == 3:
        return f'(.tarray {ty(node[1])} {int(node[2])})'
    if isinstance(node, tuple) and node and node[0] == 'Tfunction' and len(node) == 4:
        args = node[1]
        if not (isinstance(args, tuple) and args and args[0] == 'LIST'): raise Unsupported('Tfunction args')
        if node[3] != 'cc_default': raise Unsupported('calling convention')
        return f'(.tfunction [{", ".join(ty(a) for a in args[1])}] {ty(node[2])})'
    raise Unsupported(f'type {node}')

BINOPS = {'Oadd': '.oadd', 'Osub': '.osub', 'Olt': '.olt', 'Ole': '.ole', 'Oeq': '.oeq'}

def expr(node):
    if not isinstance(node, tuple) or not node: raise Unsupported(f'expr {node}')
    h = node[0]
    if h == 'Econst_int' and len(node) == 3:
        r = node[1]
        if not (isinstance(r, tuple) and len(r) == 2 and r[0] == 'Int.repr'): raise Unsupported('Econst_int')
        return f'(.econst_int {int(r[1])} {ty(node[2])})'
    if h == 'Evar' and len(node) == 3: return f'(.evar {ident(node[1])} {ty(node[2])})'
    if h == 'Etempvar' and len(node) == 3: return f'(.etempvar {ident(node[1])} {ty(node[2])})'
    if h == 'Ebinop' and len(node) == 5:
        if node[1] not in BINOPS: raise Unsupported(f'binop {node[1]}')
        return f'(.ebinop {BINOPS[node[1]]} {expr(node[2])} {expr(node[3])} {ty(node[4])})'
    if h == 'Ecast' and len(node) == 3: return f'(.ecast {expr(node[1])} {ty(node[2])})'
    raise Unsupported(f'expr head {h}')

def stmt(node, ind):
    pad = '  ' * ind
    if node == 'Sskip': return pad + '.sskip'
    if node == 'Sbreak': return pad + '.sbreak'
    if not isinstance(node, tuple) or not node: raise Unsupported(f'stmt {node}')
    h = node[0]
    if h == 'Ssequence' and len(node) == 3:
        return f'{pad}(.ssequence\n{stmt(node[1], ind + 1)}\n{stmt(node[2], ind + 1)})'
    if h == 'Sloop' and len(node) == 3:
        return f'{pad}(.sloop\n{stmt(node[1], ind + 1)}\n{stmt(node[2], ind + 1)})'
    if h == 'Swhile' and len(node) == 3:
        return f'{pad}(swhile {expr(node[1])}\n{stmt(node[2], ind + 1)})'
    if h == 'Sset' and len(node) == 3:
        return f'{pad}(.sset {ident(node[1])} {expr(node[2])})'
    if h == 'Sifthenelse' and len(node) == 4:
        return f'{pad}(.sifthenelse {expr(node[1])}\n{stmt(node[2], ind + 1)}\n{stmt(node[3], ind + 1)})'
    if h == 'Sreturn' and len(node) == 2:
        if node[1] == 'None': return pad + '(.sreturn none)'
        if isinstance(node[1], tuple) and len(node[1]) == 2 and node[1][0] == 'Some':
            return f'{pad}(.sreturn (some {expr(node[1][1])}))'
        raise Unsupported('Sreturn')
    if h == 'Scall' and len(node) == 4:
        dst = node[1]
        if dst == 'None': d = 'none'
        elif isinstance(dst, tuple) and len(dst) == 2 and dst[0] == 'Some': d = f'(some {ident(dst[1])})'
        else: raise Unsupported('Scall dst')
        args = node[3]
        if not (isinstance(args, tuple) and args and args[0] == 'LIST'): raise Unsupported('Scall args')
        return f'{pad}(.scall {d} {expr(node[2])} [{", ".join(expr(a) for a in args[1])}])'
    raise Unsupported(f'stmt head {h}')

def decls(node):
    if not (isinstance(node, tuple) and node and node[0] == 'LIST'): raise Unsupported('decl list')
    out = []
    for p in node[1]:
        if not (isinstance(p, tuple) and p[0] == 'PAIR'): raise Unsupported('decl pair')
        out.append(f'({ident(p[1])}, {ty(p[2])})')
    return '[' + ', '.join(out) + ']'

def main():
    src, out = Path(sys.argv[1]), Path(sys.argv[2])
    text = src.read_text()
    m = re.search(r'Definition f_relay := \{\|(.*?)\|\}\.', text, re.S)
    if not m: raise Unsupported('f_relay record not found')
    rec = m.group(1)
    parts = re.split(r'\b(fn_\w+) :=', rec)
    fields = {}
    for i in range(1, len(parts) - 1, 2):
        fields[parts[i]] = parts[i + 1].strip().rstrip(';').strip()
    for k in ('fn_return', 'fn_callconv', 'fn_params', 'fn_vars', 'fn_temps', 'fn_body'):
        if k not in fields: raise Unsupported(f'missing {k}')
    if fields['fn_callconv'].strip() != 'cc_default': raise Unsupported('callconv')
    if fields['fn_params'].strip() != 'nil': raise Unsupported('params')
    ret = ty(parse(list(tokenize(fields['fn_return']))))
    vars_ = decls(parse(list(tokenize(fields['fn_vars']))))
    temps = decls(parse(list(tokenize(fields['fn_temps']))))
    body = stmt(parse(list(tokenize(fields['fn_body']))), 2)
    sha_in = hashlib.sha256(src.read_bytes()).hexdigest()
    sha_gen = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    lean = f'''import ClightSubset

/-!
# RelayClightDump: GENERATED, do not edit.
Source: CompCert 3.15 `clightgen -normalize` output `relay.v` for phase2/relay.c
  relay.v sha256 {sha_in}
Generator: clight_to_lean.py sha256 {sha_gen}
Constructor-for-constructor translation of `Definition f_relay`; `swhile` is CompCert's
definition of `Swhile`. Identifiers are the Clight idents' string names (`_t'1`/`_t'2` are
CompCert temporaries 128/129). -/

namespace RelayClightDump
open ClightSubset

def fRelay : Func :=
  {{ ret := {ret}
    vars := {vars_}
    temps := {temps}
    body :=
{body} }}

end RelayClightDump
'''
    out.write_text(lean)
    print(f'wrote {out} relay.v={sha_in[:16]} generator={sha_gen[:16]} out={hashlib.sha256(lean.encode()).hexdigest()[:16]}')

if __name__ == '__main__':
    try:
        main()
    except Unsupported as e:
        print(f'UNSUPPORTED: {e}', file=sys.stderr)
        sys.exit(2)
