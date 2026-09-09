# Calculus correspondence

Replace hand-transcribed finite examples with a mechanical `parser → lowerer → export → Lean-checked-parse → Lean-checked-run` path over the pinned OCaml compiler’s S-expression printer, including byte-bearing state, negative controls on real exported ASTs, a large same-input OCaml-vs-Lean comparison, and general theorems about the exported `write_block`/`read_block`/`relay` bodies.

**Finding (local stage).** Under a private correctly-versioned OCaml build and a strict full-state comparator: **1,593/1,593** same-input matches. Lean theorems identify exported token lists with statement ASTs and relate `relay` to the phase3 `BufferRelay` model (`relay_matches_phase3`). Later whole-program status (tokenizer117, parser135, source197, packaging) is in [../FINAL-DELIVERY.md](../FINAL-DELIVERY.md), not in this directory’s session record.

Empirical matches are not a theorem about OCaml source. Trusted: `Lower.show_stmt`, the adapter lowerer, `funcDef` defined to match `bytes_builtin.ml`. Shared container path `/home/coq/phase5/calculus-bytes` was a stale pre-v2 build at the time of these numbers; comparisons used a **private** staging tree (`setup_private_build.sh`).

Date: 2026-09-08. Job chain historically labeled calculus-correspondence-4 through -18, -61, -75, -79.

## Same-input comparison (strict comparator, session -11)

Session -10 found the container `cb_main.exe` running a pre-v2 `bytes_builtin.ml` (no overflow trap) and unpatched `interp.ml` `Element` path order. Session -11 found comparator bugs (duplicate names, OCaml-keys-only iteration, empty corpus as 0/0, incomplete state fields). Numbers below use the rewritten `compare_relay.py` (old version kept as `compare_relay_v1.py`) and eleven meta-tests in `tests/test_compare_relay.py`.

| Corpus | Cases | Result |
|---|---|---|
| `relay` + 4 siblings, `cases_curated.tsv` | 5 × 20 = 100 | 100/100 |
| `relay`, `cases_phase3_standard.tsv` | 953 | 953/953 |
| `nested_state.sc` 7 functions, `cases_curated.tsv` | 7 × 20 = 140 | 140/140 |
| `finite_ints.sc` 20 functions, `cases_curated.tsv` | 20 × 20 = 400 | 400/400 |
| **Total** | **1,593** | **1,593/1,593** |

Earlier -10 total 1,080/1,080 used a single trivial case for nested/finite corpora and is superseded as a count, not as a fabrication of the relay 20/20.

Byte-list mutants of real exports: `mut_single_out_of_range` → `failure`; `mut_unsupported_byte_func` → `parse_rejected`; `mut_negative_take_count` and `mut_length_of_nonlist` break previously successful cases.

## Kernel-checked identities and body theorems

Token lists of current `write_block`, `relay` and `read_block` entries of `results/export_input__byte_relay_exec.tsv` (sha256 `5b3af9ea…c25a281`). `writeBlock_parse` / `relay_parse` / `readBlock_parse` prove `CalculusExport.parseStmt` maps those tokens to the stated bodies. Text → tokens (`CalculusExport.tokenize`, `partial`) is executable glue: receipts print `(true, true)` for `tokenize text == toks`.

Whole-body theorems (`CalculusBody.lean`, `CalculusRelayOuter.lean`), ∀ over fuel/environment/state under explicit well-formed-block, byte-valued lists, `range:` premises and counter headroom:

- `write_block_body_ret` / `_neg` / `write_block_assert{1,2,3}_raises`
- `read_block_body_ret` / `_neg`
- `relay_inner_step`, `relay_inner_lost`, `InnerInv`, `relay_inner_loop_run` / `_terminates` (fuel `2·(r-off)+30`)
- `OuterInv`, `relay_outer_loop_run` / `_terminates` (fuel `2·|input| + 2·cap + 37`)
- `relay_terminates`: `runEntry` status in `{0,1,2}` at fuel `2·|input| + 108`
- `interp_fuel_mono` — **not** general `Stmt.WF` preservation
- `writeBlockBody_WF` / `readBlockBody_WF` / `relayBody_WF` and round-trips

Axioms: `propext`, `Classical.choice`, `Quot.sound` or a subset; zero `sorryAx`.

`relay_matches_phase3` (`CalculusRelaySpec.lean`): from `CompareMain.initialState`, `runEntry actDef (fuel + 2·|inp| + 110) "relay"` matches `BufferRelay.run` on status, `delivered`/`input`/`lost`/`read_calls`/`write_calls`. Premise: `|inp| + 1 ≤ maxInt`.

`tokenizeTotal` / `parseText`: kernel-checked on a ~200-character fragment; `decide +kernel` on full `writeBlockText` (1,300 characters) did not finish in 15 minutes. Later full-export identities: [lean/CalculusTokenize-EXPORT-ACCEPTANCE.md](../integration/lean/CalculusTokenize-EXPORT-ACCEPTANCE.md) (root117).

## Typing, lowering, guards (sessions -61, -75, -79)

`preservation`: well-typed statement/environment/state ⇒ continue/raise/ret with well-shaped state, **or `.failure`**. Range safety is not claimed.

`lowering_checked`: Lean re-implementation of `lower.ml` on `byteRelayExecSpec` equals the nine exported bodies. Later `exportedSpec_eq_hand` (axiom-free) and `exported_lowers` (`propext`) after machine `print_ast.ml` + `sexp_to_lean.py` (raw export 33 declarations, 4,579 bytes, sha256 `3f687ca1…`). Trusted executables: printer and generator.

`write_block_guard_gate` / `write_block_guarded`: five range/assert facts derived; imported invariants remain. `read_block` guards sit **after** bookkeeping writes. `relay_caught_of_ret` / `_readError` / `_other` / `_failure`. Whole-body `relay_raising` was open here; later raising151 — [CalculusRelayRaising-ACCEPTANCE.md](../integration/lean/CalculusRelayRaising-ACCEPTANCE.md).

## Trust boundary

- TRUSTED: `cb_main.exe` serialization; adapter lowerer vs intended source semantics.
- CHECKED: parser/render round-trips; body/loop theorems; `relay_matches_phase3`; typing preservation (failure allowed); machine AST equality for this fixture.
- EMPIRICAL: 1,593 matches + mutants.
- NOT ESTABLISHED here: OCaml-source theorems; Bash; Coq/Lean import; generalization beyond the two corpora.

Private build: `setup_private_build.sh` → `calculus-correspondence11-<UTC>-<pid>`. Patched `interp.ml` sha256 prefix `e41d6227…`.

## Reproduce

```sh
L=~/.cache/bash-spec-pilot/phase5-integration-lean
cp integration/lean/*.lean integration/lean/lakefile.toml integration/lean/lean-toolchain $L/
cd $L && LEAN_NUM_THREADS=1 LEAN_STACK_SIZE_KB=16384 \
  flock ~/.cache/bash-spec-pilot/phase3-compiler.lock timeout 300s prlimit --as=3221225472 lake build
lake env lean -j1 -s16384 -DElab.async=false CalculusExportAxioms.lean

STAGE=$(./research/libc-specs/phase5/calculus-correspondence/setup_private_build.sh)
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-correspondence-privatebuild-NEW \
  --seconds 120 --workdir "$STAGE" -- \
  dune build --profile release ./bash-verifier/calculus_bytes/cb_main.exe --display short

uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-correspondence-lower-NEW \
  --seconds 120 --workdir "$STAGE" -- \
  ./_build/default/bash-verifier/calculus_bytes/cb_main.exe lower \
  fixtures/v2/nested_state.sc fixtures/v2/finite_ints.sc fixtures/byte_relay_exec.sc fixtures/byte_relay_exec_typed.sc

$L/.lake/build/bin/compare-run relay calculus-correspondence/results/export_input__byte_relay_exec.tsv \
  < calculus-bytes/results/cases_curated.tsv > calculus-correspondence/results/compare_lean_relay.jsonl
uv run --no-project python research/libc-specs/phase5/run_vst.py --name calculus-correspondence-relay-run-NEW \
  --seconds 60 --workdir "$STAGE" -- \
  ./_build/default/bash-verifier/calculus_bytes/cb_main.exe run fixtures/byte_relay_exec.sc relay cases/cases_curated.tsv
python3 calculus-correspondence/compare_relay.py relay
python3 calculus-correspondence/tests/test_compare_relay.py
```

## Historical session map (not current whole-program status)

| Session | Result kept |
|---|---|
| -8 | `CalculusExport` first `lake build` (22/22); `splitFirstColon` |
| -9 | Eleven byte-list primitives; `RVal.rpair`; relay 20/20 (narrower than later totals) |
| -10 | Stale container build diagnosed; private patched tree; then 1,080/1,080 before comparator fix |
| -11 | Comparator rewrite; **1,593/1,593**; `write_block_prefix_binds` (pattern later not matching ranged export) |
| -12 | Ranged prefix theorems; one-step `while` lemmas |
| -13/-14 | Whole bodies, loops, `relay_terminates`; inner/outer root audits |
| -15 | `relay_matches_phase3`; `tokenizeTotal`; `interp_pure_state` |
| -61 | Typing preservation; hand `byteRelayExecSpec` |
| -75 | Machine AST; write_block guards |
| -79 | Guarded inner loop; read_block post-bookkeeping guards; try/catch lemmas |

`export-run` on 46 functions from empty state: 0 `parse_rejected`, 15 `continue`, 31 `failure` (5 overflow/div-zero, 2 missing-parent, 18 byte-relay functions needing real initial state).
