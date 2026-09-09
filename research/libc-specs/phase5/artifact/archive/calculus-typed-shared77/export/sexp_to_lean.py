#!/usr/bin/env python3
"""Deterministic translation of `print_ast.exe` output (the pinned frontend's PARSED spec AST,
one S-expression per declaration) into a Lean 4 term of type `List CalculusLowering.Decl`.

Fail-closed: any `(unsupported ...)` node, unknown head, malformed shape, or unknown type/operator
atom aborts with a non-zero exit and NO output file. Only the constructs `CalculusLowering.Decl` /
`SStmt` / `SExpr` / `STyp` / `BinOp` have constructors for are emitted, so the emitted term is
well-formed Lean iff every node of the export is inside the supported fragment.

Usage: sexp_to_lean.py RAW.sexp OUT.lean [--hand-name byteRelayExecSpec]
The emitted module records sha256 of the raw export and of this generator in its header.

No randomness, no dict-ordering dependence: output is a pure function of the input bytes.
"""
import hashlib
import sys
from pathlib import Path


class Unsupported(Exception):
    pass


# ---------------------------------------------------------------- S-expression reader

def tokenize(text):
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c.isspace():
            i += 1
        elif c in '()':
            yield c
            i += 1
        elif c == '"':
            j = i + 1
            buf = []
            while True:
                if j >= n:
                    raise Unsupported('unterminated string literal')
                d = text[j]
                if d == '\\':
                    if j + 1 >= n:
                        raise Unsupported('dangling escape')
                    e = text[j + 1]
                    if e not in '"\\':
                        raise Unsupported('unknown escape \\%s' % e)
                    buf.append(e)
                    j += 2
                elif d == '"':
                    break
                else:
                    buf.append(d)
                    j += 1
            yield ('str', ''.join(buf))
            i = j + 1
        else:
            j = i
            while j < n and not text[j].isspace() and text[j] not in '()"':
                j += 1
            yield ('atom', text[i:j])
            i = j


def parse_all(text):
    toks = list(tokenize(text))
    pos = 0

    def node():
        nonlocal pos
        t = toks[pos]
        pos += 1
        if t == '(':
            items = []
            while toks[pos] != ')':
                items.append(node())
            pos += 1
            return items
        if t == ')':
            raise Unsupported('unexpected )')
        return t

    out = []
    while pos < len(toks):
        out.append(node())
    return out


# ---------------------------------------------------------------- shape helpers

def is_atom(x, v=None):
    return isinstance(x, tuple) and x[0] == 'atom' and (v is None or x[1] == v)


def is_str(x):
    return isinstance(x, tuple) and x[0] == 'str'


def head(x):
    if isinstance(x, list) and x and is_atom(x[0]):
        return x[0][1]
    return None


def need(cond, what):
    if not cond:
        raise Unsupported(what)


def lean_str(s):
    out = ['"']
    for ch in s:
        if ch == '"':
            out.append('\\"')
        elif ch == '\\':
            out.append('\\\\')
        else:
            need(32 <= ord(ch) < 127, 'non-printable/non-ASCII character in identifier %r' % s)
            out.append(ch)
    out.append('"')
    return ''.join(out)


def lean_int(s):
    need(s.lstrip('-').isdigit() and s.count('-') <= 1 and not s.startswith('--'),
         'malformed integer %r' % s)
    n = int(s)
    return '(%d)' % n if n < 0 else str(n)


def lean_list(items):
    return '[' + ', '.join(items) + ']'


# ---------------------------------------------------------------- translation

TYP_ATOMS = {
    'bool': '.bool', 'void': '.void',
    'i8': '.sint8', 'u8': '.uint8', 'i16': '.sint16', 'u16': '.uint16',
    'i32': '.sint32', 'u32': '.uint32', 'i64': '.sint64', 'u64': '.uint64',
    'state': '.stateRef',
}

BINOPS = {
    '+': '.add', '-': '.sub', '*': '.mul', '/': '.div', '%': '.mod',
    '<': '.lt', '<=': '.le', '>': '.gt', '>=': '.ge', '==': '.eq', '!=': '.ne',
    '&&': '.land', '||': '.lor',
}


def typ(x):
    if is_atom(x):
        need(x[1] in TYP_ATOMS, 'unknown type atom %r' % x[1])
        return TYP_ATOMS[x[1]]
    h = head(x)
    if h == 'list':
        need(len(x) == 2, 'list type arity')
        return '(.list %s)' % typ(x[1])
    if h == 'named':
        need(len(x) == 2 and is_str(x[1]), 'named type shape')
        return '(.named %s)' % lean_str(x[1][1])
    raise Unsupported('type node %r' % (x,))


def expr(x):
    if is_atom(x, 'unit'):
        return 'unitLit'
    h = head(x)
    need(h is not None, 'expression node %r' % (x,))
    if h == 'var':
        need(len(x) == 2 and is_str(x[1]), 'var shape')
        return '(var %s)' % lean_str(x[1][1])
    if h == 'bool':
        need(len(x) == 2 and is_atom(x[1]) and x[1][1] in ('true', 'false'), 'bool shape')
        return '(boolLit %s)' % x[1][1]
    if h == 'int':
        need(len(x) == 2 and is_atom(x[1]), 'int shape')
        return '(intLit %s)' % lean_int(x[1][1])
    if h == 'neg':
        need(len(x) == 2, 'neg arity')
        return '(neg %s)' % expr(x[1])
    if h == 'lnot':
        need(len(x) == 2, 'lnot arity')
        return '(lnot %s)' % expr(x[1])
    if h == 'binop':
        need(len(x) == 4 and is_atom(x[1]) and x[1][1] in BINOPS, 'binop shape %r' % (x[1],))
        return '(binop %s %s %s)' % (BINOPS[x[1][1]], expr(x[2]), expr(x[3]))
    if h == 'field':
        need(len(x) == 3 and is_str(x[2]), 'field shape')
        return '(field %s %s)' % (expr(x[1]), lean_str(x[2][1]))
    if h == 'call':
        need(len(x) == 3 and is_str(x[1]) and isinstance(x[2], list), 'call shape')
        return '(call %s %s)' % (lean_str(x[1][1]), lean_list([expr(a) for a in x[2]]))
    if h == 'field-call':
        need(len(x) == 4 and is_str(x[2]) and isinstance(x[3], list), 'field-call shape')
        return '(fieldCall %s %s %s)' % (expr(x[1]), lean_str(x[2][1]),
                                         lean_list([expr(a) for a in x[3]]))
    if h == 'exists':
        need(len(x) == 2, 'exists arity')
        return '(existsE %s)' % expr(x[1])
    raise Unsupported('expression head %r' % h)


def stmts(x):
    need(isinstance(x, list) and head(x) is None or x == [], 'statement list expected, got %r' % (x,))
    return lean_list([stmt(s) for s in x])


def stmt(x):
    h = head(x)
    need(h is not None, 'statement node %r' % (x,))
    if h == 'let':
        need(len(x) == 4 and is_str(x[1]), 'let shape')
        ty = 'none' if is_atom(x[2], '_') else '(some %s)' % typ(x[2])
        return '(letS %s %s %s)' % (lean_str(x[1][1]), ty, expr(x[3]))
    if h == 'assign':
        need(len(x) == 3, 'assign arity')
        return '(assign %s %s)' % (expr(x[1]), expr(x[2]))
    if h == 'while':
        need(len(x) == 3, 'while arity')
        return '(whileS %s %s)' % (expr(x[1]), stmts(x[2]))
    if h == 'if':
        need(len(x) == 4, 'if arity')
        return '(ifS %s %s %s)' % (expr(x[1]), stmts(x[2]), stmts(x[3]))
    if h == 'return':
        need(len(x) == 2, 'return arity')
        return '(ret %s)' % expr(x[1])
    if h == 'raise':
        need(len(x) == 3 and is_str(x[1]) and isinstance(x[2], list), 'raise shape')
        return '(raise %s %s)' % (lean_str(x[1][1]), lean_list([expr(a) for a in x[2]]))
    if h == 'try':
        need(len(x) == 4, 'try arity')
        c = x[2]
        if is_atom(c, 'none'):
            catch = 'none'
        else:
            need(head(c) == 'catch' and len(c) == 4 and is_str(c[1]) and isinstance(c[2], list),
                 'catch shape')
            for v in c[2]:
                need(is_str(v), 'catch variable must be a string')
            catch = '(some (%s, %s, %s))' % (lean_str(c[1][1]),
                                             lean_list([lean_str(v[1]) for v in c[2]]),
                                             stmts(c[3]))
        return '(tryCatch %s %s %s)' % (stmts(x[1]), catch, stmts(x[3]))
    if h == 'touch':
        need(len(x) == 2, 'touch arity')
        return '(touch %s)' % expr(x[1])
    if h == 'clear':
        need(len(x) == 2, 'clear arity')
        return '(clear %s)' % expr(x[1])
    if h == 'assert':
        need(len(x) == 2, 'assert arity')
        return '(assert %s)' % expr(x[1])
    raise Unsupported('statement head %r' % h)


def decl(x):
    h = head(x)
    need(h is not None, 'declaration node %r' % (x,))
    if h == 'attribute':
        need(len(x) == 3 and is_str(x[1]), 'attribute shape')
        return '.attribute %s %s' % (lean_str(x[1][1]), typ(x[2]))
    if h == 'element':
        need(len(x) == 3 and is_str(x[1]) and isinstance(x[2], list), 'element shape')
        return '.element %s %s' % (lean_str(x[1][1]), lean_list([typ(t) for t in x[2]]))
    if h == 'exception':
        need(len(x) == 3 and is_str(x[1]) and isinstance(x[2], list), 'exception shape')
        return '.exception %s %s' % (lean_str(x[1][1]), lean_list([typ(t) for t in x[2]]))
    if h == 'type':
        need(len(x) == 3 and is_str(x[1]), 'type shape')
        return '.typeAlias %s %s' % (lean_str(x[1][1]), typ(x[2]))
    if h == 'uninterp':
        need(len(x) == 4 and is_str(x[1]) and isinstance(x[2], list), 'uninterp shape')
        return '.uninterp %s %s %s' % (lean_str(x[1][1]), lean_list([typ(t) for t in x[2]]),
                                       typ(x[3]))
    if h == 'function':
        need(len(x) == 5 and is_str(x[1]) and isinstance(x[2], list), 'function shape')
        args = []
        for a in x[2]:
            need(isinstance(a, list) and len(a) == 2 and is_str(a[0]), 'function argument shape')
            args.append('(%s, %s)' % (lean_str(a[0][1]), typ(a[1])))
        return '.function %s %s %s\n      %s' % (lean_str(x[1][1]), lean_list(args), typ(x[3]),
                                                stmts(x[4]))
    raise Unsupported('declaration head %r' % h)


# ---------------------------------------------------------------- emission

HEADER = '''/-
  GENERATED by calculus-correspondence/spec_ast_export/sexp_to_lean.py — do not edit.
  Source: the pinned frontend's parsed AST of `fixtures/byte_relay_exec.sc`, printed by
  `print_ast.exe` (calculus-correspondence/spec_ast_export/print_ast.ml, built in a private
  staging tree of the shared phase5-vst container; receipts in calculus-correspondence-75).
    raw export  : {raw_name}  sha256 {raw_sha}
    generator   : sexp_to_lean.py  sha256 {gen_sha}
  Every node of the raw export was in the supported fragment (the generator aborts otherwise).
-/
import CalculusLowering
open CalculusNested CalculusBody CalculusRelayOuter

namespace CalculusLowering

section ExportedProgram
open SExpr SStmt

/-- The machine-produced spec AST of `fixtures/byte_relay_exec.sc` (declarations in file order),
    translated node-for-node from the raw S-expression export. -/
def exportedSpec : List Decl :=
  [ {decls} ]

end ExportedProgram

/-- The machine-produced AST is EXACTLY the hand encoding used by `lowering_checked`: both are
    closed constructor terms, so the kernel decides the equality by definitional unfolding
    (`rfl`). `SExpr`/`SStmt` are nested inductives (`List SExpr` fields) for which Lean 4.31's
    `DecidableEq` deriving handler does not apply, so `decide` is not used here. -/
theorem exportedSpec_eq_hand : exportedSpec = {hand} := by
  rfl

/-- Composition: the Lean lowering of the MACHINE-PRODUCED spec AST is the nine exported bodies.
    This is a checked relation among (i) the pinned parser's own AST export, (ii) the Lean
    re-implementation of `lower.ml`, and (iii) the exported calculus; it is not a proof about the
    OCaml text of `lower.ml` or `interp.ml`. -/
theorem exported_lowers :
    lowerProgram exportedSpec = some
      [("read_block", readBlockBody), ("write_block", writeBlockBody), ("relay", relayBody),
       ("relay_raising", relayRaisingBody), ("relay_caught", relayCaughtBody), ("mark", markBody),
       ("relay_seq_relay", relaySeqRelayBody), ("relay_and_mark", relayAndMarkBody),
       ("relay_or_mark", relayOrMarkBody)] := by
  rw [exportedSpec_eq_hand]; exact lowering_checked

end CalculusLowering
'''


def main(argv):
    if len(argv) < 3:
        print(__doc__, file=sys.stderr)
        return 2
    raw_path, out_path = Path(argv[1]), Path(argv[2])
    hand = 'byteRelayExecSpec'
    if len(argv) >= 5 and argv[3] == '--hand-name':
        hand = argv[4]
    raw = raw_path.read_bytes()
    try:
        text = raw.decode('ascii')
        nodes = parse_all(text)
        decls = [decl(d) for d in nodes]
    except (Unsupported, UnicodeDecodeError, IndexError) as e:
        print('FAIL-CLOSED: %s' % e, file=sys.stderr)
        return 1
    body = ',\n    '.join(decls)
    out = HEADER.format(raw_name=raw_path.name,
                        raw_sha=hashlib.sha256(raw).hexdigest(),
                        gen_sha=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                        decls=body, hand=hand)
    out_path.write_text(out)
    print('%d declarations -> %s' % (len(decls), out_path))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
