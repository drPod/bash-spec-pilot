# Lowering specification: parsed spec language -> pinned Calculus.Ast (bounded fragment)

**This file describes two lowerings.** Everything below down to "## v1 vs v2" is the
**v1** lowering (2026-09-07 morning, `adapter/v1/lower.ml`, still used by the byte-relay
fixtures). The current adapter (`adapter/lower.ml`, driving `fixtures/v2/*`) is **v2**, a
same-day rewrite that replaced v1's untyped/non-short-circuit/single-level-nesting semantics;
see "## v1 vs v2" below for exactly what changed and why the v1 text under this line is no
longer true of the code that actually runs. Do not read the tables immediately below as a
description of the current `adapter/lower.ml`.

Worker: Claude (calculus-bytes), 2026-09-07. Implementation: `adapter/lower.ml` (new code,
built against the pinned `counc009/state_based@190dd8491b258d8a0ee29f79629908540236b332`
libraries `frontend` and `calculus`). Upstream provides no lowering at this commit
(`Semant.analyze_expr = failwith "TODO"`); this mapping is the worker's, informed only by
the name categories `semant.ml` already distinguishes (attribute, element, uninterpreted,
function, exception, local) and by the constructors of `calculus/ast.ml`. It is not a claim
about Aaron's intended semantics. Anything outside the fragment is rejected with a source
position and reason (`cb_main.exe lower` prints `"outcome": "rejected"`); nothing is
approximated silently.

## Input and output

Input: `Frontend.Ast.Parsed.decl list` exactly as returned by the pinned
`Frontend.Parser.program Frontend.Lexer.token` (no hand-built ASTs anywhere).
Output: one `Calculus.Ast.Ast(B).stmt` per `fn`, installed as the body of action `fn-name`
for the pinned `Calculus.Interp.InterpConcrete(B)(Defs)`; `B`/`Defs` are
`adapter/bytes_builtin.ml`. The state reference `σ` of the pinned interpreter's
`init_env` is the root state; a fn's argument tuple arrives in `ι`.

## Declarations

| Source | Lowering | Notes |
|---|---|---|
| `attribute a : T` | name `a` becomes a root attribute (`Get`/`Add QualAttr` on `σ` or on a state value) | `local attribute` rejected |
| `element e(x : T, ...)` | `e(args)` -> `Element(σ, "e", args)`; `s.e(args)` -> `Element(s, "e", args)` | `local element` rejected |
| `exception E(T, ...)` | value `Pair(String "E", args)`; arity checked at `raise`/`catch` | |
| `uninterpreted f(...) -> T` | must appear in `Bytes_builtin.uninterp_table` with matching arity; becomes `Function(f_builtin, args)` | unknown names rejected (e.g. `read_chunk`, `concat`) |
| `type t = T` | accepted and ignored | integer widths are NOT modelled |
| `fn f(x : T, ...) -> R { body }` | action `f`; body = `Assign x_i (proj_i ι); ...; lowered body`; calls `f(args)` -> `Action(tmp, "f", args)` | generics rejected; a fn must `return` (else the pinned interpreter yields `Failure`) |
| `enum`, `struct` | rejected | |

Argument tuples: `()` for none, the value for one, right-nested `Pair` otherwise; projections
use builtin `Fst`/`Snd`.

## Expressions (return prefix statements + expression)

Reads of attributes and calls of fns are statements in the calculus, so every expression
lowers to `(prefix, expr)`; the prefix binds fresh temporaries `$tN` (unlexable in source)
in left-to-right evaluation order.

| Source | Expression | Prefix |
|---|---|---|
| local `x` | `Variable x` | |
| attribute `a` | `Variable $t` | `Get($t, (σ, a))` |
| `s.a` (s a state value, a an attribute) | `Variable $t` | `Get($t, (s, a))` |
| integer / bool / char / unit literal | `Literal (Int n)` etc. (char = its code) | typed suffixes give the same `Int` |
| `-e`, `!e` | `Function(Neg/LNot, e)` | |
| `e1 op e2` for `+ - * / % < <= > >= == !=` | `Function(op, Pair(e1, e2))` | prefixes of e1 then e2 |
| `e1 && e2`, `e1 || e2` | `Function(LAnd/LOr, Pair)` **non-short-circuit** | rejected if e2 has a prefix (effects) |
| `f(args)` uninterpreted | `Function(builtin, tuple)` | |
| `g(args)` fn | `Variable $t` | `Action($t, "g", tuple)` |
| `e(args)` / `s.e(args)` element | `Element(σ or s, "e", tuple)` (a state value) | |
| `exists e(args)` | `Variable $t` | `Contains((base, e, args), $t := true, $t := false)` |
| cast, tuple, struct, enum, string, float, `if-then-else` expr, for-each expr | rejected | |

Kinds: a value is a *state* if it is an element expression, a local bound to one, a
parameter declared `state`, or the result of a fn declared `-> state`. `.a` and `.e(...)`
require a state.

## Statements

| Source | Lowering |
|---|---|
| `let x = e;` (optional type ignored) | `prefix; Assign(x, e)`; redeclaring `x` in the same fn is rejected (flat calculus environment) |
| `x = e;` local | `prefix; Assign(x, e)` |
| `a = e;` attribute | `prefix; Add(QualAttr(σ, a, e))` |
| `s.a = e;` | `prefix_s; prefix_e; Add(QualAttr(s, a, e))` |
| `while c { body }` | `prefix_c; While(c, Seq(body, prefix_c))` (condition prefix re-run before every test) |
| `if c { t } else { e }` | `prefix_c; Cond(c, t, e)` |
| `return e;` | `prefix; Return e` |
| `raise E(args)` (no `;`, pinned grammar) / `raise E;` | `prefix; Raise(Pair(String "E", tuple))` |
| `try { b } catch E(v1..vn) { c } finally { f }` | `TryCatch(b, $ex, Cond(ExcTag "E" $ex, (v_i := proj_i (Snd $ex); c), Raise $ex))`, wrapped in `TryFinally(_, f)` when `finally` is present |
| `touch e(args)` / `clear e(args)` | `Add(QualPosE/QualNegE (base, e, args))` |
| `assert c;` | `prefix; Cond(c, Pass, Raise(Pair(String "AssertionFailure", ())))` |
| `match`, `for`, `yield`, `localize` | rejected |

## Builtin table (trusted boundary, `adapter/bytes_builtin.ml`)

Lists use the calculus list encoding `Left () | Right (hd, tl)`; byte lists carry
`Literal (Int b)` with `0 <= b <= 255`, checked by every list builtin that constructs a list
(`single`, `append`, `take`, `drop`, `slice`); a violation returns `None`, which the pinned
interpreter reports as `Failure`. Integers are unbounded OCaml ints (no wraparound).

| name (arity) | meaning |
|---|---|
| `length(xs)` | list length |
| `take(xs, n)`, `drop(xs, n)` | first n / all but first n, `0 <= n <= |xs|` |
| `slice(xs, off, n)` | `xs[off, n)`, `0 <= off <= n <= |xs|` |
| `append(xs, ys)`, `single(b)`, `empty()` | list construction |
| `head_or(xs, d)`, `tail(xs)` | schedule head with default / tail |
| `min`, `max` | integers |

## v1 vs v2

Everything above this section describes the **v1** lowering exactly as the original
calculus-bytes worker built it (2026-09-07 morning; preserved verbatim in `adapter/v1/`,
still driving the byte-relay fixtures and 2046-record comparison in `compare_bytes.py`).
It is untyped in the sense described below, and that description is still literally true
of `adapter/v1/lower.ml`. It is **not** true of the current `adapter/lower.ml`, which the
calculus-resume-2/3 workers replaced same-day with the fragment described in "v2" below.
Both lowerings exist side by side on disk (`adapter/lower.ml` = v2, `adapter/v1/lower.ml` =
v1); `cb_main.ml` links only the v2 module. Nothing here claims to know Aaron's intended
semantics for any of this — both are the worker's explicit choices, stated precisely so a
reader can tell them apart from an unimplemented upstream analyzer (`Semant.analyze_expr`
is still `failwith "TODO"` at the pinned commit).

### v1 (superseded, kept only for the byte-relay fixtures)

The lowering was untyped: `u64`/`i64`/`u8` annotations were accepted but only byte-list
contents were range-checked (0..255), and OCaml's native (63-bit, unboxed) `int` was treated
as if it could not overflow — false, and never exercised by the byte-relay fixtures, whose
arithmetic stays tiny. Block scoping was not modelled beyond rejecting redeclaration inside
one fn. `&&`/`||` evaluated both operands unconditionally (`Function(LAnd/LOr, Pair(e1, e2))`),
so `e1 && e2` was only accepted when `e2` had no prefix (i.e. no attribute reads / fn calls /
short-circuit effects of its own) — it could not skip a trap or an effect in `e2` because it
never tried to.

### v2 (current: `adapter/lower.ml`, `adapter/bytes_builtin.ml`)

Fixes, each with negative fixtures in `fixtures/v2/neg/` and positive fixtures in
`fixtures/v2/{finite_ints,short_circuit,nested_state,scope_ok}.sc` (checked by
`check_v2.py` against the pinned parser/lowering, and by `compare_bytes.py`/
`compare_lean_v2.py` against the pinned interpreter's actual run output):

- **Real short-circuit.** `e1 && e2` lowers to `p1; t := e1; if t then (p2; t := e2) else pass`
  and `e1 || e2` to `p1; t := e1; if t then pass else (p2; t := e2)`, so a trapping or
  effectful `e2` (an uninterpreted call, a fn call, an attribute read) is only evaluated when
  the left operand does not already decide the result. `neg_sc_rhs_int`/`neg_bool_and_int`
  reject ill-typed operands (`&&`/`||` require `bool` on both sides); `short_circuit.sc`'s
  `sc_skip_trap_and`/`sc_skip_trap_or`/`sc_eval_trap_and`/`sc_eval_trap_or` exercise a `1/0`
  right operand both skipped and evaluated, and `sc_action_skipped`/`sc_action_taken` do the
  same for an action call.
- **Explicit finite-integer semantics, not "unbounded OCaml ints".** Every `TInt (lo, hi)`
  carries a range; the adapter's carrier is `i64 = [-2^62, 2^62-1]` and `u64 = [0, 2^62-1]`
  (`min_int`/`max_int` of the OCaml native 63-bit `int`, see `bytes_builtin.ml`), not the
  mathematical integers and not C's `int64_t`/`uint64_t` (which would be 64-bit and wrap
  differently) — this is the adapter's own choice, stated so it is not mistaken for either.
  `+ - * neg` trap (interpreter `Failure`) outside the carrier; `/` truncates toward zero and
  traps on division by zero; a declared narrower width (e.g. `type u8 = 0..255` style
  annotations) inserts a `Range`/`RangeList` builtin assertion at every annotated
  source/sink, and a literal outside its declared range is rejected **statically** at lowering
  (`neg_literal_range`, `neg_attr_literal_range`, `neg_i64_literal_carrier`), not silently
  truncated or wrapped. `finite_ints.sc` exercises carrier overflow/underflow on
  `+ - * neg`, truncating division and its sign, division by zero, a narrower local/parameter/
  return width with both an in-range and a trapping value, and the literal-suffix carrier
  bound. This is the adapter's chosen semantics; it is not derived from or claimed to match
  any upstream OCaml/C/Bash integer semantics beyond being explicit about its own bound.
- **Static typing.** Every expression gets one of `TBool | TUnit | TInt (lo,hi) | TList ty |
  TState`; conditions, `&&`/`||` operands, equality operands, uninterpreted/fn call arguments
  and casts are all checked against this typing (`neg_cond_int`, `neg_arg_type`,
  `neg_eq_list`, `neg_arith_cond`, `neg_uninterp_shape`, `neg_cast`). Casts remain rejected
  (declared widths are enforced as range assertions, not conversions).
  `scope_ok.sc` shows that this is source-level (lexical) scoping, not the runtime calculus
  environment (which stays flat): a name may be redeclared once its enclosing block ends
  (`branch_lets`, `loop_let`), and a `catch` variable is scoped to its handler
  (`catch_scope`). `neg_shadow`/`neg_scope_after_block`/`neg_dup_alias` are the corresponding
  negative controls.

None of this is proved; agreement between the lowering+patched-pinned-interpreter and an
independent expectation is measured by execution and recorded in `compare_bytes.py` (byte-relay,
2046/2046), `check_v2.py` (60 curated v2 lowering outcomes / negative-fixture error messages),
`compare_lean_v2.py` (8 hand-transcribed programs against the Lean fragment in
`integration/lean/CalculusNested.lean`), and `coq/BytesOracle.v` (90 finite Coq-checked
observations on the byte-relay case).

## Nested-state patches (private, `adapter/*.patch`)

Two private patches to the pinned OCaml are needed for ANY program that writes or reads a
depth->=2 state path (`a(1).b(2). ...`), both with failing-before/passing-after evidence in
`results/nested_before_after.json` and `results/interp_prepatch/`:

- `state_concrete_nested.patch` (`state.ml`): `ConcreteState.set_attr`/`pos_elem`/`neg_elem`
  returned the nested sub-state as the *whole* state on a `Nested` path, discarding the parent
  and every sibling. The patch rebuilds the enclosing state, as `RandomizeState.locate` (a
  different code path in the same file) already did it correctly.
- `interp_element_path.patch` (`interp.ml`): with the state patch alone but NOT this one, a
  path of depth >= 2 still resolves in the WRONG order (`results/v2_prepath/`: every
  `nested_state.sc` fn of depth 2 still fails except the depth-1-safe `wrong_order_probe`
  probe, which continues but on the wrong element — see `nested_before_after.json`'s
  `results/v2_prepath` column). `Element(base, e, arg)` must APPEND the new hop after `base`'s
  existing path (outermost-first), matching how every state walker and `Value.string_of_value`
  in `state.ml` reads a path; the pinned producer prepended it instead. With both patches,
  `nested_state.sc`'s `deep_set`/`deep_clear`/`deep_touch_keeps`/`deep3` (2-3 levels deep,
  reading through `s`/`t` locals bound mid-path) and `wrong_order_probe` all continue with the
  expected values (`results/v2/nested_state__*.jsonl`, cross-checked against a hand-transcribed
  Lean re-execution in `compare_lean_v2.py`); `missing_parent` (writing through an element that
  was never `touch`ed) correctly fails, as no patch changes what counts as a missing parent.
