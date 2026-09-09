# Lowering specification: parsed spec language → pinned Calculus.Ast (bounded fragment)

Document two explicit lowerings from the pinned parser AST to `Calculus.Ast`. Upstream provides no lowering at commit `190dd8491b258d8a0ee29f79629908540236b332` (`Semant.analyze_expr = failwith "TODO"`). The mapping is informed by name categories in `semant.ml` and constructors of `calculus/ast.ml`. It is not a claim about intended upstream semantics. Unsupported syntax is rejected with a source position (`cb_main.exe lower` prints `"outcome": "rejected"`).

v1 still drives the original byte-relay fixtures. v2 is the current `adapter/lower.ml` linked by `cb_main.ml`. Do not read the v1 tables as a description of current `adapter/lower.ml`.

Neither lowering is proved. Agreement is measured by execution ([README.md](README.md)).

## Two lowerings

Everything through the builtin table is **v1** (`adapter/v1/lower.ml`, 2026-09-07). Current adapter (`adapter/lower.ml`, `fixtures/v2/*`) is **v2**.

Input: `Frontend.Ast.Parsed.decl list` from `Frontend.Parser.program Frontend.Lexer.token`. Output: one `Calculus.Ast.Ast(B).stmt` per `fn`, installed as action `fn-name` for `Calculus.Interp.InterpConcrete(B)(Defs)` with `B`/`Defs` = `adapter/bytes_builtin.ml`. State reference `σ` is the root; argument tuple arrives in `ι`.

## Declarations (v1)

| Source | Lowering | Notes |
|---|---|---|
| `attribute a : T` | name `a` becomes a root attribute (`Get`/`Add QualAttr` on `σ` or on a state value) | `local attribute` rejected |
| `element e(x : T, ...)` | `e(args)` → `Element(σ, "e", args)`; `s.e(args)` → `Element(s, "e", args)` | `local element` rejected |
| `exception E(T, ...)` | value `Pair(String "E", args)`; arity checked at `raise`/`catch` | |
| `uninterpreted f(...) -> T` | must appear in `Bytes_builtin.uninterp_table` with matching arity; becomes `Function(f_builtin, args)` | unknown names rejected |
| `type t = T` | accepted and ignored | integer widths are NOT modelled |
| `fn f(x : T, ...) -> R { body }` | action `f`; body = `Assign x_i (proj_i ι); ...; lowered body`; calls `f(args)` → `Action(tmp, "f", args)` | generics rejected; a fn must `return` |
| `enum`, `struct` | rejected | |

Argument tuples: `()` for none, the value for one, right-nested `Pair` otherwise; projections use builtin `Fst`/`Snd`.

## Expressions (v1)

Reads of attributes and calls of fns are statements, so every expression lowers to `(prefix, expr)`; prefix binds fresh temporaries `$tN` left-to-right.

| Source | Expression | Prefix |
|---|---|---|
| local `x` | `Variable x` | |
| attribute `a` | `Variable $t` | `Get($t, (σ, a))` |
| `s.a` | `Variable $t` | `Get($t, (s, a))` |
| integer / bool / char / unit literal | `Literal (Int n)` etc. (char = its code) | typed suffixes give the same `Int` |
| `-e`, `!e` | `Function(Neg/LNot, e)` | |
| `e1 op e2` for `+ - * / % < <= > >= == !=` | `Function(op, Pair(e1, e2))` | prefixes of e1 then e2 |
| `e1 && e2`, `e1 || e2` | `Function(LAnd/LOr, Pair)` **non-short-circuit** | rejected if e2 has a prefix |
| `f(args)` uninterpreted | `Function(builtin, tuple)` | |
| `g(args)` fn | `Variable $t` | `Action($t, "g", tuple)` |
| `e(args)` / `s.e(args)` element | `Element(σ or s, "e", tuple)` | |
| `exists e(args)` | `Variable $t` | `Contains((base, e, args), $t := true, $t := false)` |
| cast, tuple, struct, enum, string, float, `if-then-else` expr, for-each expr | rejected | |

A value is a *state* if it is an element expression, a local bound to one, a parameter declared `state`, or the result of a fn declared `→ state`. `.a` and `.e(...)` require a state.

## Statements (v1)

| Source | Lowering |
|---|---|
| `let x = e;` (optional type ignored) | `prefix; Assign(x, e)`; redeclaring `x` in the same fn is rejected |
| `x = e;` local | `prefix; Assign(x, e)` |
| `a = e;` attribute | `prefix; Add(QualAttr(σ, a, e))` |
| `s.a = e;` | `prefix_s; prefix_e; Add(QualAttr(s, a, e))` |
| `while c { body }` | `prefix_c; While(c, Seq(body, prefix_c))` |
| `if c { t } else { e }` | `prefix_c; Cond(c, t, e)` |
| `return e;` | `prefix; Return e` |
| `raise E(args)` (no `;`) / `raise E;` | `prefix; Raise(Pair(String "E", tuple))` |
| `try { b } catch E(v1..vn) { c } finally { f }` | `TryCatch` with tag test, wrapped in `TryFinally` when `finally` is present |
| `touch e(args)` / `clear e(args)` | `Add(QualPosE/QualNegE (base, e, args))` |
| `assert c;` | `prefix; Cond(c, Pass, Raise(Pair(String "AssertionFailure", ())))` |
| `match`, `for`, `yield`, `localize` | rejected |

## Builtin table (trusted, `adapter/bytes_builtin.ml`)

Lists use `Left () | Right (hd, tl)`; byte lists carry `Literal (Int b)` with `0 <= b <= 255`; a violation returns `None` (`Failure`). v1 integers are unbounded OCaml ints (no wraparound).

| name (arity) | meaning |
|---|---|
| `length(xs)` | list length |
| `take(xs, n)`, `drop(xs, n)` | first n / all but first n, `0 <= n <= |xs|` |
| `slice(xs, off, n)` | `xs[off, n)`, `0 <= off <= n <= |xs|` |
| `append(xs, ys)`, `single(b)`, `empty()` | list construction |
| `head_or(xs, d)`, `tail(xs)` | schedule head with default / tail |
| `min`, `max` | integers |

## v1 vs v2

v1 is preserved in `adapter/v1/` and still drives the 2046-record byte-relay comparison. v2 is `adapter/lower.ml`.

### v1 (superseded except for those fixtures)

Untyped: `u64`/`i64`/`u8` annotations accepted but only byte-list contents range-checked (0..255); OCaml native 63-bit `int` treated as non-overflowing — false, never exercised by byte-relay fixtures. Block scoping only rejected redeclaration inside one fn. `&&`/`||` evaluated both operands (`Function(LAnd/LOr, Pair)`), so `e2` with a prefix was rejected rather than skipped.

### v2 (current)

Fixtures in `fixtures/v2/{finite_ints,short_circuit,nested_state,scope_ok}.sc` and `fixtures/v2/neg/`; checked by `check_v2.py`, `compare_bytes.py`, `compare_lean_v2.py`.

- **Short-circuit.** `e1 && e2` lowers to `p1; t := e1; if t then (p2; t := e2) else pass` (dual for `||`). `&&`/`||` require `bool` on both sides.
- **Finite integers.** Carrier `i64 = [-2^62, 2^62-1]`, `u64 = [0, 2^62-1]` (OCaml native 63-bit `int` bounds), not mathematical integers and not C `int64_t`/`uint64_t`. `+ - * neg` trap outside the carrier; `/` truncates toward zero and traps on division by zero; narrower declared widths insert `Range`/`RangeList` assertions; out-of-range literals rejected statically.
- **Static typing.** `TBool | TUnit | TInt (lo,hi) | TList ty | TState`. Casts remain rejected. Lexical block scoping: a name may be redeclared once its enclosing block ends; `catch` variables scoped to the handler.

Measured agreement: `compare_bytes.py` 2046/2046; `check_v2.py` 60/60; `compare_lean_v2.py` (hand-transcribed programs vs `CalculusNested.lean`); `coq/BytesOracle.v` 90 finite observations.

## Nested-state patches (private)

Needed for any program that writes or reads a depth ≥2 path. Evidence: `results/nested_before_after.json`, `results/interp_prepatch/`.

- `state_concrete_nested.patch` (`state.ml`): rebuild enclosing state on `Nested` paths, matching `RandomizeState.locate`.
- `interp_element_path.patch` (`interp.ml`): `Element(base, e, arg)` must **append** the hop (outermost-first). With the state patch alone, depth ≥2 still fails (`results/v2_prepath/`). With both patches, `nested_state.sc` functions continue with expected values; `missing_parent` still fails.
