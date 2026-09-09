> Final delivery closure (release212, audit213, catalog215): all required work is complete at the documented research bounds. See [final delivery receipt](FINAL-DELIVERY.md). Historical pending-package statements below describe the frozen pre-release snapshot.

# Completion audit — research-consolidation-8/9

First compiled 2026-09-08T09:35:30-09:42:49Z (actual `process.json`/`exit.json` timestamps for
`research-consolidation-8`; that job's own REPORT.md estimated "~40 minutes,
09:20Z-09:42Z" from prose, which is wrong — actual wall time was ~7.3 minutes. This paragraph
is the correction; `research-consolidation-8/REPORT.md` itself is left unedited as a historical
record of what was believed at the time). Corrected in place 2026-09-08 by
`research-consolidation-9` after root/orchestrator review found several source-reading errors
in the first pass (see "Corrections applied by research-consolidation-9" below) — those errors
are fixed directly in the rows below, not merely appended as a contradicting addendum.

Predecessor `research-consolidation-6` made zero tool calls before an immediate account
rate-limit exit — `claude-resume/research-consolidation-6/exit.json` exit_code 1, only a
`system init` + `rate_limit_event` in `events.jsonl`; nothing from it to reconcile. This audit
is read-only research synthesis: no proofs, evaluation data, organization graph, or Atlas
records were touched. It reconciles `REQUIREMENTS.md`, `evaluation/DRAFT-PAPER.md`,
`integration/PROOF-CHAIN.md`, `integration/COMPLETION-AUDIT.md`,
`organization/{COVERAGE-GAPS,REQUIREMENTS-CROSSWALK,CURRENT-EVIDENCE.json}` (all last written
2026-09-07/early 2026-09-08 and now stale in places) against direct receipts and the
authoritative timelines in `research-consolidation-{8,9}/FROM-ORCHESTRATOR.md` and the two
named predecessor Pi's own output
(`pi-reviews/{organization-validate-7,evaluation-accounting-7}`).

**Current reconciliation: full30-174/183 + original-source-link-audit-179 (historical gap) + root197 bounded source connection.** Earlier utility, case-wrapper, stateful, calculus, typing, export and command/query/guard acceptances remain valid at their named receipts. Six full-export tokenizer identities are accepted117 (16 fresh modules). **Harness133 accepted:** universal copied tokenizer equality, corrected default CLI, saved 1,593 replay and 12 negatives (`root-tokenizer-harness-review-133/ROOT-REVIEW.json`). **Parser135 accepted:** supported Lean text parser, independent TOKEN-grammar soundness, Nested command/query connector under explicit premises, 38/38 fixtures (`root-shell-parser-review-135/ROOT-REVIEW.json`); not character-lexer grammar, host-Bash equivalence, full Bash, completeness, or query-text. **Raising151 accepted** (`root-raising-seven-review-151/ROOT-REVIEW.json`): actual raising/caught `initialState` exact status + seven root fields vs BufferRelay; explicit actDefs/headroom/fuel; raisedReadError(-1) maps ordinary 1, catch restores 1. **147 accepted:** actual general-`st` same-post entry/catch. Scope-audit-152: no arbitrary-Related raising mandate. Historical 131/138/146 are not active pending-proof claims. Shared exception170 and shell173 accepted; private 162/164 no longer pending. **Current shared manifest 30.** Full30 replay174 terminal exit 0 (`run20260908T213227Z`, summary `165a63d40cdf862605142d368c61a057a3571e4ae9d29f6c81e1b95b2f347aee`): 29 PASS + 1 experimental host-OCaml skip, container PASS, fresh true, nofilter. Root183 accepted the artifact replay; independent177 passed; root receipt recheck passed. Full30 does **not** include source197 or supplementals. Frozen full27 remains **historical** 121. Supplemental188 accepted; fresh198 (`run20260908T223418Z`, summary `a8528873723704287780d6973e53957bfd97ec3139e21580dcd3d81d94e3c781`): 23 fresh modules, 9 named axiom reports; not full30. Caches remain off. The OCaml source frontend remains an explicit trusted boundary, not a newly invented generic importer task. Audit179's bar against empirical-only discharge is preserved. Root197 **accepts** the bounded generated-`fRelay`→`BufferRelay`→Nested initial/shared script-atom connection under explicit TCB (clightgen / Python dump / reviewed Lean Clight subset / libc contracts); **not** CompCert `step*` / Vundef / full Bash. Historical `lost` is ghost; current pending is memory. Independent195 reviewed cp17 (`a5c689e54bd9ca8f04743c59815524fe2ed2bd85ad6071e1770b359fb7cef876`); root promoted cp18/cp19/cp20 after delta/hash review. `ClightRelayLink` src `cc02a88c4ec8ddadb2344d8df77c04bebbbad8390af3d70bac4aeb3542fdc467` log `4fb77cff3dcd89e2e3895b33b05cdbd7b6faee2e48937f3cf244fc5ca743764d`. Fresh196 accepted203 (`run20260908T224120Z`, 18 modules, 18 axioms, 17 fixtures, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`); Claude200 original-requirement matrix terminal (no mandated proof gaps; 9 TCB boundaries). Goal is not packaging-only. Evaluation stays frozen (93 first-pass / 90 scored / 23 accepts; no new trials). Paper206 reviewed/rendered (source b515b98b… HTML 0f8135f…); do not edit paper. Research is not complete.

Status labels: **PROVED** (a named checker accepted a named file/theorem, receipt cited) —
always bounded, see "Missing" column; **INCOMPLETE** (real partial evidence, explicit
sub-parts open); **UNVERIFIED** (claimed somewhere but this audit found no checker receipt);
**CONTRADICTED** (a later receipt overturns an earlier claim still sitting in a document).
No row is marked complete in an absolute sense — `REQUIREMENTS.md`'s own framing governs.

## Per-requirement ledger (rows match `REQUIREMENTS.md`'s "Completion evidence" table)

| # | Requirement | Status | Evidence (exact) | Missing / open |
|---|---|---|---|---|
| 1 | Existing-library reuse decision | BOUNDED REUSE DECISION AND EVIDENCE ACCEPTED | `Body.body_relay` (`relay-body-coqc-16`); GNU `body_safe_read`/`body_simple_cat`/`body_safe_write`/**`body_full_write`** (`utility-resume2-replay-FullWriteBody`, exit 0 — CORRECTED, see below) all closed and in the fresh 24-file `gnu_vsu_utility_reuse_chain_replay`; case-studies **`body_head_bytes`** (`case6-s-HeadBytesBody`, exit 0)/**`body_wc_lines`** (`case9-wc55-WcLinesBody`, exit 0, independently verified `ROOT-WC-VERIFICATION.json`) reuse `IOW.SafeRead` unchanged for reading. **Precision correction**: `head_bytes`'s write side does NOT reuse `IOW.FullWrite`. `case-studies/coq/CaseWorld.v` records that the case-studies4 model originally built `XWrite` on `IOW.FullWrite`, and `case-proofs-6` deliberately REPLACED that with a new, explicit stdio contract `XWrite`/`xwrite_stdout_spec` (buffered-`fwrite` semantics), specifically because the two write disciplines are not the same contract — do not describe head's write path as an `IOW.FullWrite` reuse | Cross-utility *measured* transfer is real for the relay's own 4 leaf functions (`safe_read`/`safe_write`/`full_write`/`simple_cat`, all closed) plus 2 further GNU utilities (head, wc) reusing only the READ side unchanged; the write side of a *second* real utility (head) required a NEW contract, not a transferred one — that is itself useful evidence about reuse limits, not a gap to hide |
| 2 | Trustworthy C representation | PROVED (bounded) | `relay.v` (CompCert 3.15 `clightgen -normalize`, Coq-accepted); source/tool hashes recorded (`phase5/relay/frontend-results.json`) | AST-hash identity only; no functional source theorem; CompCert's own parser/elaborator is a trusted, uncertified boundary (link 1, `PROOF-CHAIN.md`) |
| 3 | Byte-bearing memory and I/O | PROVED UNDER EXPLICIT CONTRACTS | `adequacy/Dry.v`; `Safety.v` `relay_dry_safety` under `Jsub`; **`PH5-RELAY-007`/`008`** + accepted `UniversalShell.v` (Jsub-free) | Named `Trace.v` timeout is **superseded** by universal returned-outcome / `UniversalShell`; **no mandatory redo** of `Trace.v`. `Jsub` remains on the safety family only |
| 4 | Nonvacuity and progress | PROVED (bounded), distinguished | **Witness** (`PH5-RELAY-007`, existential — one execution per world) vs **Universal** (`PH5-RELAY-008`, bounded-∀ over all permitted executions, both for `relay_main.prog` and `relay_exit.prog`, plus `UniversalShell.v`) — both Jsub-free per `organization/REQUIREMENTS-CROSSWALK.md`; `Progress.v` `outcome_exists` (`relay-progress-coqc-5`) is the earlier *abstract* progress statement, a third, weaker thing again | Universal is bounded to the stated scheduled-environment model; termination against a non-scheduled/host-OS environment is out of scope by construction, not proved absent |
| 5 | Source-as-specification | PROVED (bounded hand-authored contracts and wrapper link) | Functional consequences `cat_true_copies_all`, `HeadOutcome`, `WcLinesShort`, and `XWrite_effect`; selected-function VST bodies establish the stated contracts under explicit imports. CaseTransfer/CaseTransferWc lift accepted callee bodies and prove wrappers under the same extended Gprog. `case-transfer-finish-44/ROOT-ASSUMPTION-AUDIT.json` verifies four source identities and both fresh root51 audit receipts; four lemmas print standard VST assumptions only. | These are hand-authored contracts, not automatic C-text extraction. REQUIREMENTS found **no independent mandate for an automatic extractor**; absence of that separate artifact is a boundary, not an added requirement. Source-as-spec can preserve source bugs. |
| 6 | Independent correctness calibration | PROVED negative (closed, bounded) | `calibration/RESULTS.md`: 1,190,417 baseline cases + 5 directed; frozen gnulib UTF-8 source; worker stopped by its own stop-rule | C conformance and gettext caller-transfer explicitly not established; this is preserved as a stated negative result, per `REQUIREMENTS.md` line 27/54 — do not silently re-extend it |
| 7 | Reuse beyond purpose-built relay | BOUNDED BODY/WRAPPER/TRANSPORT RESULTS ACCEPTED | AllVSU of 4 TUs (not GNU `main`). **Accepted type (utility13):** full POST + `iow_juicy_dry_specs` + memory evolution — `ROOT-JUICY-DRY-AUDIT` (**15** replay, **13** source identities). **Accepted type (embed-read):** ghost/dry reverse + assertion-level **read PRE** — `ROOT-EMBED-READ-AUDIT` (**4** replay, **2** identities: `EmbedBridge.v`/`EmbedPre.v`). Head/wc source bodies + functional POST accepted; export-wrapper link now checked by CaseTransfer/CaseTransferWc: accepted callee bodies lifted and wrapper bodies proved under a common extended Gprog | **Accepted utility14** (`utility-transport-audit-31` `REVIEW.md`/`VALIDATION.json`; `ROOT-FULL27-RECEIPT-AUDIT.json` 27/27 status+timing 0, hash_matches true): PRE transport + dry PRE + dry POST chaining under fresh errno `mem_cell_ext`. **Not** whole linked main / `funspec_sub` / juicy reverse to Relay_Espec. No FullWrite-on-stdio required |
| 8 | Aaron's frontend integration / general calculus correspondence | INCOMPLETE | Accepted: actual write_block/read_block/outer-loop proofs; calc15 output, calc67 residual schedules, Shared70 arbitrary related seven-field state; root74 general type preservation and nine-body checked lowering; root77 machine-produced parser AST identity; root82 actual write_block guard consequences. 1,593 same-input canonical comparisons remain empirical evidence. | Root87 accepts command composition/headroom; Root92 accepts the bounded query compiler and exported mark identity. Root89 accepts inner-relay/read_block guard integration and conditional catch behavior (15 new audits plus4 dependencies). All six full-export token/AST identities are accepted117. Harness133 accepts universal copy equality and the actual corrected CLI on 1,593 + 12 negatives. Raising151/147 accept documented raising/caught exact status+seven-field initialState and general-st same-post; no arbitrary-Related raising mandate. Type preservation permits failure. Machine export does not verify OCaml parser/lower/interpreter source. |
| 9 | Shell/query connection | BOUNDED MODELS ACCEPTED; PARSER CONNECTION BOUNDED | `shell-bridge/` 44; `Compose.v` `parse_program3_sound` 31 audit; modelled file-store redirect fragment. Audit22 **too aggressive** (`scope-audit-correction-23`): completeness/compound redirect **not** original minimum; **numeric fd** was an original obligation, now met for the accepted finite fd24 fragment. Host OS/full Bash not required | **Fd24 accepted** finite live-table gating/freshness/bidirectional adequacy (`shell-calculus-audit-30`). **Not** OS. **Stateful55 accepted** (`root-schedule-repair-55/ROOT-FINAL-RECEIPT.json`): three source identities and 18 standard-Lean assumption outputs checked; composition consumes residual input and read/write schedules, including read-error recovery and empty-path failure. This is a Lean reference-composition result, **not** a checked C/Coq-to-Lean bridge. Root87/92 accept the bounded actual-calculus command/query proof. Audit108's Lean text-to-Command-to-encodeCmd gap is now bounded by **parser135** (`root-shell-parser-review-135/ROOT-REVIEW.json`): supported text parser, independent TOKEN-grammar soundness, Nested connector under explicit premises, 38 fixtures. Coq Parse.v still does not itself feed encodeCmd. Do not invent NL/query-text parser or generic Coq importer obligations. Remaining 135 limits: no independent character-level lexer grammar, no host-Bash semantic equivalence, no full Bash/completeness/query-text claim. |
| 10 | Final proof-assistant boundary | BOUNDED LEAN-FINAL THEOREM ACCEPTED; BOUNDED SOURCE-TO-CALCULUS CONNECTION ACCEPTED197 UNDER EXPLICIT TCB | Original user notes require Lean to prove supported script behavior matches its query through the actual state calculus (`organization/ORIGINAL-USER-SCOPE.md`). Coq-final subchain is accepted separately; no generic Coq importer was mandated. | **Calc67 accepted** (`root-calculus-schedules-67/ROOT-REVIEW.json`): general outer-loop exactness and fresh-state `runEntry`, under explicit actDef identities/counter headroom, preserve all seven fields, including actual residual `reads`/`writes`; the drop corollary uses actual call counts. Eleven dependency modules and four standard-Lean assumption outputs were independently reviewed. **Shared70 accepted** (`root-calculus-shared-70/ROOT-REVIEW.json`): actual relay body/action/runEntry on arbitrary related seven-field state and caller environment, under explicit cumulative counter headroom. Root87 accepts actual-calculus command encoding, derived cumulative headroom and structural fuel (11 audited theorems); root92 accepts the bounded query AST compiler and actual exported mark identity (17 query audits plus one axiom-free equality). Query text parsing and exact-byte query expressions remain outside this bounded claim. Stateful55 reference composition/replay69 is accepted; the bounded actual calculus-to-stateful script/query connection is accepted87/92. Audit108's parser connection is now bounded by parser135 as in row 9. Utility-source/OCaml/cross-kernel trust boundaries remain explicit; statement alignment alone does not complete the requirement. Raising151/147 accept documented raising/caught original-scope proofs (`root-raising-seven-review-151/ROOT-REVIEW.json`, `root-raising-entry-review-147/ROOT-REVIEW.json`). Historical 132/139/131/138/146 remain labeled historical, not active pending proofs. No arbitrary-Related raising theorem. **Audit179** (historical): no user authorization to accept empirical Coq/Lean agreement as done — that bar is preserved, not narrowed. **Root197** accepts bounded `relay_clight_execute` / `clight_calculus_initialState` / `clight_calculus_shared` after independent195+cp18/19/20 hash review. TCB: clightgen/Python dump/reviewed Lean Clight subset/libc contracts. Not CompCert step*/Vundef/full Bash. Fresh196 accepted203 (`run20260908T224120Z`, 18 modules, 18 axioms, 17 fixtures, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`); Claude200 original-requirement matrix terminal (no mandated proof gaps; 9 TCB boundaries). Supplemental188/198 (23 modules, 9 axioms) separately from full30. OCaml-source/cross-kernel trust remain explicit. |
| 11 | Automation improvement (evaluation) | BOUNDED EVALUATION COMPLETE; general-improvement claim unsupported | See "Evaluation accounting" section below — do not collapse to a single number | Protocol deviation (a6 ran 6 model calls vs the stated "3 extra") preserved, not silently corrected; helper ablation ineffective specifically for `claude:fable`; n=30/model; no human baseline |
| 12 | Paper contribution and artifact | INCOMPLETE (bounded source connection accepted197; package-202 no final tar; packaging is not completion) | Current shared manifest **30**. Full30 replay174 terminal exit 0 (`run20260908T213227Z`, summary `165a63d40cdf862605142d368c61a057a3571e4ae9d29f6c81e1b95b2f347aee`): 29 PASS + 1 experimental host skip; container OCaml PASS; fresh true, nofilter. Root183 accepted; independent177 passed (root receipt recheck passed). Full30 excludes source197/supplementals. Shared exception170 and shell173 accepted; private 162/164 no longer pending. Frozen full27 historical at121: 26 PASS plus one experimental host skip; container OCaml PASS. Frozen evaluation (93 first-pass / 90 scored / 23 accepts; no new trials) and older archives unchanged; caching off. Paper206 reviewed/rendered (source b515b98b… HTML 0f8135f…); do not edit paper. | Independent177 passed; root receipt recheck passed. Supplemental175 accepted188, separately from full30. **Bounded source connection accepted197** under explicit TCB; 179 empirical-only bar preserved. Fresh196 accepted203 (`run20260908T224120Z`, 18 modules, 18 axioms, 17 fixtures, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`); Claude200 original-requirement matrix terminal (no mandated proof gaps; 9 TCB boundaries). Compiler serialization is in the accepted runner. Trusted OCaml/C/cross-kernel boundaries remain; no CompCert-step* or full-Bash claim. Do not mark complete. |

## Evaluation accounting (do not use a single number — `evaluation-accounting-7` is authoritative)

Per `pi-reviews/evaluation-accounting-7/{ACCOUNTING.json,ANALYSIS.md,REPORT.md}`, itself
terminal exit 0 and directly inspecting the 96-row `attempts.jsonl`:

- **Original 90** (attempt indices 0-4): 22 accepted / 59 build failed / 6 timeout-no-block
  (all sonnet, ~150s wall, 0 chars) / 3 checker-collision (`attempt directory already exists`
  — these ARE real model calls with exit 0 and a found Lean block; grok/sonnet/fable a0, the
  checker just refused to rescore into a reused scratch dir). **90 actual model-call attempts,
  not 87.**
- **Makeup a5** (3 new attempts backfilling the 3 collisions): 1 accepted (fable) / 2 build
  failed (grok, sonnet).
- **Two legitimate denominators, state both, never collapse to one:** 22/90 (collisions
  scored as non-accepts, as recorded) **or** 23/90 (collisions replaced by their a5 makeup).
  Do not report "93/96 first-pass" as if it were one preregistered matrix.
- **Assisted a6**: protocol specified 3 extra calls; actual jsonl shows 3 cells × 2 rounds =
  **6 model process calls**, all 3 final results build-failed. This is a **disclosed protocol
  deviation** — do not rerun to "fix" it and do not report it as compliant with the 3-call
  design.
- **Collaborative** (3 runs, agent-assisted, NOT human, not in `attempts.jsonl`): 1 accepted /
  2 build failed.
- `results.json`'s `total_attempts=96`/`sum(accepted)=23` folds a5+a6 into per-cell rates; it
  is not a preregistered 90-cell first-pass table and should not be quoted as one without this
  context.
- `evaluation-finalize-6` itself exited 1 with no REPORT/NEXT; its own `evaluation-accounting-7`
  successor is the terminal, authoritative accounting — cite that job, not finalize-6.
- No new makeup/assisted/collaborative calls are needed or authorized; the remaining work is
  accurate disclosure (done here) and prompt-hash null recovery from the stored exact prompts
  where possible (not attempted in this audit; flagged as remaining work below). Original
  evaluation records (attempts.jsonl, results.json) are untouched by this or the prior audit
  session; 23/90 (makeup-substituted) and 22/90 (original) are both disclosed, neither is
  treated as sole.

## Organization / OpenScience / Atlas state

- `organization-validate-7` (exit 0): finished an interrupted inventory import — 311 missing
  `job_dir_file` labels POSTed, 0 failed. Final GET 2026-09-08T06:02:05Z: **2,242 nodes / 2,348
  edges, 0 orphan edges, 0/2,178 intended labels missing**. This is **inventory-row coverage
  only** — org-validate-7's own REPORT.md explicitly disclaims "all research organization
  complete."
- Independent full-file hash follow-up (same job, `root-fullhash-check.json`): of 1,444
  content-hash-bearing nodes, **1,437 match current bytes; 7 differ** (older catalog/artifact
  versions, 3 ORCHESTRATION versions, evaluation `attempts.jsonl` post-snapshot trials,
  `evaluation-finalize-6/FROM-ORCHESTRATOR`). Label *coverage* is complete for the frozen
  inventory; current-state *synchronization* is not — those 7 must not be advertised as
  current matches.
- Later same day (`organization-current-evidence-8`, `organization-milestones-12`): graph grew
  further (historical snapshots). **Historical hosted Atlas snapshot:** `organization-milestones-27`
  `ROOT-VERIFICATION.json`: **274/274** retrieved, **all private**, hash_matches on sampled
  new nodes. Local last worker report: **2346** nodes / **112** claims. **FILE receipts remain
  authoritative**; Atlas is catalog only.
- No API calls in refresh-29.

## Distinguishing axes this audit was specifically asked to preserve

- **Universal vs Jsub/witness**: see row 4. `PH5-RELAY-008` (universal) and `PH5-RELAY-007`
  (witness) are both Jsub-free; `relay_dry_safety` (row 3) is a *different, weaker* theorem
  family that still carries the `Jsub` premise. Do not describe the universal result as having
  "removed Jsub from safety" — it is a separate theorem, not a strengthening of `Safety.v`.
- **AllVSU linking vs complete GNU main**: see row 7. `linkVSUs` over 4 TUs is real and
  fresh-replayed; it is not a `main`/argv-parsing/complete-binary proof for any GNU coreutils
  program.
- **FILE-accepted vs external delivery**: the checked artifacts are the `.v`/`.lean` files and
  their compiler receipts (`coqc`/`lean` exit 0, `Print Assumptions`/`#print axioms` output)
  living in this repository and the container job dirs. OpenScience/Atlas records are indexes
  *of* those files (by content hash), not a second acceptance mechanism.
- **Coq/Lean/OCaml trust boundaries**: Coq-final is the single-kernel arrangement for the
  central relay→shell sentence (row 10). Lean is an independent reference model with no
  checked import either direction. OCaml (`interp.ml`, the pinned calculus interpreter) is
  executable-only everywhere it appears (rows 8, 12); no extraction or source-level proof
  connects it to either kernel — only empirical same-input comparison (1,593/1,593 for the
  correspondence corpus, 2,086/2,086 + 14/14 mutants for the artifact-replay corpus).

## Ledger vs other documents

`REQUIREMENTS.md`, `evaluation/DRAFT-PAPER.md`, and `integration/PROOF-CHAIN.md` tables were
rewritten in place by `current-ledger-reconcile-18` to match the receipts in this audit
(no contradictory addenda). Organization files are **not** owned here.

**Historical (corrected in the four owned docs; listed so they are not re-applied):**

1. Early `REQUIREMENTS.md` tables claimed universal termination still missing, head/wc
   bodies absent, artifact chains future work, and only a `write_block` 3-assignment prefix.
2. `DRAFT-PAPER.md` once cited "9 entries"; later last full=17 + two targeted while full19
   ran. **Historical.** Then-current: full-19 passed **plus** two targeted (manifest21). Current accounting is in row12.
3. Evaluation must state **both** 22/90 original and 23/90 scored (90 scheduled / 93 first-pass
   with 3 makeup / 90 scored). No new trials.

**Still outside these four files (organization workers):**
`organization/COVERAGE-GAPS.md` `PH5-CASE-001` / `PH5-SHELL-004` and
`organization/REQUIREMENTS-CROSSWALK.md` evaluation singular 22/90 — those files remain
stale if unedited by their owners. Do not invent `wc_lines_null_spec` or full GNU CLI as
new original-plan requirements.

## Corrections applied by research-consolidation-9 (self-corrections to this file's first pass)

The first pass of this audit (`research-consolidation-8`) made three source-reading errors,
found by root/orchestrator review and fixed in place above, not by appending a contradicting
note:

1. **Row 1 read a historical failure paragraph as current.** `utility-reuse/RESULTS.md`
   describes a Pi attempt (`pi-utility-direct-FullWriteBody-1`) that failed at `split3`, then
   (same file, "How `body_full_write` was closed") the actual fix that closed it. The first
   pass cited only the failure and missed the fix two paragraphs later. `body_full_write` is
   accepted (`utility-resume2-replay-FullWriteBody`, exit 0) and is one of the 24 files in the
   fresh `gnu_vsu_utility_reuse_chain_replay`.
2. **Row 1 also overstated `head_bytes`'s reuse.** It reuses `IOW.SafeRead` unchanged but its
   write side uses a NEW contract (`XWrite`/`xwrite_stdout_spec`), not `IOW.FullWrite` —
   `case-studies/coq/CaseWorld.v`'s own header records this as a deliberate replacement, not
   an oversight to paper over.
3. **Row 12 misdiagnosed why caching is disabled** (called it architecturally impossible; it
   is an unimplemented-correctly provenance check) **and understated replay coverage of the
   Coq-to-shell composition** (`ShellExit.v`/`UniversalShell.v` already replay it fresh).
   Coq↔Lean currently has **no checked import** (empirical only); that is **not** a claim
   the link is mathematically impossible.
4. **Row 5** asserted a source-summary theorem was "never attempted" without checking for
   partial evidence; real functional-consequence lemmas exist and are now cited, with the
   distinction (hand-authored vs. mechanically source-derived) stated. The later scope audit found no independent automatic-extractor mandate; row5 now treats that as a boundary rather than an invented requirement.
5. **This file's own header timing was an estimate**, not the actual `process.json`/
   `exit.json` timestamps; corrected at the top of this file.

No proof, evaluation, or organization file was touched to make these corrections — all four
are reading errors in this consolidation job's own prose, fixed against evidence that was
already cited correctly elsewhere in the same first-pass document (e.g. row 7's linking
evidence already correctly named the 24-file chain `body_full_write` sits in).

## What this audit did NOT do (remaining work for the next worker)

- Did not mark any research goal complete.
- Does not accept current Claude61 / tokenizer_verify work without independent receipts.
- Historical: this file previously listed utility14/calc15/shell24 as unaccepted; **updated in place** by milestone-consolidation-32 against Pi 30/31 + ROOT-FULL27.
- Did not run compiler, API, evaluation trials, or commits.
- Did not invent GNU `main`, FullWrite-on-stdio, named import-tool mandate, or Trace.v redo.

Current work allocation: original proofs at documented scope accepted (including raising151/147). Harness133, parser135, tokenizer158, shared exception170, shell173 accepted. Current shared manifest **30**; full30-174 terminal (root183 accepted; independent177 passed (root receipt recheck passed); 29 PASS + 1 host skip / container PASS; not including new source/supplementals). Frozen full27 historical 121. Private 162/164 no longer pending. Supplemental188 + fresh198: 23 modules, 9 axioms, not full30. Bounded source connection accepted197 under explicit TCB; fresh196 accepted203 (`run20260908T224120Z`, 18 modules, 18 axioms, 17 fixtures, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`); Claude200 original-requirement matrix terminal (no mandated proof gaps; 9 TCB boundaries). Catalog205: Atlas **307** private, local OpenScience **2379** nodes / **2436** edges. Paper206 reviewed/rendered; do not edit paper. Package-202 builder still being finalized; no final tar yet. Remaining delivery gate: archive build / extract / hash verify / final receipt catalog. No goal-complete declaration before tar verified. Do not mark research complete.

Verified case-wrapper update (root, 2026-09-08): `body_head_bytes_lifted`, `body_head_bytes_entry`, `body_wc_lines_lifted`, and `body_wc_lines_entry` supply the bounded wrapper-ident/common-Gprog link. Fresh `root-case-transfer-head-audit-51` and `root-case-transfer-wc-audit-51` both exit/timing 0; printed assumptions are standard VST/Coq only. `case-transfer-finish-44/ROOT-ASSUMPTION-AUDIT.json` records log hashes and four repo/container identities. No whole GNU CLI/VSU or cross-kernel result follows; artifact entry24 is accepted by targeted replay63; historical replay57 lock contention is superseded; frozen full27 is historical accepted121; current shared manifest 30 after full30-174 (independent177 passed (root receipt recheck passed)).
