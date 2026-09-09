> Final delivery closure (release212, audit213, catalog215): required work is complete at the documented research bounds. See [FINAL-DELIVERY.md](FINAL-DELIVERY.md). Historical pending-package statements below describe the frozen pre-release snapshot.

# Completion audit

Reconcile [REQUIREMENTS.md](REQUIREMENTS.md), [evaluation/DRAFT-PAPER.md](evaluation/DRAFT-PAPER.md), [integration/PROOF-CHAIN.md](integration/PROOF-CHAIN.md) and [integration/COMPLETION-AUDIT.md](integration/COMPLETION-AUDIT.md) against checker receipts. First compiled 2026-09-08 (research-consolidation-8/9). Status labels: **PROVED** (named checker accepted a named file/theorem, receipt cited — always bounded); **INCOMPLETE** (partial evidence, sub-parts open); **UNVERIFIED** (no checker receipt); **CONTRADICTED** (later receipt overturns an earlier claim). No row is complete in an absolute sense.

**Current prototype.** Bounded source connection accepted at root197; full30 replay174 terminal; UTF-8 negative; evaluation 23/90 scored. Packaging closed in [FINAL-DELIVERY.md](FINAL-DELIVERY.md). This audit does not expand theorem claims.

File/checker receipts establish acceptance. OpenScience/Atlas records are indexes by content hash, not a second acceptance mechanism.

## Per-requirement ledger

Rows match the “Completion evidence” table in [REQUIREMENTS.md](REQUIREMENTS.md).

| # | Requirement | Status | Evidence (exact) | Missing / open |
|---|---|---|---|---|
| 1 | Existing-library reuse decision | BOUNDED REUSE ACCEPTED | `Body.body_relay` (`relay-body-coqc-16`); GNU `body_safe_read`/`body_simple_cat`/`body_safe_write`/`body_full_write` (closed in 24-file `gnu_vsu_utility_reuse_chain_replay`); `body_head_bytes` (`case6-s-HeadBytesBody`); `body_wc_lines` (`case9-wc55-WcLinesBody`). Both extra utilities reuse `IOW.SafeRead` for reading. Head write uses explicit stdio `XWrite`/`xwrite_stdout_spec`, **not** `IOW.FullWrite` | Measured transfer: relay’s four leaf functions plus two GNU utilities on the **read** side; head write required a new contract — evidence about reuse limits, not a gap to hide |
| 2 | Trustworthy C representation | PROVED (bounded) | `relay.v` (CompCert 3.15 `clightgen -normalize`, Coq-accepted); hashes in `phase5/relay/frontend-results.json` | AST-hash identity only; CompCert parser/elaborator is trusted (PROOF-CHAIN link 1) |
| 3 | Byte-bearing memory and I/O | PROVED UNDER EXPLICIT CONTRACTS | `adequacy/Dry.v`; `Safety.v` `relay_dry_safety` under `Jsub`; **`PH5-RELAY-007`/`008`** + `UniversalShell.v` (Jsub-free) | `Trace.v` timeout **superseded**; no mandatory redo. `Jsub` remains on the safety family only |
| 4 | Nonvacuity and progress | PROVED (bounded), distinguished | Witness `PH5-RELAY-007` vs universal `PH5-RELAY-008` (both Jsub-free); `Progress.v` `outcome_exists` is a weaker abstract statement | Universal bounded to the scheduled-environment model |
| 5 | Source-as-specification | PROVED (bounded hand-authored contracts and wrapper link) | `cat_true_copies_all`, `HeadOutcome`, `WcLinesShort`, `XWrite_effect`; CaseTransfer/CaseTransferWc; `case-transfer-finish-44/ROOT-ASSUMPTION-AUDIT.json` | Hand-authored contracts, not automatic C-text extraction. Source-as-spec can preserve source bugs |
| 6 | Independent correctness calibration | PROVED negative (closed, bounded) | `calibration/RESULTS.md`: 1,190,417 baseline cases + 5 directed; frozen gnulib UTF-8; stop-rule | C conformance and gettext caller-transfer not established |
| 7 | Reuse beyond purpose-built relay | BOUNDED BODY/WRAPPER/TRANSPORT ACCEPTED | AllVSU of 4 TUs (not GNU `main`). Utility13: full POST + `iow_juicy_dry_specs` (`ROOT-JUICY-DRY-AUDIT`, **15** replay, **13** identities). Embed-read: `ROOT-EMBED-READ-AUDIT` (**4** replay, **2** identities). Utility14: PRE transport + dry PRE + dry POST chaining under fresh errno `mem_cell_ext` (`utility-transport-audit-31`; `ROOT-FULL27-RECEIPT-AUDIT.json` 27/27) | **Not** whole linked main / `funspec_sub` / juicy reverse to Relay_Espec. No FullWrite-on-stdio required |
| 8 | Frontend / general calculus correspondence | INCOMPLETE (local stages accepted) | write_block/read_block/outer-loop; calc15; calc67; Shared70; root74 typing; root77 AST identity; root82 guards; 1,593 same-input comparisons (empirical) | Root87/92 command/query; root89 guards; tokenizer117; harness133; raising151/147. Type preservation permits failure. Machine export does not verify OCaml source |
| 9 | Shell/query connection | BOUNDED; PARSER CONNECTION BOUNDED | `shell-bridge/` 44; `Compose.v` `parse_program3_sound` 31 audit. Fd24 finite live-table gating. Stateful55 (`root-schedule-repair-55/ROOT-FINAL-RECEIPT.json`). Parser135 (`root-shell-parser-review-135/ROOT-REVIEW.json`): 38 fixtures | Completeness/compound redirect **not** original minimum (`scope-audit-correction-23`). No independent character-level lexer, host-Bash equivalence, full Bash, or query-text parser. Coq `Parse.v` does not feed `encodeCmd` |
| 10 | Final proof-assistant boundary | BOUNDED LEAN-FINAL + SOURCE CONNECTION 197 | Original notes: Lean proves supported script behavior matches its query through the state calculus (`organization/ORIGINAL-USER-SCOPE.md`). Coq-final accepted separately | Calc67, Shared70, root87/92, parser135, raising151/147. Audit179 empirical-only bar preserved. Root197: `relay_clight_execute` / `clight_calculus_initialState` / `clight_calculus_shared`. TCB: clightgen/Python dump/reviewed Lean Clight subset/libc. Fresh196 accepted203 (`run20260908T224120Z`, 18 modules, 18 named assumption reports, 17 fixtures, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`) |
| 11 | Automation improvement | BOUNDED EVALUATION COMPLETE | See evaluation accounting | Protocol deviation (a6 ran 6 model calls vs stated 3 extra) preserved; helper ablation ineffective for `claude:fable`; n=30/model; no human baseline |
| 12 | Paper contribution and artifact | Historical row said packaging incomplete | Manifest **30**; full30 `run20260908T213227Z` summary `165a63d40cdf862605142d368c61a057a3571e4ae9d29f6c81e1b95b2f347aee`; frozen full27 historical at121; paper206 | **Current packaging:** [FINAL-DELIVERY.md](FINAL-DELIVERY.md). Do not treat historical “no final tar” as current |

## Evaluation accounting (`evaluation-accounting-7`)

Authoritative inspection of the 96-row `attempts.jsonl`:

| Set | Outcome |
|---|---|
| Original 90 (indices 0–4) | 22 accepted / 59 build failed / 6 timeout-no-block (all sonnet, ~150s wall, 0 chars) / 3 checker-collision (`attempt directory already exists` — real model calls with exit 0 and a Lean block) |
| Makeup a5 (3 attempts) | 1 accepted (fable) / 2 build failed |
| Denominators | **22/90** (collisions as non-accepts) **or** **23/90** (collisions replaced by a5). Do not report “93/96 first-pass” as a preregistered matrix |
| Assisted a6 | Protocol specified 3 extra calls; jsonl shows 3 cells × 2 rounds = **6** process calls, all final results build-failed. Disclosed protocol deviation |
| Collaborative | 3 runs, agent-assisted, not human, not in `attempts.jsonl`: 1 accepted / 2 build failed |
| `results.json` | `total_attempts=96` / `sum(accepted)=23` folds a5+a6 into per-cell rates; not a preregistered 90-cell first-pass table |

`evaluation-finalize-6` exited 1 with no REPORT; successor `evaluation-accounting-7` is terminal. Original evaluation records were not rewritten.

## Organization / catalog (historical snapshots)

| Snapshot | Count | Note |
|---|---|---|
| `organization-validate-7` GET 2026-09-08T06:02:05Z | 2,242 nodes / 2,348 edges; 0 orphan edges; 0/2,178 intended labels missing | Inventory-row coverage only |
| Independent full-file hash (same job) | 1,437/1,444 content-hash nodes match; **7 differ** | Label coverage ≠ current-state synchronization |
| `organization-milestones-27` | 274/274 retrieved, all private | FILE receipts remain authoritative |
| Catalog205 (pre-release) | Atlas **307** private; local **2379** / **2436** | Dated |
| Delivery catalog215 | Atlas **308**; OpenScience **2380** / **2436** | [FINAL-DELIVERY.md](FINAL-DELIVERY.md) |

## Distinguishing axes

- **Universal vs Jsub/witness.** `PH5-RELAY-008` and `PH5-RELAY-007` are Jsub-free; `relay_dry_safety` still carries `Jsub`. The universal result is a separate theorem, not a strengthening of `Safety.v`.
- **AllVSU vs GNU main.** `linkVSUs` over 4 TUs is not a `main`/argv-parsing/complete-binary proof.
- **Coq/Lean/OCaml.** No checked import either direction. OCaml is executable-only; empirical comparison 1,593/1,593 (correspondence corpus) and 2,086/2,086 + 14/14 mutants (artifact-replay corpus).

## Historical corrections (research-consolidation-9)

Reading errors in the first pass, fixed in the table above rather than by contradicting addenda: (1) `body_full_write` is accepted, not a current failure; (2) `head_bytes` write is `XWrite`, not FullWrite reuse; (3) caching disabled is an unimplemented provenance check, not architectural impossibility; (4) functional-consequence lemmas exist for row 5.

This audit did not invent GNU `main`, FullWrite-on-stdio, an import-tool mandate, or a `Trace.v` redo.
