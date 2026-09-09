# Byte-bearing execution in the pinned State Calculus interpreter, from parsed source

Worker: Claude (calculus-bytes), 2026-09-07. Owns this directory and `../integration`.
Nothing here is a Bash parser, a theorem about OCaml code, or an end-to-end verification claim.
The objective stays the original one (Aaron's spec language / State Calculus frontend for the
relay-style utility fragment); this directory closes two gaps left by `../integration`:

1. **Byte-bearing execution in the REAL pinned `Calculus.Interp`**: explicit byte values 0..255,
   a block-indexed buffer element `block(0)` with `cap`/`len`/`bytes`, `input`/`delivered` streams,
   read/write schedules, call counters, a `lost` ledger, partial effects on error, and fresh
   invocation state, all compared against the phase3 reference pointer machine and the checked
   Coq relay evaluator.
2. **An actual source path** `spec text -> pinned lexer/parser -> Frontend.Ast.Parsed -> NEW bounded
   lowering (adapter/lower.ml) -> Calculus.Ast -> pinned interpreter`, with an explicit supported
   fragment (`MAPPING.md`), negative fixtures, and no hand-built calculus programs.

## Identities

| Item | Value |
|---|---|
| Pinned upstream | `counc009/state_based`, branch `bash`, commit `190dd8491b258d8a0ee29f79629908540236b332`, tree `292a37c9848e8f9a1cc679a8c3f1e28dfcffd116` |
| Private build tree | copy of the integration worker's tree (its five OCaml-4.13 shims, `--profile release`, vendored `stdint` 0.7.2), plus `bash-verifier/calculus_bytes/` (this worker) and ONE new semantic patch (below). `results/private-build-tree.sha256` lists the tree BEFORE the patch (pinned `state.ml` `9b735498…`); `interp.ml` sha256 `a7a390e7572279f18527c4de250b19a012bad77f060e6c356cd79f6a9b06cfc6` and `ast.ml` `01d85f13…` are unchanged throughout |
| New patches | (1) `adapter/state_concrete_nested.patch` on `lib/calculus/state.ml` (pinned sha256 `9b735498…bddde` -> patched `abf32195…1df8`), three hunks, semantic, see "Pinned defect found by execution"; (2) `adapter/lexer_suffix.patch` on `lib/frontend/lexer.mll` (pinned `0fbeb343…1162` -> patched `d0d9fa6b…d951`), strips the type suffix before `Stdint.*.of_string` in the 32 suffixed-literal rules (the integration worker's reported lexer crash); built from `calculus-bytes-dune-build-4-lexerpatch` on |
| Executable source | `fixtures/byte_relay_exec.sc` (parsed by the pinned parser: 9 fns, 7 root attributes, 1 element, 1 exception, 11 table-mapped uninterpreted functions) |
| Lowered calculus | printed as S-expressions with MD5 in the first record of every `results/interp/*.jsonl` (`"mode": "lower"`) |
| Builtin instance | `adapter/bytes_builtin.ml` (worker code, trusted boundary; table in `MAPPING.md`) |
| Oracles | phase3 `validation/ptrcheck/pointer_model.run_pointer_machine` (host Python; the independently checked phase3 reference), and `coq/BytesOracle.v` over `../relay/Evaluator.v` (`RelayEvaluator.eval`, proved sound/complete w.r.t. `RelayReach.outcome`) |
| Container | shared `phase5-vst` (OCaml 4.13.1, dune 3.21.1, Coq 8.20.1); source dir `/home/coq/phase5/calculus-bytes`; all runs via `../run_vst.py`, receipts `~/agent-jobs/astra-research/phase5/runs/calculus-bytes-*.{json,log}` |

## The executable relay spec is NOT `../integration/fixtures/byte_relay_plain.sc`

`byte_relay_plain.sc` stays as the old *parse* fixture. It is not a faithful relay: it raises
`ReadError` instead of returning 1, returns 1 on write failure instead of 2, and leaves
`read_chunk`/`take` uninterpreted. The lowering rejects it explicitly (`struct 'buffer' is
outside the fragment`, receipt `calculus-bytes-lower-1`). `fixtures/byte_relay_exec.sc` is the
separately named executable version with the status/effect mapping of the frozen C relay
(`../../phase2/relay.c` through `../relay/Protocol.v`/`Reach.v`): read error -> 1 with delivered
bytes retained, EOF -> 0, write ret <= 0 -> 2 with the unwritten suffix appended to `lost`.
Its `relay_raising`/`relay_caught` pair shows the calculus exception path carrying partial
effects (the pinned `Raise` result retains state; `TryCatch` resumes with it) and is shown
equal to `relay` on every case.

**Target label.** Every post-patch result below is about *the pinned interpreter (`interp.ml`,
`ast.ml`, `value.ml` unchanged) with the named private state patch
`adapter/state_concrete_nested.patch`* (and, from `-dune-build-4-lexerpatch` on, the pinned
lexer with `adapter/lexer_suffix.patch`; the lexer patch does not affect the plain-literal
fixtures, whose lowered programs are byte-identical before and after). The unmodified pinned source does NOT satisfy these
comparisons: with it every case is `Failure` (`results/interp_prepatch/`, receipts
`calculus-bytes-interp-positive-1`, `-mutants-1`). Comparison fields: status, delivered bytes,
unread bytes, lost/pending bytes, read and write call counts, and the `block(0)` element
(`cap = 32`, `len = |bytes| <= 32`); a record agrees only if all of them do.

## Results (all from receipts; container runs `calculus-bytes-*`)

| Step | Receipt | Result |
|---|---|---|
| Build (my type error) | `calculus-bytes-dune-build-1` | fail (fixed) |
| Build | `calculus-bytes-dune-build-2` | exit 0 |
| Lowering of 10 files | `calculus-bytes-lower-1` | `byte_relay_exec.sc` lowered (9 fns); 5 negative fixtures + `byte_relay_plain.sc`, `pinned_filesys.sc`, `shell_fragment.sc` rejected with position and reason; `byte_relay.sc` still hits the pinned lexer `Uint64.of_string` crash |
| Interpreter, unpatched state.ml | `calculus-bytes-interp-positive-1`, `-mutants-1` | **every case `Failure`** (see defect below); kept in `results/interp_prepatch/` |
| Build with state patch | `calculus-bytes-dune-build-3-statepatch` | exit 0 |
| Interpreter, patched | `calculus-bytes-interp-positive-2`, `-mutants-2` | outputs in `results/interp/` |
| Comparison (host) | `compare_bytes.py` -> `results/compare_summary.json` | **2006/2006 positive records agree** with the phase3 reference: entries `relay`, `relay_caught`, `relay_seq_relay`, `relay_and_mark`, `relay_or_mark` on 20 curated cases each, and `relay`, `relay_caught` on all 953 non-reject cases of the phase3 standard corpus; every agreeing record also has exactly one `block(0)` with `cap = 32` and `len = |bytes| <= 32`. 7/7 mutants detected |
| Coq oracle | `calculus-bytes-oracle-coqc-1` (exit 0, 3.71 s, 508,528 KiB) | `coq/BytesOracle.v`: 60 positive `Example`s (`observe w = <OCaml values>` by `vm_compute; reflexivity`: 20 `relay`, 20 `relay_caught`, 20 `relay ; relay` via `observe2`) and 30 mutant `Example`s (`observe w <> <mutant values>`, `discriminate`) all accepted by Coq 8.20.1 |
| Assumption audit | `calculus-bytes-oracle-audit-1` (exit 0, 12.11 s) | `Print Assumptions` on all 90 Examples: 90/90 "Closed under the global context" (`results/oracle-audit-1.log`) |
| Lexer patch regression | `calculus-bytes-dune-build-4-lexerpatch`, `calculus-bytes-lower-2-lexerpatch` | failing-before: `byte_relay.sc` (`0u64`) -> `Uint64.of_string` crash in `-lower-1`; passing-after: it lexes and parses (then the lowering rejects its `struct`, as expected), and `fixtures/byte_relay_exec_typed.sc` (same program with `32u64`, `0u64`, `0i64`, `1i64`, `33u8`) lexes, lowers to calculus programs with the same MD5 as the plain fixture for all 9 fns, and its 40 curated records (`relay`, `relay_and_mark`) agree with the reference (`compare_bytes.py`) |

Curated observations (each a row in `results/interp/curated_relay.jsonl`, all matching the
reference): late read error after full delivery (`abc`, reads `[3;-1]`: status 1, delivered
`abc`, 2 reads / 1 write); zero write with pending loss (`abcdef`, reads `[4]`, writes `[2;0]`:
status 2, delivered `ab`, unread `ef`, lost `cd`); NUL and 255 (`00 ff 0a 21` preserved);
all 256 byte values forward and reversed with single-byte writes; write error / zero write in
the third chunk (pending 27 bytes); non-full reads (`r31`, `r1,2,3`); offset short writes
(`w16,15`, eight `w1`); read error first (with and without input); over-requests clamped.
Fresh invocation state: `relay ; relay` on `abcdef`/`[4]`/`[2;0]` gives status 0, delivered
`abef`, lost `cd`, byte total conserved, exactly the Coq `Shell.v` witness
(`pending_lost_then_fresh_relay`).

Negative controls (`results/compare_summary.json`, `mutants`): wrong offset (`off+1`): 16/20
differ; requesting the uninitialized region: 8/20 raise `AssertionFailure` from the
source-level assert, and without the assert the `slice` builtin's range check makes the pinned
interpreter `Failure` on the same 8; byte 256 in `mark`: `Failure` on the 10 cases that reach
`mark`; swapped statuses 1/2: 10/20 differ; zero-write retry: 4/20 differ; no fresh
`block(0)`: `Failure` on all 20.

## Pinned defect found by execution (not fixed upstream; private patch only)

`ConcreteState.set_attr`, `pos_elem`, `neg_elem` (`lib/calculus/state.ml` lines 123-151 at the
pinned commit) return the *nested* state as the new whole state when the path is
`Nested(elem, v, n)`: the enclosing state (root attributes, sibling elements) is discarded, so
the next root access fails. `get_attr`/`check_elem` are unaffected. `RandomizeState.locate`
rebuilds the parent correctly, which is what the patch does for the concrete state (fold the
updated nested state back with `ElemMap.add`). Evidence: identical fixtures and cases, all
`Failure` before (`-interp-positive-1`) and 2006/2006 agreeing after (`-interp-positive-2`).
The integration/shell-bridge fixtures never wrote a nested attribute, so they did not hit it.
Together with the lexer (`0u64` -> `Uint64.of_string` crash) and pretty-printer findings of
`../integration/README.md`, this is to be reported upstream when a channel is authorized.

## Which links are checked, empirical, or trusted

- **Kernel-checked (Coq 8.20.1):** `BytesOracle.v` — the OCaml observations for the curated
  cases equal the values of the proved-sound relay evaluator, and the mutant observations differ.
  The evaluator's soundness (`eval_sound`) ties them to `RelayReach.outcome`, the same predicate
  the VST body theorem (`../relay/Body.v`) establishes for the generated Clight relay.
- **Empirical (finite observations):** pinned-interpreter output vs phase3 Python reference on
  2006 records; mutant detection; lowering acceptance/rejection on 10 files.
- **Trusted:** the builtin instance; the lowering as a semantics for the spec language (there is
  no upstream semantics to check against); the pinned OCaml code itself (no theorem about it);
  the `state.ml` patch as the intended semantics; the identification of source-level `reads`/
  `writes` schedule lists with the protocol's `action`; the phase3 reference implementation.
- Lean phase3/phase5 artifacts are not touched and remain the independent reference model
  (`../integration/PROOF-CHAIN.md`, link 4); nothing imports across assistants.

## Replay (repository root, container idle, fresh run names)

```sh
# 1. fixtures, mutants, case files (host)
python3 research/libc-specs/phase5/calculus-bytes/make_fixtures.py
# 2. build tree: integration worker's private tree + adapter/ + state patch -> /home/coq/phase5/calculus-bytes
#    (this worker used tar | docker exec -u coq; the tree hashes are results/private-build-tree.sha256)
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-bytes-dune-build-NEW --seconds 600 --workdir /home/coq/phase5/calculus-bytes -- dune build --profile release ./bash-verifier/calculus_bytes/cb_main.exe --display short
# 3. lowering + interpreter (curated and phase3 cases, all entries, mutants): commands as recorded in the receipts
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-bytes-interp-NEW --seconds 300 --workdir /home/coq/phase5/calculus-bytes -- ./_build/default/bash-verifier/calculus_bytes/cb_main.exe run fixtures/byte_relay_exec.sc relay cases/cases_curated.tsv
# 4. compare and regenerate the Coq oracle (host), then check it in the container
python3 research/libc-specs/phase5/calculus-bytes/compare_bytes.py
python3 research/libc-specs/phase5/calculus-bytes/make_coq_oracle.py
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-bytes-oracle-coqc-NEW --seconds 600 --workdir /home/coq/phase5/calculus-bytes/coq -- coqc -Q /home/coq/phase5/relay "" BytesOracle.v
```

## Not established

No Bash text is parsed here (the bounded shell-text frontend is `../shell-bridge`, in Coq).
No theorem mentions the OCaml interpreter or the lowering. The spec-language fragment excludes
enums/match, for loops, structs, strings, casts and typed integer widths; the old fixtures that
use them are rejected, not executed. The 1-argument `block(0)` is the only element; nested
elements deeper than one level were not exercised (the pinned `Element` path order for deeper
nesting was not examined). `mark` assumes a successful one-byte write, as in `Shell.v`.

## v2 update (calculus-resume-2/3, same day): typed lowering, deep nesting, Lean correspondence

Everything above is the original (v1) worker's record and is still accurate for
`adapter/v1/` and the byte-relay fixtures it drove. Two follow-up workers
(calculus-resume-2, calculus-resume-3) found and fixed real gaps in that v1 fragment rather
than only adding more relay examples; see `MAPPING.md`'s "v1 vs v2" section for the exact
before/after semantics and `fixtures/v2/`/`check_v2.py`/`compare_bytes.py`/
`compare_lean_v2.py` for the evidence:

- **Real short-circuit** (`&&`/`||` skip the right operand's effects/traps, not just its
  prefix-rejection), **explicit finite-integer semantics** (a stated 63-bit carrier with
  trapping `+ - * neg`, truncating `/` `%`, and static range checks on declared narrower
  widths — not "unbounded OCaml ints"), and **static typing / lexical block scoping** replace
  v1's untyped, both-sides-evaluated, redeclaration-only-rejected fragment. `check_v2.py`:
  60/60 lowering outcomes (values + rejection messages) match by construction; `compare_bytes.py`
  (re-run against the v2 adapter): 2046/2046 byte-relay records still agree, 7/7 mutants still
  detected (one, `mut_bad_byte`, is now caught statically at lowering instead of at runtime —
  confirmed reproducible via a fresh container build, receipt `calculus-resume3-baseline-1`,
  exit code 4 both times).
- **Two more pinned defects, found the same way as the first** (execution, not code reading):
  `state_concrete_nested.patch` alone is not enough for depth->=2 paths; `interp.ml`'s `Element`
  constructor also needs `interp_element_path.patch` (path order). Before/after evidence for
  both patches together: `results/nested_before_after.json`, `results/v2_prepath/`,
  `results/v2_build4_unpatched/`. With both patches, `fixtures/v2/nested_state.sc` (element
  nesting through `set_attr`/`pos_elem`/`neg_elem`, locals bound mid-path, parent/sibling
  preservation) executes as expected on all 7 of its functions.
- **A Lean interpreter correspondence beyond the general fragment**: `../integration/lean/
  CalculusNested.lean` transcribes the patched nested-state semantics (`Get`/`Add` on nested
  `QualAttr`/`QualPosE`/`QualNegE`, `While`, `TryCatch`/`TryFinally`/`Raise`, the v2 checked-
  integer builtins) and proves, for the transcription (not the OCaml source): `setAttrAt_same`/
  `setAttrAt_frame` (writing an attribute at a path changes nothing else — parent attributes,
  sibling elements, unrelated subtrees), `addElemAt_attrs` (touching an element changes no
  attribute anywhere), `removeElemAt_here_frame` (clearing an element preserves the root's
  attributes and every other sibling), and `and_skips_rhs`/`or_skips_rhs` (the general
  short-circuit lowering pattern really skips the right operand). Lean 4.31.0, host build under
  the shared compiler lock, `-DwarningAsError=true`; axiom audit
  (`results/v2/nested_lean_axioms.txt`): all 11 theorems depend only on `propext`/`Quot.sound`,
  no `sorryAx`. Then, for 11 concrete hand-transcribed programs (from the exact lowered
  S-expressions `cb_main lower` printed — `missing_parent`, `wrong_order_probe`, `deep_set`,
  `deep3` (3 levels deep, exercising `contains`/`hasElemAt` and a `clear`+re-`touch`),
  `deep_clear` (the one program here that itself calls another via `Action`: `deep_clear`
  invokes `deep_set`, exercising the actual action-call interpreter case, not just its
  callees run standalone), `cleared_then_read` (a `Get` on a removed element, which must fail),
  and, from `fixtures/v2/scope_ok.sc`, `catch_scope`, `finally_runs`, `uncaught_is_raise`,
  `partial_effects_survive_raise`, `loop_let`), `compare_lean_v2.py` runs the Lean
  transcription (`nested-json` exe) and the ACTUAL patched pinned OCaml interpreter and checks
  structural agreement on outcome / return value / raised value / every attribute / the full
  element subtree at every depth: 11/11 agree, 0 mismatches.
- **Still not established**: this is 11 hand-picked programs and a handful of general frame
  lemmas about the Lean transcription, not a lowering-to-Lean pipeline, not a claim that the
  transcription is extracted from or checked against the OCaml source by any tool, and not a
  theorem about the OCaml program. Byte-list builtins, `Match`/`ForEach`/`ForElem`/`Localize`/
  `Yield`, the randomized state, and state references used as element keys remain untranscribed
  in Lean. No Bash text path and no Coq/Lean import are claimed here either.
