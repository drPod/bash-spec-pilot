# Byte-bearing execution in the pinned State Calculus interpreter

Close two gaps relative to [../integration](../integration): (1) byte-bearing execution in the pinned `Calculus.Interp` compared with the phase3 pointer machine and the checked Coq relay evaluator; (2) a source path `spec text → pinned lexer/parser → Frontend.Ast.Parsed → bounded lowering → Calculus.Ast → pinned interpreter`, with fragment [MAPPING.md](MAPPING.md). This is not a Bash parser, a theorem about OCaml code, or an end-to-end verification claim.

**Finding (local v1).** After a private `state.ml` nested-mutator patch: **2006/2006** positive records agree with the phase3 reference; 7/7 mutants detected; Coq `BytesOracle.v` 90 Examples closed under the global context. v2 adapter: **2046/2046** byte-relay records still agree; 60/60 `check_v2.py` lowering outcomes; 11/11 Lean nested-state structural comparisons.

Unmodified pinned source fails every case (`results/interp_prepatch/`). No theorem mentions the OCaml interpreter or lowering. Spec-language fragment excludes enums/match, for loops, structs, strings, casts and typed integer widths. Nested elements deeper than one level were not exercised in v1.

Date: 2026-09-07.

## Identities

| Item | Value |
|---|---|
| Pinned upstream | `counc009/state_based`, branch `bash`, commit `190dd8491b258d8a0ee29f79629908540236b332`, tree `292a37c9848e8f9a1cc679a8c3f1e28dfcffd116` |
| Private build | Integration tree (five OCaml-4.13 shims, `--profile release`, vendored `stdint` 0.7.2) plus `bash-verifier/calculus_bytes/` and named patches. `results/private-build-tree.sha256` lists the tree **before** the state patch (pinned `state.ml` `9b735498…`); `interp.ml` sha256 `a7a390e7572279f18527c4de250b19a012bad77f060e6c356cd79f6a9b06cfc6` and `ast.ml` `01d85f13…` unchanged throughout v1 |
| Patches | (1) `adapter/state_concrete_nested.patch` on `lib/calculus/state.ml` (`9b735498…` → `abf32195…`); (2) `adapter/lexer_suffix.patch` on `lib/frontend/lexer.mll` (`0fbeb343…` → `d0d9fa6b…`) |
| Executable source | `fixtures/byte_relay_exec.sc` (9 fns, 7 root attributes, 1 element, 1 exception, 11 table-mapped uninterpreted functions) |
| Builtin instance | `adapter/bytes_builtin.ml` (trusted boundary; table in MAPPING.md) |
| Oracles | phase3 `validation/ptrcheck/pointer_model.run_pointer_machine`; `coq/BytesOracle.v` over `../relay/Evaluator.v` |
| Container | shared `phase5-vst` (OCaml 4.13.1, dune 3.21.1, Coq 8.20.1); source dir `/home/coq/phase5/calculus-bytes`; runs via `../run_vst.py` |

`byte_relay_plain.sc` remains a parse fixture, not a faithful relay (raises `ReadError` instead of returning 1, etc.). The lowering rejects it (`struct 'buffer' is outside the fragment`, receipt `calculus-bytes-lower-1`). `byte_relay_exec.sc` maps frozen C relay statuses: read error → 1 with delivered bytes retained, EOF → 0, write ret ≤ 0 → 2 with unwritten suffix appended to `lost`.

Comparison fields: status, delivered, unread, lost/pending, read/write call counts, and `block(0)` (`cap = 32`, `len = |bytes| ≤ 32`).

## Results

| Step | Receipt | Result |
|---|---|---|
| Build | `calculus-bytes-dune-build-2` | exit 0 (build-1 failed on a type error) |
| Lowering of 10 files | `calculus-bytes-lower-1` | `byte_relay_exec.sc` lowered (9 fns); 5 negatives + `byte_relay_plain.sc`, `pinned_filesys.sc`, `shell_fragment.sc` rejected; `byte_relay.sc` hits pinned lexer `Uint64.of_string` crash |
| Interpreter, unpatched `state.ml` | `calculus-bytes-interp-positive-1`, `-mutants-1` | **every case `Failure`**; kept in `results/interp_prepatch/` |
| Interpreter, patched | `-interp-positive-2`, `-mutants-2` | `results/interp/` |
| Comparison (host) | `compare_bytes.py` → `results/compare_summary.json` | **2006/2006** agree; 7/7 mutants detected |
| Coq oracle | `calculus-bytes-oracle-coqc-1` (exit 0, 3.71 s, 508,528 KiB) | 60 positive + 30 mutant `Example`s accepted by Coq 8.20.1 |
| Assumption audit | `calculus-bytes-oracle-audit-1` | 90/90 “Closed under the global context” |
| Lexer patch | `calculus-bytes-dune-build-4-lexerpatch`, `calculus-bytes-lower-2-lexerpatch` | `byte_relay.sc` lexes then lowering rejects `struct`; `byte_relay_exec_typed.sc` same MD5 as plain fixture for all 9 fns; 40 curated records agree |

Curated observations include late read error after full delivery, zero write with pending loss, NUL/255, all 256 byte values, offset short writes, and `relay ; relay` matching Coq `pending_lost_then_fresh_relay`.

## Pinned defect (private patch only)

`ConcreteState.set_attr`, `pos_elem`, `neg_elem` (`lib/calculus/state.ml` lines 123–151 at the pinned commit) return the nested state as the new whole state on a `Nested` path, discarding the enclosing state. `RandomizeState.locate` rebuilds the parent correctly; the patch does the same for concrete state. Evidence: all `Failure` before, 2006/2006 after.

## Checked vs empirical vs trusted

- **Kernel-checked (Coq 8.20.1):** `BytesOracle.v` observations equal/differ from the proved-sound relay evaluator (`eval_sound` ↔ `RelayReach.outcome`).
- **Empirical:** 2006 (v1) / 2046 (v2) interpreter vs phase3; mutant detection; lowering accept/reject on 10 files.
- **Trusted:** builtin instance; lowering as spec-language semantics; pinned OCaml; `state.ml` patch as intended semantics; schedule lists identified with protocol `action`; phase3 Python reference.
- Lean remains an independent reference ([../integration/PROOF-CHAIN.md](../integration/PROOF-CHAIN.md), link 4).

## Replay

```sh
python3 research/libc-specs/phase5/calculus-bytes/make_fixtures.py
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-bytes-dune-build-NEW --seconds 600 --workdir /home/coq/phase5/calculus-bytes -- dune build --profile release ./bash-verifier/calculus_bytes/cb_main.exe --display short
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-bytes-interp-NEW --seconds 300 --workdir /home/coq/phase5/calculus-bytes -- ./_build/default/bash-verifier/calculus_bytes/cb_main.exe run fixtures/byte_relay_exec.sc relay cases/cases_curated.tsv
python3 research/libc-specs/phase5/calculus-bytes/compare_bytes.py
python3 research/libc-specs/phase5/calculus-bytes/make_coq_oracle.py
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-bytes-oracle-coqc-NEW --seconds 600 --workdir /home/coq/phase5/calculus-bytes/coq -- coqc -Q /home/coq/phase5/relay "" BytesOracle.v
```

## v2 update (same day)

v1 record above remains accurate for `adapter/v1/` and the original byte-relay fixtures. v2 (`adapter/lower.ml`) replaced untyped, both-sides-evaluated, single-level-nesting semantics. See [MAPPING.md](MAPPING.md) “v1 vs v2”.

- Real short-circuit of `&&`/`||`; explicit 63-bit trapping integer carrier; static typing / lexical block scoping. `check_v2.py`: 60/60. `compare_bytes.py` vs v2 adapter: 2046/2046, 7/7 mutants (`mut_bad_byte` now caught at lowering; receipt `calculus-resume3-baseline-1`, exit code 4 both times).
- Depth ≥2 paths also need `interp_element_path.patch`. Evidence: `results/nested_before_after.json`, `results/v2_prepath/`, `results/v2_build4_unpatched/`. With both patches, `fixtures/v2/nested_state.sc` executes on all 7 functions.
- Lean `CalculusNested.lean`: frame lemmas `setAttrAt_same`/`setAttrAt_frame`/`addElemAt_attrs`/`removeElemAt_here_frame`/`and_skips_rhs`/`or_skips_rhs`; axiom audit `results/v2/nested_lean_axioms.txt`: 11 theorems on `propext`/`Quot.sound`. `compare_lean_v2.py`: 11/11 structural agreement on hand-transcribed programs. Not extraction from OCaml; byte-list builtins, `Match`/`ForEach`/`ForElem`/`Localize`/`Yield`, randomized state, and state-reference element keys remain untranscribed in that comparison.
