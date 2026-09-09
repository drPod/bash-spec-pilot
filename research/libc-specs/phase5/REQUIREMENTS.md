> Final delivery closure (release212, audit213, catalog215): required work is complete at the documented research bounds. See [FINAL-DELIVERY.md](FINAL-DELIVERY.md). Historical pending-package statements below describe the frozen pre-release snapshot and must not be read as current packaging status.

# Research completion ledger

Record original-plan obligations, accepted bounded results, and remaining research-program limits. A green bounded pilot is not completion of the broader Bash/State Calculus program or evidence of conference acceptance.

**Current prototype.** [FINAL-DELIVERY.md](FINAL-DELIVERY.md) and [evaluation/DRAFT-PAPER.md](evaluation/DRAFT-PAPER.md) state the accepted fragment: Lean script language with `relay`, modeled `mark`, sequencing, `&&`, `||` and parentheses; only `relay` has the generated-C connection in Lean; UTF-8 is a negative calibration; LLM proof regeneration 23/90 scored.

CompCert `step*` preservation, Vundef, full Bash, host OS, GNU `main`, query-text parsing, character-level lexer, and Coq↔Lean proof import are outside the accepted claim.

## Source-to-calculus connection (accepted at root197; historical gap 179)

Original-source audit179: a source hash, canned AST recognizer, finite comparison, or empirical Coq/Lean agreement alone does **not** prove semantic preservation. A generic Coq importer, full Bash, and full GNU `main` were not newly required.

Root197 accepts a **bounded** connection after independent195 review of cp17 and root hash review of cp18 model / cp19 dump / cp20 source proof. Generated `fRelay` equals `BufferRelay.execute` on status and observable fields, then Nested `initialState` (`clight_calculus_initialState`) and the shared script relay atom (`clight_calculus_shared` / `atomStep .relay`) under explicit action identities, headroom and fuel.

Explicit TCB: CompCert clightgen, syntax-directed Python dump, reviewed Lean Clight/Cop subset transcription, scheduled libc contracts. **Not** CompCert `step*` preservation, **not** a Vundef theorem (total byte memory), **not** full Bash. Historical Nested `lost` is a ghost field, not C RAM; current pending is the buffer suffix / memory range `[off,n)` on status 2.

| Module | Kind | Hash |
|---|---|---|
| `ClightSubset` | src | `7e3061ead3041cfc4ac9ed13135921be6efa04ceeaabd1d5283792b31db95b58` |
| `RelayClightDump` | src | `fd49f46c3c414c23294e71efeebcf98fc833573d86a12bbde217630253ac497a` |
| `ClightRelayLink` | src | `cc02a88c4ec8ddadb2344d8df77c04bebbbad8390af3d70bac4aeb3542fdc467` |
| `ClightRelayLink` | log | `4fb77cff3dcd89e2e3895b33b05cdbd7b6faee2e48937f3cf244fc5ca743764d` |
| `ClightRelayLink` | olean | `3d4674d8e4ecd792ea670f4decad3fc8e36c4f6f690fec261364c80b89617cca` |
| Independent195 pin | SHA | `a5c689e54bd9ca8f04743c59815524fe2ed2bd85ad6071e1770b359fb7cef876` |

Fresh source replay196 accepted203 (`run20260908T224120Z`, 18 modules, 18 named axiom reports, 17 generator checks, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`). Claude200 original-requirement matrix: no mandated proof gaps at stated bounds with 9 TCB boundaries. Receipt: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-clight-source-review-197/ROOT-REVIEW.json`. Historical 179 evidence: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/original-source-link-audit-179/EVIDENCE.json`. Original scope: `organization/ORIGINAL-USER-SCOPE.md`.

These source modules are **not** in the shared 30-entry manifest.

## Artifact replay

| Artifact | Run | Result |
|---|---|---|
| Shared manifest **30** (full30) | `run20260908T213227Z`, summary `165a63d40cdf862605142d368c61a057a3571e4ae9d29f6c81e1b95b2f347aee` | Terminal exit 0: **29 PASS** + 1 experimental host-OCaml skip; container PASS; fresh true, nofilter. Root183 accepted; independent177 passed. **Does not** include source197 or supplementals. |
| Frozen **full27** (historical) | `run20260908T195509Z` | Root121 after independent120: **26 PASS** + 1 experimental host-OCaml skip; container PASS. |
| Supplemental 175/188, fresh198 | `run20260908T223418Z`, summary `a8528873723704287780d6973e53957bfd97ec3139e21580dcd3d81d94e3c781` | **23** fresh modules, 9 named standard-axiom reports; **not** full30. |

Shared exception170 and shell173 accepted. Evaluation archive unchanged `36525e18cde92225dcaef9d30077565f1124a7c96782b22ef3e3366c75783587`. Paper206 reviewed/rendered (source b515b98b… HTML 0f8135f…); do not edit the paper in this ledger.

Catalog counts are indexes, not theorem coverage. Historical Catalog205: Atlas **307** private, local OpenScience **2379** nodes / **2436** edges. Current delivery catalog: see [FINAL-DELIVERY.md](FINAL-DELIVERY.md) (308 / 2380 / 2436).

## Accepted workstreams (scope as of 2026-09-08)

UTF-8 is not a replacement for the work below. Root reviews, not worker reports, are authoritative. Utility13/14, calc14/15, and fd24 are accepted at the named reviews, not as research-program completion.

| Workstream | Current accepted scope | Remaining original-plan / boundary |
|---|---|---|
| Universal concrete C execution | **`PH5-RELAY-008`**: bounded-∀ over permitted executions of `relay_main.prog` and `relay_exit.prog`, plus `UniversalShell.v`, Jsub-free; distinct from existential `PH5-RELAY-007` and from `Safety.v` (`relay_dry_safety` still has `Jsub`). | Exact environment and memory-equivalence assumptions stated; termination against a non-scheduled/host-OS environment remains out of scope |
| Shell expansion | **`shell-expansion/extended/Compose.v`**: pipes and redirection with `parse_program3_sound`; 31 closed `ComposeAudit.v` statements. Finite descriptor binding/write/restoration from fd24 under explicit freshness. **Stateful55**: three source identities and 18 standard-Lean assumption outputs; composition consumes residual input and read/write schedules. | Lean reference composition, **not** a checked C/Coq-to-Lean bridge. Parser completeness and compound-command redirection outside the requested minimum |
| General calculus correspondence | **1,593/1,593** empirical comparisons; `write_block_prefix_binds`; CalculusBody whole `write_block` + `relay_inner_step`. **Calc14** outer/`runEntry` (fuel `+ 2*\|inp\| + 108`, status `{0,1,2}`) + 3 concrete `Stmt.WF`/roundtrip. **Calc15**: `relay_matches_phase3` exact return status + five root fields vs phase3 `run`/`runDetailed`, fuel `+ 2*\|inp\| + 110`, premise `(inp.length : Int)+1 ≤ maxInt`. **Calc67**: seven fields including residual `reads`/`writes`. **Shared70**: arbitrary related seven-field state. Root87 command encoding; root92 query AST compiler; tokenizer identities117; harness133 (1,593 replay and 12 negatives); parser135 (38 fixtures); raising151/147. **Typing61** at root74; **Export75** at root77; guards82/89. | Query text parsing and exact-byte query expressions outside this claim. General nonfailure and OCaml-source correspondence remain open. Initial lowering used a hand-transcribed AST until export75. `interp_pure_state` is pure-state preservation, not `WellTyped`. Scope-audit-152: no arbitrary-Related raising theorem required. Historical inner/outer jobs 131/138/146 are not active pending proofs |
| Additional non-UTF8 case studies | **`body_head_bytes`** and **`body_wc_lines`** closed. `head_bytes` writes via stdio **`XWrite`**, not `IOW.FullWrite`. `wc_lines` Gprog is `safe_read`/`quotearg`/`error`/`rawmemchr` plus count output pointers — **no FullWrite import**. Wrapper/common-Gprog link accepted by root-case-transfer-{head,wc}-audit-51 | Do not invent `wc_lines_null_spec` or full GNU CLI. VSUs for these functions were never an original-plan must |
| Larger comparative evaluation | 90 scheduled first-pass calls; 93 first-pass including 3 disclosed makeup; **90 scored**; **23/90** accepted (makeup-substituted) and **22/90** original both disclosed. **No new trials.** | Dual-denominator disclosure only; n=30/model; helper ablation ineffective for `claude:fable`; agent-assisted (not human) baseline |
| Reproducible artifact and manuscript | Manifest **30**; full30 replay174 as above. Bounded source connection 197. Paper206 reviewed | Trusted OCaml/C/cross-kernel boundaries stay explicit. Packaging does not expand proof claims |
| UTF-8 calibration | Closed bounded experiment / stated negative | Preserve missing C conformance/caller-transfer |

## Completion evidence

| Requirement | Evidence now | Missing / boundary |
|---|---|---|
| Existing-library reuse decision | Phase4 source reviews; phase5 `Body.body_relay` (`relay-body-coqc-16`); GNU leaf bodies including `body_full_write`; `head_bytes`/`wc_lines` reuse **read** (`IOW.SafeRead`) unchanged | Head uses stdio `XWrite`; wc has no FullWrite import |
| Trustworthy C representation | CompCert 3.15 relay Clight generated and accepted by Coq; hashes in `phase5/relay/frontend-results.json` | Functional source theorem and stronger textual-source translation assurance |
| Byte-bearing memory and I/O | Phase3 Lean refinement; phase4 modular memory; phase5 VST body; `relay/adequacy/Dry.v`; `Safety.v` `relay_dry_safety` under `Jsub`; returned-status/termination for scheduled worlds by `PH5-RELAY-007`/`008` plus `UniversalShell.v` (Jsub-free) | Named `Trace.v` attempt 7 timed out and is **superseded**; no mandatory redo. `Jsub` remains on the **safety** family |
| Nonvacuity and progress | Abstract progress (`outcome_exists`); witness `PH5-RELAY-007`; bounded-∀ `PH5-RELAY-008` | Universal is bounded to the scheduled-environment model |
| Source-as-specification | Hand-authored functional lemmas (`cat_true_copies_all`, `HeadOutcome`, `WcLinesShort`, `XWrite_effect`, …); CaseTransfer wrappers | No independent mandate for an automatic C-text spec extractor. C-as-spec can preserve source bugs |
| Independent correctness calibration | Frozen gnulib UTF-8; 1,190,417 baseline + five directed cases (`calibration/RESULTS.md`) | C conformance and caller transfer unestablished |
| Reuse beyond purpose-built relay | Five body proofs, four VSU components and AllVSU linking; 24-file GNU replay. Utility13: full POST + `iow_juicy_dry_specs` (**15** replay receipts, **13** source identities). Embed-read PRE accepted. Utility14: PRE transport + dry PRE at `m'` + dry POST chaining under fresh errno cell (`mem_cell_ext`); 27 receipts | **Not** whole linked `main`/`prog_correct`/`funspec_sub`; **not** juicy POST reverse to `Relay_Espec` |
| Aaron's frontend integration | Pinned parser plus bounded lowering; 2,046 observations + 90 Coq oracle; **1,593/1,593**; axioms `propext` / `Classical.choice` / `Quot.sound`. Parser135: TOKEN-grammar soundness; Nested connector | Aaron's spec-language parser still does not parse Bash. No independent character-level lexer grammar, host-Bash semantic equivalence, completeness, or query-text parser. Fuel mono ≠ general WF |
| Shell/query connection | `shell-bridge/` 44; `Compose.v`; Fd24 finite live-table write gating; Parser135 38/38 fixtures; Stateful55 | Not OS/allocator/pipes. Not a C/Coq-to-Lean bridge |
| Final proof-assistant boundary | Lean proves supported script behavior matches its query through the state calculus at documented bounds (root87/92 + Shared70 + parser135 + source197) | Utility-source/OCaml/cross-kernel trust boundaries remain explicit |
| Automation improvement | Original 12-cell diagnostic (7/12). Expanded: 90 scheduled / 93 first-pass (3 makeup) / **90 scored**; **23 accepted** and **22 original** | Not a general-improvement claim |
| Paper contribution and artifact | Manifest 30; full30 replay174; paper206 | Do not treat packaging as an expanded theorem |

Calibration remains subordinate: one bounded target, stated transfer hypothesis and stop criterion. Do not conflate preserving C behavior with proving C conforms to an independent format specification.

## Historical notes (not current-status patches)

| Dated claim | Status |
|---|---|
| 2026-09-07 table text: universal termination missing, head/wc bodies absent, `write_block` only a 3-assignment prefix | Superseded by `PH5-RELAY-007`/`008`, case6/case9 bodies, calc14, utility13 |
| Early evaluation singular 22/90 | Both 22/90 original and 23/90 scored must be disclosed |
| Package-202 “no final tar” in pre-release ledgers | Closed by release212 / audit213; see [FINAL-DELIVERY.md](FINAL-DELIVERY.md) |
| Audit108: Commands87/Query92 start from Lean ASTs | Bounded by parser135 |

Case wrapper acceptance (2026-09-08): `CaseTransfer.v` and `CaseTransferWc.v`; `case-transfer-finish-44/ROOT-ASSUMPTION-AUDIT.json`. Adds no GNU main, VSU, host-libc, or Coq-to-Lean claim.
