# Calculus correspondence: general parser -> checked-interpreter pipeline over the compiler's own export

Date: 2026-09-08. Worker: Claude, ONE continuing session (`47046454-e02d-4c39-8f50-9ee26b64cee1`,
confirmed by `process.json` in each job directory — session -10's REPORT.md incorrectly called it
"a different underlying Claude session"; that line is wrong and is corrected here, not silently
fixed). Job chain -4 through -18, -61, -75 and -79; -4, -6 and -13 were quota-interrupted before writing their own reports (-13's accepted work is described in the "Sessions -13 and -14" section).
Scope: replace hand-transcribed finite examples with a mechanical
`parser -> lowerer -> export -> Lean-checked-parse -> Lean-checked-run` path over the REAL pinned
OCaml compiler's own S-expression printer output, byte-bearing state included, negative controls
over real (not synthetic) exported ASTs, a real, LARGE same-input OCaml-vs-Lean comparison, and
(session -11) a statement-level, not just expression-level, general theorem connecting the parser
and interpreter for the reference-bearing assignment pattern `write_block` actually uses, and
(sessions -13/-14) whole-body theorems for `write_block`/`read_block`, invariant/termination
theorems for both of `relay`'s loops and for `relay` from its entry point, all about ASTs the
kernel has identified with the exporter's own token stream.

**Read this before trusting any number below in isolation**: session -10 found a build-staleness
problem that had silently narrowed every earlier same-input claim (see "Session -10"). Session -11
found the COMPARATOR that measured those claims had its own bugs (an orchestrator audit, not
self-discovered) that could have hidden a real mismatch even against the corrected build (see
"Session -11"); every number in this file has been re-verified with the fixed comparator.

## Session -8: the parser proof gap

`integration/lean/CalculusExport.lean` (733 lines) and `ExportMain.lean` existed from a prior
session but had never successfully built: `lake build` failed with an unsolved-goal error in
`parseFunc_renderFunc`'s `range` case (`Func.range`'s round trip through
`"range:" ++ lo.repr ++ ":" ++ hi.repr`). Fixed with a hand-rolled, inductively-provable `List
Char` splitter (`splitFirstColon`) and four new general lemmas. `lake build` succeeded for the
first time (22/22 jobs); axiom-clean.

## Session -9: byte-list builtins and a value-representation gap

Transcribed `calculus-bytes/adapter/bytes_builtin.ml`'s eleven `uninterp_table` byte-list
primitives (`length, take, drop, slice, append, single, empty, head_or, tail, min, max`) into
`CalculusNested.funcDef` and the parser. Bisecting a `relay` failure (Python-driven paren-tree
prefix search over the real exported S-expression, not hand-retyped fragments) found a genuine,
previously-undiscovered gap: `evalExpr`'s `.pair` case silently failed whenever a component was
a state reference (`relay`'s `(pair b (pair off r))`, `b` an element ref). Fixed additively with
`RVal.rpair` — zero existing interpreter cases changed. Reported (at the time) a 20/20 same-input
match for `relay` against `calculus-bytes/results/cases_curated.tsv`.

## Session -10: the correspondence claims were real, but narrower than reported — and the reason

The orchestrator's -10 brief asked for the 4 pending relay-family OCaml comparisons,
`nested_state`/`finite_ints` same-input comparisons, a general (not just empirical) theorem for
`RVal.rpair`, byte-list negative controls, and a comparison sweep beyond 20 cases. Doing the
`nested_state`/`finite_ints` comparisons surfaced something session -9 had no way to see:

### The container's `cb_main.exe` was silently running an OLD, pre-v2 build

`compare-run`'s `nested_state.sc` functions that touch NESTED elements (`deep_set`,
`wrong_order_probe`, ...) all came back `outcome: failure` against the real OCaml interpreter,
even the empty/unit case that a saved 2026-09-07 record (`calculus-bytes/results/v2/
nested_state__deep_set.jsonl`) shows succeeding with the SAME lowered program (identical
`calculus_md5`). Root-caused by direct inspection of the container's checked-out source, not
guessed:

- `/home/coq/phase5/calculus-bytes/bash-verifier/lib/calculus/interp.ml`'s `Element` case still
  had the ORIGINAL, un-patched line
  (`Some (V.SRef (V.Nested (elem, e, b)))`, prepending the new hop) — the documented
  `interp_element_path.patch` (which appends instead, matching `CalculusNested.Path.snoc`'s and
  every `state.ml` walker's outermost-first convention) was NOT applied in the deployed build,
  even though `state.ml`'s companion `state_concrete_nested.patch` WAS. Multi-level nested-element
  writes/reads land at the wrong place under this bug, so any program touching `a(1).b(2)` fails.
- `/home/coq/phase5/calculus-bytes/bash-verifier/calculus_bytes/bytes_builtin.ml` was a
  PRE-v2 file entirely: `B.Add -> int2 (fun a b -> Some (int (a + b)))`, no overflow trap, no
  `Range`/`RangeList` constructors at all — confirmed by diffing it against the current
  `research/libc-specs/phase5/calculus-bytes/adapter/bytes_builtin.ml` (207 lines, `add_checked`/
  `sub_checked`/`mul_checked`/`neg_checked`, `B.Range`/`B.RangeList`) which is NOT what was
  deployed. `finite_ints.sc`'s four `overflow_*` fixtures (which exist specifically to test
  trapping) came back `continue` with a silently WRAPPED result (`-4611686018427387904 = -(2^62)`,
  i.e. `max_int + 1` wrapped to `min_int`) instead of `Failure`.

Neither gap affected session -9's `relay` claim in a way that would have shown up: relay only
creates ONE level of element nesting (`block(0)`, never nested further) and never overflows the
63-bit carrier in the tested cases, so that 20/20 match was not fabricated — it just didn't
exercise either broken code path, and the file's OWN header (v1's "unbounded ints... that was
false") already told a careful reader that "v1" and "v2" adapter behavior diverge, which should
have been checked earlier and was not.

**No shared container original was modified.** A PRIVATE copy was made
(`docker exec ... cp -r /home/coq/phase5/calculus-bytes /home/coq/phase5/calculus-correspondence10`),
the three current adapter files (`bytes_builtin.ml`, `lower.ml`, `cb_main.ml`) were copied in from
this repo's `calculus-bytes/adapter/`, `interp_element_path.patch` was applied (`patch -p1`,
verified with `--dry-run` first), and `dune build --profile release` was run there — all under the
shared compiler lock, `run_vst.py --workdir /home/coq/phase5/calculus-correspondence10`. The
original `/home/coq/phase5/calculus-bytes` is byte-for-byte what it was before this session
(spot-checked: `grep -c add_checked` on the original's `bytes_builtin.ml` is still `0`).

### Corrected results, all against the private, correctly-versioned build

Re-lowering all four fixture files through the correct build changed EVERY exported S-expression
(new `range:`/`range-list:` assertions the v2 lowering inserts at typed sinks) —
`results/export_input__*.tsv` were regenerated from scratch, not patched. This required one more
addition: `range-list:lo:hi` (`Func.rangeList`, the list counterpart of the already-supported
`range:lo:hi`) appears around every real byte-list sink (e.g. `write_block`'s `req`) and was not
yet parseable; added the same way `range` already was (`splitFirstColon`-based, general round-trip
proof extended). Axiom-clean throughout.

With the corrected build and corrected exports:

| Corpus | Cases | Result |
|---|---|---|
| `relay`, `cases_curated.tsv` | 20 | **20/20 exact match** |
| `relay_and_mark`/`relay_or_mark`/`relay_seq_relay`/`relay_caught`, `cases_curated.tsv` (4 pending from -9) | 4 x 20 | **80/80 exact match** |
| `nested_state.sc`'s 7 functions, empty case | 7 | **7/7 exact match** (was 0/7 against the stale build) |
| `finite_ints.sc`'s 20 functions, empty case | 20 | **20/20 exact match** (was 16/20 against the stale build — the 4 overflow traps now correctly agree) |
| `relay`, `cases_phase3_standard.tsv` (the "sweep beyond 20", a real pre-existing ~950-case corpus, not written this session) | 953 | **953/953 exact match** |

**Total: 1,080/1,080 same-input OCaml-vs-Lean matches**, all against the correctly-versioned
build, covering nested nested-element state, integer overflow trapping, byte-list operations, and
the full byte-relay read/write/exception protocol. `calculus-correspondence/compare_relay.py` and
the inline comparator used for `nested_state`/`finite_ints` are both kept in the repo, not
throwaway.

### `RVal.rpair`: from empirical to general

Added `evalExpr_fst_pair`/`evalExpr_snd_pair` to `CalculusNested.lean`: for ANY expressions
`ea`/`eb` that evaluate to something (not just the specific `write_block`/`relay` subexpressions),
`fst`/`snd` of `(pair ea eb)` recover exactly `ea`'s/`eb`'s own evaluation, whatever shape it is
(plain data, a reference, or itself another `rpair`). This is now a proved, `∀`-quantified
property, not only the empirical 1,080/1,080 match above (which remains as the independent
empirical check that the property is the RIGHT one, not just an internally-consistent one).

### Byte-list negative controls (re-verified against the corrected build/exports)

Four mutations of REAL exports (not synthetic), re-run after the re-lowering above still hold:

| Mutant | What was done | Outcome |
|---|---|---|
| `mut_single_out_of_range` | `mark`'s real `(single 33)` → `(single 999)` | `failure` (0<=b<=255 check traps) |
| `mut_unsupported_byte_func` | `mark`'s real `single` → `reverse` | `parse_rejected` |
| `mut_negative_take_count` | `read_block`'s real `take` count → `(neg 1)`, swapped into the full `relay` chain | breaks a previously-successful case (`continue`→`failure`) |
| `mut_length_of_nonlist` | `read_block`'s real `(length $t6)` → `(length 999)` (bare int, not a list), swapped into the full `relay` chain | breaks a previously-successful case |

`mutants/bytelist_manifest.json`, `mutants/bytelist_results.json`, `mutants/relay_mut_*.tsv`.

## Session -11: the comparator itself had bugs, a corrected reproducibility script, and a real statement-level theorem

An orchestrator audit (not self-discovered) found `compare_relay.py` had four real bugs:
duplicate case names silently overwritten in a `dict`; only the OCaml side's key set was
iterated, so a name missing from Lean (or extra) could be invisible; an empty corpus on either
side compared as a vacuous "0/0" pass; and only `rc` + `delivered`/`lost`/`input` + the FIRST
element's `cap`/`len`/`bytes` were compared — not `read_calls`/`write_calls`/`reads`/`writes`,
not any additional or nested element, and (a latent crash, never triggered because every prior
run happened to have `outcome: continue`) no handling for a genuine `outcome: failure` match.

**Rewritten** (`compare_relay.py`; the old version kept verbatim, not deleted, as
`compare_relay_v1.py`, since it is what actually produced every number reported before this
session): duplicate names and non-identical case-name sets are now hard errors; an empty corpus
is a hard error; the ENTIRE state tree is compared recursively — every attribute, every element
at every depth, keyed by `(element name, arg)` so producer-side ordering isn't asserted, only
content; every outcome is handled. The normalization this requires (OCaml's hex-object vs plain
int-list vs Lean's flat-array-or-`"()"`) is documented in the module docstring, not buried in a
helper. **Eleven meta-tests** (`tests/test_compare_relay.py`) prove the FIXED comparator actually
catches each failure mode named above, using synthetic fixture pairs (not real compiler output):
duplicate name, case missing from either side, empty corpus (either side, both sides), a changed
NESTED element attribute, a changed COUNTER (a field the old comparator never read at all), a
changed DOUBLY-nested attribute, and confirms element order genuinely doesn't affect the verdict.
All eleven pass.

**Re-verifying with saved outputs** (no compiler rerun) surfaced one genuine metadata bug in how
the -10 corpora were assembled, caught immediately by the new case-set-identity check: the
`nested_state.sc`/`finite_ints.sc` OCaml-side runs had been made against the full 20-case
`cases_curated.tsv` (a copy-paste from the relay-family script), while the Lean side had only
ever been run against ONE trivial empty case — a real 1-vs-20 case-set mismatch the old
comparator's ocaml-keys-only iteration and reliance on `load_run` returning just the LAST line
had silently papered over. Fixed by re-running `compare-run` (the already-built binary; no
recompilation, no container, no lock) for all 27 `nested_state.sc`/`finite_ints.sc` functions
against the SAME `cases_curated.tsv` the OCaml side already used:

| Corpus | Cases | Result (strict comparator) |
|---|---|---|
| `relay` + 4 siblings, `cases_curated.tsv` | 5 x 20 = 100 | **100/100** (unchanged from -10, re-verified) |
| `relay`, `cases_phase3_standard.tsv` | 953 | **953/953** (unchanged from -10, re-verified) |
| `nested_state.sc`'s 7 functions, `cases_curated.tsv` (was 1 trivial case each in -10) | 7 x 20 = 140 | **140/140** |
| `finite_ints.sc`'s 20 functions, `cases_curated.tsv` (was 1 trivial case each in -10) | 20 x 20 = 400 | **400/400** |

**Corrected total: 1,593/1,593** same-input matches (UP from -10's reported 1,080, because
`nested_state`/`finite_ints` are now genuinely compared against the full 20-case corpus, not a
single trivial one) — all under the strict, full-state, case-set-checked comparator, all against
the private corrected build. No field was dropped or excluded to preserve a count; where the
richer comparison could have surfaced a difference (the whole point of fixing it), it did not.

**Reproducibility script** (`setup_private_build.sh`, tested end-to-end this session): the -10
README's inline `docker exec ... patch -p1 < file` never worked as written — `docker exec`
needs `-i` to attach stdin at all, so the redirection was against a detached process, not the
container's `patch`. Fixed by `docker cp`-ing the patch file in (like the other three adapter
files already were) and using `docker exec -i`. The static staging directory name
(`calculus-correspondence10`) is replaced with a fresh `calculus-correspondence11-<UTC
timestamp>-<pid>` directory every run — verified this session to reproduce byte-identical
results (`sha256sum` of the patched `interp.ml`: `e41d6227...`, matching session -10's build
exactly) from a completely fresh, independent staging directory.

**Statement-level theorem** (the orchestrator's item 3: "beyond fst/snd expression lemmas").
`evalExpr_fst_pair`/`_snd_pair` (session -10) are about the syntactic shape `.fn .fst (.pair ea
eb)`; they do not apply to `write_block`'s ACTUAL code, `(fst ι)`, where `ι` is a bare variable,
not a `.pair` expression. Added two more general expression lemmas,
`evalExpr_fst_of_rpair`/`_snd_of_rpair` (for ANY expression that evaluates to an `rpair`, not
just a syntactic `.pair`; the existing session-10 lemmas are now provable corollaries and were
NOT removed), and — the actual statement-level result —
`write_block_prefix_binds : CalculusNested.lean`: for ANY `fuel`, `rest : Stmt Act`, and ANY
binding of `ι` to a nested `rpair bv (rpair ov nv)` (not just the specific triple `relay`
happens to construct), running `write_block`'s EXACT real 3-statement prefix
(`(seq (assign b (fst ι)) (seq (assign off (fst (snd ι))) (seq (assign n (snd (snd ι))) rest)))`)
is `interp`-equal to directly binding `b`/`off`/`n` to `bv`/`ov`/`nv` and continuing with `rest`.
This is a genuine general (∀-quantified) proof connecting the parser/interpreter's `RVal.rpair`
machinery to the STATEMENT semantics `write_block` actually uses — not a claim that this
constitutes "complete lowering/type/state correspondence": see "Exact remaining theorem
obligations" below for what a complete correspondence claim would still need. Axiom-clean
(`[propext, Quot.sound]` or a subset), no `sorry`.

## Session -12: `write_block`'s prefix was stale, the range wrapper, first-assertion coverage, and one `.while` step

Same Claude session as -8 through -11 (`47046454-e02d-4c39-8f50-9ee26b64cee1`, `process.json`
confirms it again). Scope per the orchestrator's prompt: `integration/lean/` and
`calculus-correspondence/` only, no `REQUIREMENTS.md` edit (a concurrent `consolidation-8` job now
owns that file — not touched this session), no commits.

**`write_block_prefix_binds` (session -11) does not match the current real export.** Re-reading
`results/export_input__byte_relay_exec.tsv`'s `write_block` entry this session found the real
`off`/`n` assignments are wrapped in `(range:0:4611686018427387903 ...)` — the v2 lowering's
declared-int-sink assertion (`Func.range`) — not the bare `(fst (snd ι))`/`(snd (snd ι))` the -11
theorem states. `write_block_prefix_binds` is still a TRUE, still-verified statement about the
pattern it names; it is kept, not deleted or weakened. It just isn't the theorem that connects to
`write_block` as it is actually exported today. Added, in `CalculusNested.lean`:

- `evalExpr_range_pass`: a `Func.range lo hi` check is a no-op on a value already known in range.
- `write_block_prefix_binds_ranged`: the REAL prefix (with the `range:` wrapper), general over
  `fuel`/`rest`/the triple's binding, with explicit in-range hypotheses on `off`/`n` as premises
  (their failure — the assertion itself failing — is a lowering/type-soundness question, item 5
  below, not something this statement-level theorem characterizes).
- `interp_assert_pass`/`interp_assert_fail`: the reusable `(seq (cond c pass (raise exc)) rest)`
  "assert-or-raise" building block — this exact shape appears three times in `write_block`'s real
  body (`off <= n`, `n <= b.len`, `l <= b.cap`).
- `write_block_through_first_assert_pass`: COMPOSES the two above — `write_block`'s real prefix
  through its FIRST assertion (`off <= n`), general over `fuel`/`rest`/the triple's binding, pass
  case only. This is genuine "beyond the prefix" coverage, honestly scoped: it reaches the point
  just before the first `.get` (a real state read), not the rest of the function. The second and
  third assertions additionally depend on `.get $t9 b len` / `.get $t11 b cap` — reads of `st` at
  `b`'s reference path — so composing them needs a hypothesis characterizing `st`'s shape there;
  NOT attempted this session (folded into item 1 below, narrowed, not resolved).
- `interp_while_true`/`interp_while_false`: `interp`'s own `.while` equation, restated as general
  before/after facts (same spirit as `and_skips_rhs`/`or_skips_rhs`). Deliberately scoped to ONE
  iteration — `relay`'s real export has two nested `.while` loops (an outer `(while true ...)`
  that only terminates via a `.ret`/`.raise` inside its body, and an inner
  `(while (< (pair off r)) ...)` driven by `off` reaching `r`); these lemmas do NOT prove
  termination or an invariant for either loop, only give a mechanically-checked single-step fact
  usable as a building block for that future proof.

All six new theorems: `lake build` clean (from-scratch full rebuild, all 25 targets), axiom-clean
(`[propext]` or `[propext, Quot.sound]`, always a subset of the standard trio), no `sorryAx` —
`integration/results/lean_axioms_export.txt` refreshed with this session's actual audit output,
not assumed. Two real proof bugs caught and fixed while doing this (worth recording, since these are
easy to get wrong silently): (1) fuel-arithmetic for `interp_assert_pass`/`_fail` — `.seq (.cond c
.pass (.raise exc)) rest` at incoming fuel `k+3` unfolds ONE level to `k+2` for both the `.cond`
dispatch and `rest`'s continuation (not `k+1` as first guessed, and not bare `k`) — traced by hand
against `interp`'s actual equations rather than assumed by analogy to the `.seq`-triple prefix
theorem's arithmetic, which has a different shape; (2) `lookup_assocSet_other`'s hypothesis
direction is `b ≠ a` where `a` is the SET key and `b` is the LOOKED-UP key — an inverted
hypothesis (`"n" ≠ "off"` instead of `"off" ≠ "n"`) elaborates fine as a term but is simply
inapplicable to the goal, so simp reports it "unused" rather than erroring, which is a
misleading-if-not-read-carefully failure mode. Also: this project's `lakefile.toml` is core-only
(no mathlib) per `CLAUDE.md`, so the `set` tactic is unavailable — discovered as an "unknown
tactic" error, fixed by writing the full expression out instead of aliasing it.

Did NOT start: a general `Stmt.WF` precondition (item 3 below, unchanged from -11); the
second/third assertions' `.get`-dependent continuation; any termination/invariant proof for either
`.while` loop. No new LLM evaluation. No sibling job directories touched.

## Sessions -13 and -14: the WHOLE `write_block` and `read_block` bodies, both `relay` loops, and `relay` itself — kernel-identified with the export

Same Claude session as -8 through -12 (`47046454-e02d-4c39-8f50-9ee26b64cee1`). Session -13 hit
the account quota mid-build (no REPORT of its own; the orchestrator's `calculus13-terminal-audit`
recorded the state, and a Pi `calculus13-step-repair` job repaired the last failing proof —
`relay_inner_step`'s `simp` step limit — with a tactics-only change, statements untouched; the
accepted result is archived at `artifact/archive/calculus-body13/`). Session -14 resumed after the
11:30 UTC reset and continued to the loops. Scope both times: `integration/lean/` and
`calculus-correspondence/` only; `REQUIREMENTS.md` not touched; no commits; no LLM trials.

### Mechanical identity with the export (kernel-checked, new in -13)

Every theorem below is about a `Stmt` value that the KERNEL has checked to be what the exporter
printed. `CalculusBody.lean` / `CalculusRelayOuter.lean` contain the token lists of the current
`write_block`, `relay` and `read_block` entries of `results/export_input__byte_relay_exec.tsv`
(sha256 `5b3af9ea…c25a281`; the lists were generated by a script, not typed), and
`writeBlock_parse`/`relay_parse`/`readBlock_parse` prove by `decide +kernel` that the shared
checked parser `CalculusExport.parseStmt` maps those tokens to exactly `writeBlockBody`/
`relayBody`/`readBlockBody` (and `*_render` that `renderStmtToks` maps them back). Two changes to
the accepted parser were needed for the kernel to be able to evaluate it at all, both documented
in `CalculusExport.lean` and both re-proved against the general round-trip theorems:
`unescape` was a `partial def` (opaque to the kernel) and is now the same structural recursion;
`parseIntLit` read digits with `String.toNat?`, which in Lean 4.31 goes through `String.Slice`
`for`-loops (well-founded recursion the kernel does not evaluate) and silently accepted `_` digit
separators — it now uses a hand-rolled structural `digitsToNat?` (strict `[0-9]+`), with
`parseIntLit_repr` re-proved from `Nat.repr_of_lt`/`repr_of_ge`. `Expr`/`Stmt` additionally
derive `DecidableEq` (additive). The ONE link the kernel does not see is text -> tokens
(`CalculusExport.tokenize`, `partial`, the same untrusted glue `export-run`/`compare-run` always
used); it is checked executably: `CalculusBodyReceipts.lean`/`CalculusRelayLoopAxioms.lean`
print `(true, true)` for `tokenize text == toks` and `parseStmt 400 (tokenize text) == some (body,
[])` on the verbatim TSV lines (`integration/results/lean_body_receipts.txt`,
`lean_axioms_relay_loops.txt`).

### Whole-body theorems (`CalculusBody.lean`, -13; `CalculusRelayOuter.lean`, -14)

All ∀-quantified over fuel, environment, state, block/root paths and contents, under EXPLICIT
hypotheses (a well-formed block whose `len` is its byte count, byte-valued lists, the in-range
premises of the body's own `range:` assertions, counter headroom for the checked `+ 1`):

- `write_block_body_ret`: `0 ≤ q` (the scheduled write count `head_or writes |req|`) →
  exactly three `setAttrAt`s at `σ` (`writes := tail`, `write_calls := +1`, `delivered :=
  delivered ++ take k req`) and `return k` with `k = min q |req|`, `req = bytes[off, n)`.
  `write_block_body_neg`: `q < 0` → the two bookkeeping updates and `return -1`.
  `write_block_assert{1,2,3}_raises`: the three `AssertionFailure` error paths (`¬ off ≤ n`,
  `¬ n ≤ len`, `¬ len ≤ cap`), state unchanged.
- `read_block_body_ret`/`_neg`: `reads := tail`, `read_calls := +1`; then (non-negative entry)
  `bytes := take k input`, `len := k`, `input := drop k input`, `return k` with
  `k = min (max 1 q) (min cap |input|)`; or `return -1`.
- Argument-shape correction: `relay`'s call `(pair b (pair (range off) (range r)))` evaluates to
  `rpair (sref b) (v (pair off r))` — NOT the nested `rpair _ (rpair _ _)` the -11/-12 prefix
  theorems assumed. Those remain true statements about the shape they name; the body theorems use
  the real shape and `relay_inner_step` (which composes through the exported call site with no
  extra assumption) is the proof that it is the real one.

### `relay`'s loops and `relay` itself (`CalculusRelayLoop.lean`, `CalculusRelayOuter.lean`, -14)

- `relay_inner_step` (-13, repaired): one positive-write inner iteration advances `off` by the
  returned `k > 0` and continues the same loop two fuel levels lower. `relay_inner_lost`: the
  `w ≤ 0` iteration extends `lost` by the unwritten slice and returns `2`.
- `InnerInv` (invariant: bindings, well-formed block at a non-root path, well-formed root lists,
  `0 ≤ off ≤ r ≤ len ≤ cap`, a `write_calls` ceiling with per-iteration headroom, and every root
  attribute the loop does not write kept at a fixed value); `relay_inner_step_inv`:
  preservation + progress (continue with `InnerInv` and `off` strictly larger, or `return 2`);
  `relay_inner_loop_run`/`_terminates`: the fuel-bounded invariant — `2·(r-off)+30` fuel above
  any base and the loop either exits with `off = r` and `InnerInv`, or returns `2`; never
  `.failure`, never `.raise`.
- `OuterInv` + `relay_outer_step`: one outer iteration (`read_block`, the `r < 0`/`r = 0`
  returns, `off := 0`, the whole inner loop) either strictly shrinks the input and continues with
  `OuterInv`, or returns `0`/`1`/`2`. `relay_outer_loop_run`/`_terminates`: `2·|input| + 2·cap +
  37` fuel above any base and the loop returns `0`, `1` or `2`.
- `relay_prologue` + `relay_terminates`: from the entry point `runEntry actDef fuel "relay" st`
  (the exact call `compare-run` makes), for ANY state carrying the seven root attributes
  `cb_main.ml`'s `initial_state` builds (byte-valued where bytes are read, counters with headroom
  for the run), the result is `.continue (rc := v) st'` with `v ∈ {0, 1, 2}`, at fuel
  `2·|input| + 108` above any base. `relayBody_eq` is the definitional identity between
  `relayBody` (kernel-identified with the export) and "prologue; outer loop".
- `CalculusSimulation.lean`: `interp_succ_*` (the definition, one constructor per equation,
  all `rfl`) and the fuel-simulation theorem `interp_fuel_mono`/`interp_fuel_mono_le`: a run
  that does not exhaust its fuel is reproduced exactly by EVERY larger fuel, for every statement
  form. This is what makes the `fuel + k` statements above budget-independent
  (`relay_inner_loop_terminates_any_fuel`). It is NOT the "general `Stmt.WF`
  preservation/simulation" obligation (the root/Pi `simulation-scope-audit-26` review is
  explicit on this, and it is right): `Stmt.WF` is the syntactic parse/render well-formedness
  predicate, and fuel monotonicity says nothing about well-formedness, the lowering, or
  range/type semantics — see obligation 3 below.
- `writeBlockBody_WF`/`readBlockBody_WF`/`relayBody_WF` (kernel evaluation of the ~300
  decidable atoms each) and `*_round_trip`: the syntactic `Stmt.WF` predicate — previously only
  used abstractly — now holds for the three real exports, so the ∀-quantified round-trip theorem
  `round_trip_stmt` applies to them (a second route to the parse identities). Still NOT a
  `Stmt.WF`-style precondition under which the whole-body/loop theorems apply to an ARBITRARY
  export; that "shape lemma" is open (obligation 3).

### Receipts (session -14, all fresh; root-accepted snapshots in the -14 job directory)

The orchestrator's root independently accepted the inner-loop snapshot (11:38 UTC,
`ROOT-INNER-LOOP-AUDIT.json`) and the outer-loop/entry-termination snapshot (12:00 UTC,
`ROOT-OUTER-LOOP-AUDIT.json`) with the hashes recorded in the -14 REPORT; the `Stmt.WF`
instantiations were added after those snapshots (final `CalculusRelayOuter.lean c49b20a8…`).
From-scratch clean rebuild (`rm -rf .lake/build`; `integration/results/cc14_clean_build.log`,
33/33 targets, exit 0); `lean_body_receipts.txt` and `lean_axioms_relay_loops.txt` (`#eval`
identities `(true, true)`, `#print axioms` for every theorem named above: `propext`,
`Classical.choice`, `Quot.sound` or a subset; zero `sorryAx`); `lean_axioms_export.txt`
refreshed. Source hashes at the end of the session are in the -14 job REPORT. All Lean runs went
through the shared `phase3-compiler.lock`; no OCaml/container work this session (no new
comparisons were needed — nothing on the OCaml side changed).

### Proof-engineering notes worth keeping

- Never `simp [interp]` on a statement containing an abstract sub-statement, a `.while`, or an
  `.action` whose callee has a big body: `interp`'s equation applies to `interp (n+1) s` for ANY
  `s`, so it unfolds everything reachable (the -13 step-limit failure). Use the one-layer
  `interp_succ_*` equations, keep callee bodies folded (`generalize … = W`) and rewrite with the
  callee's own theorem.
- Never mix two spellings of the same fuel (`x + 108` vs `x + 100 + 7 + 1`): if Nat-offset
  unification fails, `isDefEq` falls back to unfolding `interp` through the whole program and
  times out (`relay_terminates`, first attempts). Keep one canonical spelling and move every
  re-association into an `omega`-proved `rw`.
- `set` is not in core Lean; `partial def`s and `String.toNat?` are invisible to the kernel;
  `cases … with | continue` needs `«continue»`; a `?e`-named metavariable is shared across
  sibling branches of one proof (name them apart).

## Session -15: `relay` IS the phase3 protocol model; a total tokenizer; fragment-general rules

Same Claude session (`47046454-e02d-4c39-8f50-9ee26b64cee1`), 12:09–~13:00 UTC. Scope per the
orchestrator: beyond termination, to the exact functional final state, related to the REUSED phase3
relay protocol model rather than to a fresh encoding of the interpreter; a total fail-closed
tokenizer with kernel text→AST identity; general (not per-export) fragment rules; the
OCaml/lowering boundary stated as an open requirement, not an impossibility. Owned files only; no
commits; no LLM trials; no OCaml/container work; every Lean run under the shared lock.

### 1. The exact functional final state: `CalculusRelaySpec.lean`

The specification is NOT new: it is `BufferRelay.drain`/`execute`/`run` from
`integration/lean-final/BufferRelay.lean` (phase3's relay protocol model, the one the C relay was
checked against), reused unchanged. Bytes there are `UInt8`; the calculus carries `Int`s in
`[0, 255]` (`toInts`).

- `relay_inner_exact`: the inner loop IS `drain` on the block view `blk.drop off` — for every
  fuel bound, environment, state, schedule, `delivered`/`lost`/`write_calls` values: not-failed
  ⇒ exit with `delivered ++= drain.output`, `writes := drain.writes`, `write_calls +=
  drain.calls`, everything else unchanged (`Frame`); failed ⇒ `return 2` with additionally
  `lost ++= drain.pending`. (`drain.output ++ drain.pending = view` is phase3's own
  `drain_contract`, so this is conservation of the block bytes, inherited.)
- `relay_outer_exact_step`/`relay_outer_exact`: the outer loop IS `execute`, for EVERY model
  memory (`loaded_eq` makes the memory irrelevant): status, `delivered`, `lost`, remaining
  `input`, `read_calls`, `write_calls` all equal `execute`'s fields, by induction on the input
  length with the strictly-shorter-input continuation.
- **`relay_matches_phase3`**: from `compare-run`'s OWN initial state (`CompareMain.initialState
  (toInts inp) rs ws`, imported, not re-typed), `runEntry actDef (fuel + 2·|inp| + 110) "relay"`
  returns `.continue (rc := (BufferRelay.run inp rs ws).status)` in a state whose
  `delivered`/`input`/`lost`/`read_calls`/`write_calls` are `run`'s `output`/`remaining`/
  (`runDetailed`'s) `pending`/`readCalls`/`writeCalls`. Only premise: `|inp| + 1 ≤ maxInt`
  (the checked `+ 1`). Every phase3 theorem about `run` (`run_prefix`, `run_success_exact`,
  `run_conservation`, `run_call_bounds`, `run_status`, ...) therefore transfers to the calculus
  `relay` by rewriting. The 1,593 same-input OCaml comparisons and the phase3 model are now
  connected through the SAME Lean object.
- Executable cross-check in `CalculusRelaySpecAxioms.lean`: on phase3's `Examples.retry_binary`
  schedule both sides print `status 0, delivered [0,255,10,128], readCalls 4, writeCalls 4`.

### 2. Total fail-closed tokenizer: `CalculusTokenize.lean`

`tokenizeTotal` (structural, fuel = length + 1, `none` on an unterminated string literal —
`CalculusExport.scanString` silently accepted one) and `parseText` (tokens must be consumed in
full). Kernel-checked: `small_text_tokens` (a real `write_block` fragment with a string literal),
six negative controls (`rejects_unterminated_string`, `_after_escape`, `_non_statement`,
`_trailing`, `_match_text`, `_underscore_range`). Executable receipts: `tokenizeTotal` equals the
historical `tokenize` on all three verbatim exports and `parseText` yields the three bodies
(`(true, true, true)` ×3). **Obstruction, measured**: `decide +kernel` on `tokenizeTotal
writeBlockText = some writeBlockToks` (1,300 characters) did not finish in 15 minutes (`lake
build` timeout 900 s); the kernel-checked identity from TEXT for the full bodies therefore
remains open, with the ~200-character fragment as the largest kernel-evaluated instance. Not
done on purpose: switching `export-run`/`compare-run` to `tokenizeTotal` — with no kernel
theorem over the full text there is no trust gained, and the 1,593 comparison record would have
to be regenerated for nothing; the historical `tokenize` is unchanged.

### 3. Fragment-general rules: `CalculusFragmentRules.lean`

`Stmt.Pure` (no `setAttr`/`addElem`/`removeElem`/`action`) and `interp_pure_state`: for EVERY
pure statement, fuel, environment and state, the result's state component is the input state —
whole-state preservation proved once over the fragment (fuel induction, all 15 forms), not per
export. `Stmt.Supported` records that the supported fragment is `CalculusNested.Stmt` itself:
unsupported forms are rejected at parse time (`parseStmt_rejects_*`), never inside `interp`.
NOT a type-soundness theorem: no rule here discharges `range:`/`range-list:`/checked-arithmetic
assertions for well-typed programs; those stay explicit hypotheses of the body theorems.

### Receipts (session -15)

From-scratch clean rebuild 37/37 targets exit 0 (`integration/results/cc15_clean_build.log`);
`lean_axioms_relay_spec.txt` (`#print axioms` for every -15 theorem: `propext`,
`Classical.choice`, `Quot.sound` or a subset; the three `(true, true, true)` receipts; the
`retry_binary` cross-check), `lean_axioms_relay_loops.txt`, `lean_body_receipts.txt`,
`lean_axioms_export.txt` all refreshed, zero `sorryAx`. Hashes in the -15 job REPORT.

## Sessions -16/-18 (tokenizer, handed off) and -61: general typing with preservation, and the checked lowering relation

Sessions -16 and -18 (same Claude session, both cut short by infrastructure) repaired and
completed the tokenizer concatenation lemma (`tokenizeT_concat_space`, `tokenizeT_sufficient`,
`tokenizeTotal_concat_space`) and drafted the chunked full-text identities
(`CalculusTokenizeChunks.lean`); the tokenizer files were then handed to a separate in-session
owner (`tokenizer_verify`) and are NOT reported here — see the orchestration record. Session -61
(18:12 UTC onward) had NEW ownership: the two requirements that no earlier session had touched,
in NEW modules only (`CalculusTyping`, `CalculusLowering`, `CalculusTypeCheck`,
`CalculusTypingAxioms`; not registered in `lakefile.toml`, which was not editable), compiled under
the shared lock with one Lean thread under the authorized 3 GiB address cap. Recorded deviation:
the session's first compiles used a 4 GiB cap after `lake env lean` under 3 GiB aborted at
worker-thread creation; the orchestrator rejected that (no probes above 3 GiB), and the final
receipts were re-produced under 3 GiB by invoking the toolchain `bin/lean` directly with
`-j1 -s 16384 -DElab.async=false` and an explicit `LEAN_PATH` (every module ≤ 3.1 s, ≤ 768 MB RSS;
`recompile_3gib.log` in the -61 job directory).

### A type system for the fragment, with preservation over `interp` (`CalculusTyping.lean`)

`Ty` (int, bool, str, unit, scalar-literal, bytes, int list, top, pairs), `RTy` (data, state
reference, reference-bearing pair), value typing `VTy`/`RVTy`, subtyping `Sub` (`bytes ≤ list`,
literals `≤ scalar`, everything `≤ top`, pairs covariant), one signature per `Func`
(`funcArg`/`funcRet`; byte lists where `funcDef` demands `asByteList?`, int lists where it
demands `asIntList?`, `range-list:lo:hi` yields `bytes` exactly when `[lo,hi] ⊆ [0,255]`),
expression typing `ETy`, statement typing `STy` over an attribute schema and the current return
type (re-assignment keeps a variable's type, so contexts only grow: `STy_extends`), well-shaped
states `StTy` (every present attribute, at every path, carries its schema type), and:

- `funcDef_sound`: a well-typed builtin argument never yields an ill-typed result;
- `ETy_sound`: a well-typed expression that evaluates yields a value of its type;
- **`preservation`**: for EVERY fuel, statement form, environment and state — well-typed
  statement, well-typed environment, well-shaped state ⇒ the result is `.continue` with a
  well-typed environment and well-shaped state, `.raise` with a value of the exception type
  `(pair str top)` and a well-shaped state, `.ret` with a value of the declared return type and
  a well-shaped state, or `.failure`. Exceptions are typed as `(pair "Tag" payload)`, which is
  exactly what the lowering raises and what `exc-is:Tag` needs; action bodies are assumed typed
  against their signatures (`ActsTyped`).

Stated limitation, kept explicit: `preservation` allows `.failure`. Failures come from fuel
exhaustion, `funcDef` traps (`range:`/`range-list:`/checked arithmetic/division by zero/list
bounds) and absent attributes/elements at the addressed path; these are the program's own
assertions, not type errors, and they remain exactly the explicit hypotheses of the whole-body
theorems (`write_block_body_ret`'s `0 ≤ off ≤ n ≤ len ≤ cap`, byte-valued lists, counter
headroom). Range safety is therefore NOT claimed by this type system; what it adds is the general
statement, over the whole fragment, that well-typedness of environments and states is invariant
under execution.

### The checker and the concrete derivations (`CalculusTypeCheck.lean`)

`inferE`/`checkE`/`checkS` compute types; `inferE_sound`/`checkE_sound`/`checkS_sound` turn a
successful check into an `ETy`/`STy` derivation. `relaySchema` is the CONCRETE schema of
`byte_relay_exec.sc` (`input`/`delivered`/`lost`/`bytes` : bytes; `reads`/`writes` : int list;
`read_calls`/`write_calls`/`cap`/`len` : int), `relaySig` the nine action signatures the lowering
declares. Kernel-evaluated: all nine exported bodies type-check (`*_typed`, incl. `relay_caught`'s
`try/catch` and every `if`/`return`/`while`), `relayActs_typed : ActsTyped …` for the real
action table, and `writeBlock_preserves`: any run of the exported `write_block` from a well-typed
argument and a well-shaped state ends well-typed or fails. The checker's output contexts are
printed in the receipt (e.g. `write_block` binds `ι σ b off n $t9 l $t10 … k $t16`).

### The lowering, re-implemented and checked against the exports (`CalculusLowering.lean`)

A Lean transcription of `calculus-bytes/adapter/lower.ml` (v2) clause by clause — adapter types,
`resolve`/`coerce` (range assertions inserted exactly where the OCaml inserts them), the
supported fragment of `Ast.Parsed` (`SExpr`/`SStmt`/`Decl`; every construct `lower.ml` rejects
has no constructor, so the model fails closed), `lexpr`/`lstmt`/`lblock`/`lowerProgram`
fuel-indexed for kernel evaluation, INCLUDING the temporary-name counter's evaluation order
(`$t1`… numbered across functions in declaration order). `byteRelayExecSpec` encodes
`fixtures/byte_relay_exec.sc` by hand from its text. **`lowering_checked`** (kernel, `[propext]`
only): `lowerProgram byteRelayExecSpec` is EXACTLY the nine exported bodies — the three
kernel-identified with the export in -13/-14 plus the six others generated from the same TSV
(`relay_raising`, `relay_caught`, `mark`, `relay_seq_relay`, `relay_and_mark`, `relay_or_mark`).
The `#eval` receipt shows all nine `true`.

What this is and is not: a checked relation between (i) a Lean encoding of the spec-language AST,
(ii) a Lean re-implementation of the lowering, and (iii) the exported calculus. It is NOT a proof
about `lower.ml`'s OCaml text, and (i) is hand-transcribed. The step that removes the hand
transcription — an S-expression printer for the pinned parser's `Ast.Parsed` — is written
(`spec_ast_export/print_ast.ml`, source only, to be built in a PRIVATE staging tree via
`run_vst.py`; its record field names must be confirmed against the pinned `ast.ml`) and is the
first item of the -61 NEXT.

### Receipts (-61)

`integration/results/lean_axioms_typing_lowering.txt` (`1f3a4817…`, re-run under the authorized 3 GiB cap): every theorem on
`propext`/`Classical.choice`/`Quot.sound` or a subset, zero `sorryAx`; `lowering_checked`,
`writeBlock_typed`, `relayCaught_typed`, `inferE_sound`, `subB_sound` on `propext` alone. Sources:
`CalculusTyping.lean 13c41466…` (1,136 lines), `CalculusLowering.lean 45a2bae4…` (742),
`CalculusTypeCheck.lean 9b6bc7e9…` (507), `CalculusTypingAxioms.lean 3b6fa9bd…`. Snapshot with
manifest and compile logs: `claude-resume/calculus-correspondence-61/accepted-candidate/`.

## Session -75: the machine-produced spec AST, and what the guards establish

Session -75 (18:55–19:15 UTC, same session) closed -61's first NEXT item and started its second.
Root independently accepted the export milestone during the session
(`root-spec-export-review77`); the accepted bytes are preserved.

### The lowering's INPUT is now machine-produced (`spec_ast_export/`, `SpecAstExport.lean`)

`print_ast.ml` was checked constructor-by-constructor and field-by-field against the pinned
`bash-verifier/lib/frontend/ast.ml` (sha256 `eeff5471…`, identical in the shared container and
the host clone; `Parsed.annt = {ast; pos}`, `typ_base`, `expr_base`, `stmt_base`, the six
`decl_base` records), built in a FRESH private staging tree
(`/home/coq/phase5/calculus-correspondence11-20260908T185751Z-447040`, `setup_private_build.sh`;
the shared original untouched) as a second dune executable next to `cb_main`, and run on the
repo's `fixtures/byte_relay_exec.sc` (`429241a3…`) — all through `run_vst.py` under the shared
compiler lock (receipts `cc75-print-ast-build-1/2`, `cc75-print-ast-run-1`; exit 0, 6.4 s +
0.4 s build, 0.02 s run). The raw export — 33 declarations, 4,579 bytes, sha256 `3f687ca1…` —
is preserved verbatim at `spec_ast_export/results/byte_relay_exec.ast.sexp`. It is the output
of the SAME parse entry `cb_main.exe` uses (`Parser.program Lexer.token`).

`sexp_to_lean.py` (deterministic; the emitted file is a pure function of the input bytes and
records both hashes in its header) translates the export node-for-node into
`integration/lean/SpecAstExport.lean`'s `exportedSpec : List Decl`. It FAILS CLOSED: any
`(unsupported …)` node, unknown head, malformed shape, or unknown type/operator atom aborts with
no output — checked on three negative controls (unsupported statement, unsupported expression,
generic named type). Then, kernel-checked:

- **`exportedSpec_eq_hand : exportedSpec = byteRelayExecSpec`** — NO axioms at all (`rfl` on two
  closed constructor terms; Lean 4.31's `DecidableEq` deriving does not handle the nested
  inductives `SExpr`/`SStmt`, so `decide` was not available, and none was needed). The -61 hand
  encoding was therefore exactly right; nothing had to be reconciled.
- **`exported_lowers : lowerProgram exportedSpec = some [nine exported bodies]`** — `[propext]`,
  by rewriting with the equality above into `lowering_checked`.

Boundary, stated exactly: the chain is now `pinned parser → print_ast.exe → raw S-expression →
sexp_to_lean.py → Lean term`, with the two new tools hashed and the raw file kept; the new
trusted executables are the printer and the generator (small, reviewable, not proved). What is
kernel-checked is that this machine-produced AST lowers, under the Lean re-implementation of
`lower.ml`, to exactly the nine bodies the OCaml `lower.ml` exported. `lower.ml`'s and
`interp.ml`'s OCaml text remain outside Lean.

### What the lowering's guards establish (`CalculusGuards.lean`)

The v2 lowering emits exactly two guard forms: `range:lo:hi(e)` around every declared-int sink
(`range-list:lo:hi` for lists) and `assert c` as `cond c pass (raise ("AssertionFailure", ()))`.
General lemmas: `range_guard_some` (passing a range guard means the value WAS an int, is
returned unchanged, and lies in `[lo,hi]`), `range_guard_fail` (failing is `none`, i.e.
`.failure` — never a wrap, never a raise), `rangeList_guard_some`, `assign_range_cases`
(`x := range(e)` fails or continues with an in-range binding and the state untouched),
`assert_guard` (exact semantics), `assert_guard_continue`, `assert_le_continue`.

For the exported `write_block`: `writeBlockBody = wbGuardPrefix wbRest` by `rfl` (the prefix is
the two range sinks and the three source assertions; `wbRest` is read off the body itself), and
**`write_block_guard_gate`**: for the real call shape and an int-valued `len`/`cap`, the run
either reaches `wbRest` with `0 ≤ off`, `off ≤ n`, `n ≤ len`, `len ≤ cap`, `n ≤ rangeMax`
ESTABLISHED and the state untouched, or fails at a range guard, or raises `AssertionFailure`
with the state untouched — no other outcome. Hence **`write_block_guarded`** =
`write_block_body_ret` with those five hypotheses DELETED. The remaining hypotheses are
classified in the module docstring as imported invariants no guard checks: `bs.length = len`
(state invariant), byte-valuedness of `bytes`/`delivered` (`funcDef` shape traps, plus the
`range-list:0:255` sink on the SLICE only), counter headroom (checked-arithmetic trap), and
`0 ≤ q` (a property of the write schedule; the `q < 0` case is `write_block_body_neg`).

Not claimed: any general no-failure theorem. Failure stays reachable through fuel, non-guard
`funcDef` traps and absent attributes; typing does not exclude them either.

### Receipts (-75)

`integration/results/lean_axioms_spec_ast_export.txt` (`8ded5b73…`): `exportedSpec_eq_hand` no
axioms, `exported_lowers`/`lowering_checked` `[propext]`, 33 declarations, nine names.
`integration/results/lean_axioms_guards.txt` (`5da2a7be…`): eleven theorems on
`propext`/`Classical.choice`/`Quot.sound` or a subset, zero `sorryAx`, `wbRest ≠ .pass`. All
Lean checkpoints: direct toolchain `bin/lean`, 3 GiB address cap, one thread, `-j1 -s 16384
-DwarningAsError=true -DElab.async=false`, ≤ 0.8 s and ≤ 509 MB each (logs in the -75 job
directory). Sources: `SpecAstExport.lean 6b8599…`, `CalculusGuards.lean f1bff245…` (343 lines),
`print_ast.ml 9c128ef7…`, `sexp_to_lean.py cbb13c97…`.

## Session -79: guards threaded through `relay`'s invariant, the `read_block` gate, `try/catch`

Session -79 (19:22–19:35 UTC, same session; root82 accepted `CalculusGuards` unchanged during it)
added three NEW modules, all compiled under the same discipline (direct `bin/lean`, 3 GiB, one
thread, `-DwarningAsError=true -DElab.async=false`, ≤ 0.6 s / ≤ 505 MB each), all on standard
axioms with zero `sorryAx` (`integration/results/lean_axioms_guards_relay.txt` `a211dc66…`,
`lean_axioms_trycatch.txt` `3b097872…`).

### `CalculusGuardsRelay.lean` — the inner-loop invariant without its range facts

`InnerInvW` is -14's `InnerInv` with the five range fields (`0 ≤ off`, `off ≤ r`, `r ≤ len`,
`len ≤ cap`, `r ≤ rangeMax`) REMOVED, leaving exactly the imported invariants no guard checks:
bindings, block shape, `len = |bytes|`, byte-valued lists, counter headroom, the frame of
untouched root attributes. **`relay_inner_step_guarded`**: from `InnerInvW` and the loop test
`off < r`, one iteration either has the four remaining facts and then behaves exactly as
`relay_inner_step_inv` (the full `InnerInv` is re-established), or is `.failure` (a `range:` guard
failed at the call site or inside `write_block`), or is `.raise ("AssertionFailure", ())` with the
state UNTOUCHED. **`relay_inner_loop_run_guarded`** is the same trichotomy for the whole
fuel-bounded loop run (`relay_inner_loop_run`'s conclusion in the first case). The mechanism is
`interp`'s `.action` rule (`relay_inner_call_failure`/`_raise`): the callee's failure is the
caller's failure, the callee's raise is the caller's raise with the callee's state. What is NOT
claimed: that the range facts hold — in the real `relay` they do (`OuterInv` carries them); the
theorem says a violation can never pass silently.

### `CalculusGuardsRead.lean` — the `read_block` gate, and a difference that matters

`readBlockBody` has no assertions; its only guards are the three `range:0:rangeMax(k)` sinks on
the read count `k = rbK rs cap inp`, and they sit AFTER the two bookkeeping writes.
`rbK_nonneg_iff : 0 ≤ k ↔ 0 ≤ cap` (so the read-count guard is really a guard on the declared-`u64`
capacity), `rbK_le_rangeMax`, `read_block_guard_fail` (k out of range ⇒ `.failure`, stated after
`reads`/`read_calls` were written), and **`read_block_guard_gate`** = `read_block_body_ret`
minus `hcap0 : 0 ≤ cap`: for a non-negative schedule entry, `cap < 0 ∧ .failure`, or `0 ≤ cap`
derived and the `.ret` of `read_block_body_ret`. Imported and NOT guard-derived: `cap ≤ rangeMax`
(declared width), counter headroom, byte-valued `input`. Recorded explicitly: `read_block`'s
guard is NOT a pre-guard — a blanket "guards fail before any write" claim would be false for it.

### `CalculusTryCatch.lean` — the exported `relay_caught`, functionally

Four lemmas exhaustive over the callee's `Res`, the first functional statements about a real
exported `try/catch` (`interp_succ_tryCatch` on `relayCaughtBody`): `relay_caught_of_ret` (a
return passes through), `relay_caught_of_readError` (a `ReadError(x)` raise is caught: `return 1`
with `code := x`), `relay_caught_of_other` (any other exception is re-raised unchanged),
`relay_caught_of_failure` (`.failure` is not caught). `relay_raising`'s own whole-body theorem
(what it returns/raises) remains open.

### Exact remaining theorem obligations for a complete general correspondence claim

1. **`relay_raising` whole-body theorem** (the `relay` machinery with `raise ReadError(r)` in
   place of `return 1`; `OuterInv` reusable), then compose with `CalculusTryCatch` to get
   `relay_caught`'s functional theorem against phase3's `run` (status 1 on a negative read).
2. **Residual non-guard failure sources, listed and closed where possible.** With the two gates
   and the threading, the relay family's `.failure` sources are exactly: fuel; checked `+ 1` on
   `read_calls`/`write_calls` and `off + w` (headroom fields of `InnerInvW`/`OuterInv`);
   list-shape traps (byte-valuedness fields); absent attributes (the schema, `StTy`). A
   `RangeSafe`-style judgment is needed only for these; design it over the concrete relay schema.
3. **The OCaml lowering and interpreter** stay outside Lean (`exported_lowers` relates the
   machine-exported input to the exported output through the Lean re-implementation;
   `print_ast.exe`/`sexp_to_lean.py` are trusted executables).
4. **Tokenizer full-text identities** (`CalculusTokenizeChunks.lean`): owned by the tokenizer
   session; not reported here.
5. **Registration (root):** `lean_lib` entries for `CalculusGuardsRelay`, `CalculusGuardsRead`,
   `CalculusGuardsRelayAxioms`, `CalculusTryCatch`, `CalculusTryCatchAxioms`.

## The driver: real compiler output through the checked parser and interpreter

`results/export_input__<file>.tsv` (per-file, bare function names — an earlier same-session draft
that globally prefixed names broke cross-function `action` calls within a file; fixed before any
number above was collected) is NOT hand-written: it is the `"calculus"` field of
`cb_main.exe lower`'s own JSON output, run on real pinned-parser source under
`calculus-bytes/fixtures/`. `results/export_output.jsonl` (`export-run`, `St.empty` — no
byte-relay initial state, so anything needing `input`/`reads`/`writes` genuinely can't run
meaningfully from empty state) over the current 46 real functions: 0 `parse_rejected`, 15
`continue`, 31 `failure` (accounted for: 5 deliberate overflow/div-zero traps, 2 deliberate
missing-parent-path tests, and 18 functions across the two `byte_relay_exec*.sc` variants that
need the real initial state `export-run` doesn't provide — see `compare-run`'s results in the
table above for the correct way to run those).

## Trust boundary

- TRUSTED, NOT CHECKED: that `cb_main.exe`'s `Lower.show_stmt` faithfully serializes the OCaml
  lowerer's `Calculus.Ast` value, and that the lowerer (a private adapter, not upstream) matches
  any intended source semantics. `funcDef`'s byte-list/`RangeList` cases are DEFINED to match
  `bytes_builtin.ml`, not extracted from it.
- WHICH BUILD MATTERS, EXPLICITLY: every same-input number in this file is against a PRIVATE
  build (`setup_private_build.sh`, a fresh `calculus-correspondence11-<timestamp>-<pid>`
  directory each run — session -10's build at the now-superseded static path
  `/home/coq/phase5/calculus-correspondence10` is what actually produced this session's re-verified
  numbers, since they reused those saved outputs; a from-scratch run of the new script this
  session reproduced a byte-identical patched `interp.ml` hash), never the shared
  `/home/coq/phase5/calculus-bytes` original, which remains on an older, unpatched, pre-v2 build.
  A future session comparing against the SHARED container path without checking this will
  silently reproduce session -9's narrower (and, for `nested_state`/`finite_ints`, WRONG) results.
- CHECKED BY LEAN'S KERNEL, GENERAL: `parseStmt`/`parseExpr`/`renderFunc`/`parseFunc` round-trip
  for every `Stmt`/`Expr`/`Func` value, including the eleven byte-list operators and
  `range`/`range-list`; `Val.asIntList?_ofIntList`, `evalExpr_fst_pair`/`_snd_pair`,
  `evalExpr_fst_of_rpair`/`_snd_of_rpair`, and (session -11/-12, STATEMENT-level, not just
  expression-level) `write_block_prefix_binds`, `write_block_prefix_binds_ranged`,
  `interp_assert_pass`/`_fail`, `write_block_through_first_assert_pass`, and
  `interp_while_true`/`_false`; and (sessions -13/-14) the kernel identities
  `writeBlock_parse`/`relay_parse`/`readBlock_parse` of the exported token lists with the stated
  ASTs, the WHOLE-body theorems `write_block_body_ret`/`_neg`/`_assert*_raises`,
  `read_block_body_ret`/`_neg`, the loop theorems `relay_inner_step`/`_lost`/`_step_inv`/
  `_loop_run`/`_loop_terminates`, `relay_outer_step`/`_loop_run`/`_loop_terminates`,
  `relay_prologue`/`relay_terminates`, and the general simulation theorem `interp_fuel_mono` —
  all hold for every input, not just the ones exercised. See "Exact remaining theorem
  obligations" (sessions -13/-14 section) for what this does NOT cover: the OCaml program
  itself, the lowering, type soundness of the calculus as a language, the text->token glue.
- EMPIRICAL: 1,593 same-input matches (re-verified session -11 with a strict, full-state,
  case-set-checked comparator — see "Session -11") plus 4 byte-list mutants and 5 structural
  mutants is measurement, not proof, of the pipeline as a whole — strong evidence `RVal.rpair`/
  the byte-list transcription are RIGHT, not a substitute for the proved theorems above.
- NOT ESTABLISHED: any theorem about the OCaml program; any Bash-level claim; any Coq/Lean
  import; that 1,593 matches generalize beyond the two corpora used (`cases_curated.tsv`,
  `cases_phase3_standard.tsv`) or beyond `relay`/`nested_state.sc`/`finite_ints.sc` specifically;
  any of the five items in "Exact remaining theorem obligations" above.

## Reproduce

```sh
# 1. Lean side (host, under the shared lock)
L=~/.cache/bash-spec-pilot/phase5-integration-lean
cp integration/lean/*.lean integration/lean/lakefile.toml integration/lean/lean-toolchain $L/
cd $L && LEAN_NUM_THREADS=1 LEAN_STACK_SIZE_KB=16384 \
  flock ~/.cache/bash-spec-pilot/phase3-compiler.lock timeout 300s prlimit --as=3221225472 lake build
lake env lean -j1 -s16384 -DElab.async=false CalculusExportAxioms.lean

# 2. OCaml side: set up a FRESH PRIVATE, correctly-versioned build (NOT the shared calculus-bytes
#    original, which is stale — see Trust boundary above). Repeat-safe: creates a new uniquely
#    named staging directory every run, prints it, verifies patch/source hashes. Requires the
#    shared compiler lock only for the final `dune build` (run separately, printed by the script):
STAGE=$(./research/libc-specs/phase5/calculus-correspondence/setup_private_build.sh)
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-correspondence-privatebuild-NEW \
  --seconds 120 --workdir "$STAGE" -- \
  dune build --profile release ./bash-verifier/calculus_bytes/cb_main.exe --display short

# 3. Re-lower (fresh exports; NEVER reuse a prior session's export_input__*.tsv without redoing
#    this against whichever build you're about to compare against)
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-correspondence-lower-NEW \
  --seconds 120 --workdir "$STAGE" -- \
  ./_build/default/bash-verifier/calculus_bytes/cb_main.exe lower \
  fixtures/v2/nested_state.sc fixtures/v2/finite_ints.sc fixtures/byte_relay_exec.sc fixtures/byte_relay_exec_typed.sc

# 4. compare-run (Lean) / cb_main run (OCaml, same private build) / strict diff
$L/.lake/build/bin/compare-run relay calculus-correspondence/results/export_input__byte_relay_exec.tsv \
  < calculus-bytes/results/cases_curated.tsv > calculus-correspondence/results/compare_lean_relay.jsonl
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-correspondence-relay-run-NEW \
  --seconds 60 --workdir "$STAGE" -- \
  ./_build/default/bash-verifier/calculus_bytes/cb_main.exe run fixtures/byte_relay_exec.sc relay cases/cases_curated.tsv
# copy that run's .log to calculus-correspondence/results/compare_ocaml_relay.jsonl, then:
python3 calculus-correspondence/compare_relay.py relay
python3 calculus-correspondence/tests/test_compare_relay.py   # meta-tests: does the comparator itself work
```

## Remaining work (ordered)

1. **The five items in "Exact remaining theorem obligations"** (above) — this is the actual
   critical path to a "general correspondence" claim; everything else in this list is secondary.
2. **Reconcile the shared container**: report the missing `interp_element_path.patch` and the
   stale (pre-v2) `bytes_builtin.ml`/`lower.ml`/`cb_main.ml` at `/home/coq/phase5/calculus-bytes`
   to whoever owns that build, or get explicit authorization to update the shared copy from the
   private one sessions 10/11 validated (1,593/1,593). Until then, ANY other worker reading
   `/home/coq/phase5/calculus-bytes` directly is silently on the old build.
3. **Extend the phase3-scale (953-case) sweep to `nested_state.sc`/`finite_ints.sc`**: they now
   have the full 20-case `cases_curated.tsv` comparison (session -11), but nothing at
   `cases_phase3_standard.tsv`'s scale.
4. **`and`/`or` (raw, non-short-circuit)**: `fixtures/v2/short_circuit.sc` is still rejected AT
   LOWERING by the OCaml adapter itself (an OCaml-side gap, not Lean-side); report upstream
   alongside `integration/COMPLETION-AUDIT.md`'s other pinned frontend defects.
5. **Frozen automation task** (`COMPLETION-AUDIT.md` item 9(c)): zero LLM pass@k attempts exist
   for the calculus-program-from-spec-text task; none added this session — out of scope for a
   proof/interpreter-repair session, and the orchestrator explicitly said not to start new LLM
   evaluation trials. This is a DIFFERENT, narrower thing than the (separately tracked, already
   completed) `evaluation-expanded`/`evaluation-finalize-8` program — see `REQUIREMENTS.md`; do
   not read "zero attempts for this specific frozen task" as "the evaluation program is
   incomplete", which it is not.
