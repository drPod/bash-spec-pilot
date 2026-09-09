> Final delivery closure (release212, audit213, catalog215): all required work is complete at the documented research bounds. See [final delivery receipt](../FINAL-DELIVERY.md). Historical pending-package statements below describe the frozen pre-release snapshot.

# Proof chain and trusted boundaries

Current evidence: full30-174 terminal (manifest **30**; 29 PASS + 1 experimental host skip / container PASS; root183 accepted; independent177 passed (root receipt recheck passed); **not** including source197 or supplementals), shared exception170 and shell173 accepted, tokenizer harness133, shell parser135, raising151/147 documented-scope accepted, tokenizer targeted158, frozen full27 historical at121. Audit179's bar against empirical-only discharge is preserved. **Bounded source-to-calculus connection accepted at root197** under explicit TCB (clightgen / Python dump / reviewed Lean Clight subset / libc contracts): generated `fRelay` equals `BufferRelay.execute` on status and observables (`relay_clight_execute` / `relay_clight_execute_body`), then Nested `initialState` (`clight_calculus_initialState`) and shared script relay atom (`clight_calculus_shared`). **Not** CompCert `step*` / Vundef / full Bash. Historical `lost` is ghost; current pending is memory. Independent195 reviewed cp17; cp18/cp19/cp20 promoted after root delta/hash review. `ClightSubset` `7e3061ead3041cfc4ac9ed13135921be6efa04ceeaabd1d5283792b31db95b58`; `RelayClightDump` `fd49f46c3c414c23294e71efeebcf98fc833573d86a12bbde217630253ac497a`; `ClightRelayLink` src `cc02a88c4ec8ddadb2344d8df77c04bebbbad8390af3d70bac4aeb3542fdc467` log `4fb77cff3dcd89e2e3895b33b05cdbd7b6faee2e48937f3cf244fc5ca743764d` olean `3d4674d8e4ecd792ea670f4decad3fc8e36c4f6f690fec261364c80b89617cca`. Fresh196 accepted203 (`run20260908T224120Z`, 18 modules, 18 axioms, 17 fixtures, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`); Claude200 original-requirement matrix terminal (no mandated proof gaps; 9 TCB boundaries). The original research is incomplete. Original proofs at documented scope are accepted; this is not whole-goal completion. This document
separates checked theorems from executable comparisons and trusted translations. Detailed
receipts and remaining obligations are indexed in [COMPLETION-AUDIT](../COMPLETION-AUDIT.md).
Original user scope is preserved in [ORIGINAL-USER-SCOPE](../organization/ORIGINAL-USER-SCOPE.md).
See also [CLIGHT-SOURCE-ACCEPTANCE](lean/CLIGHT-SOURCE-ACCEPTANCE.md).

## Checked objects

| Object | Accepted result | Limit |
|---|---|---|
| Relay C / Clight / VST | Body contracts, protocol, progress, concrete and universal permitted scheduled executions, exit and shell consequences | C text-to-Clight frontend and external-call contracts remain trusted; no host OS nonreturn theorem |
| GNU utility leaves | Five body proofs and four VSUs, linked AllVSU with fresh replay | Stated imported libc/environment contracts |
| GNU head_bytes and wc_lines | VST body proofs plus lifted common-Gprog and entry-wrapper proofs; targeted replay63:19 fresh Coq compilations/four audits | Bounded function bodies/wrappers, not whole GNU command-line programs |
| Utility memory/world transport | Utility13 juicy/dry PRE/POST; Utility14 full PRE witness, fresh errno memory coherence and dry POST transport | No general juicy POST reverse or whole linked GNU main claim |
| Lean pointer model | Byte execution/refinement and protocol consequences | Independently specified model; no checked Coq-to-Lean import |
| Coq shell frontend/composition | Bounded lexer/parser soundness, sequence/and/or/parentheses, relay pipeline and atom/pipeline redirection, finite fd-table adequacy | Soundness, not parser completeness; no full Bash/OS semantics |
| Lean stateful shell reference | Stateful55 consumes actual read/write schedules and preserves cumulative state; replay69:8 modules/18 audits | Reference-model composition, not a Coq proof import |
| CalculusNested | Nested state/control semantics, frame rules, fuel monotonicity and concrete well-formed bodies | Lean transcription of the supported patched calculus semantics |
| Actual calculus relay | Whole write_block/read_block/inner/outer-loop proofs; calc15 output; calc67 residual schedules; Shared70 arbitrary related state | Explicit action-body identities and cumulative integer headroom |
| General calculus typing | Root74 preservation, sound checker and nine typed exported bodies; four fresh modules/13 audits | Preservation permits failure; does not establish general progress/nonfailure |
| Spec AST lowering | Root77 machine-produced parser AST equals the Lean AST and lowers to the nine exact exported bodies | Parser, AST printer and Python generator executions remain trusted |
| Actual write_block guards | Root82 derives five range/assert facts; two fresh modules/11 audits | Imported state invariants, counter headroom and possible failure/raise remain explicit |
| Full-export tokenizer + harness | Root117 six text-to-token/AST identities; root133 universal copy equality and actual corrected CLI (saved 1,593 + 12 negatives) | Not research completion; OCaml interpreter source still unchecked |
| Supported Lean Bash-fragment parser | Root135 text parser, independent TOKEN-grammar soundness, Nested command/query connector under parse-success/action/Related/Budget; 38/38 fixtures | No independent character-level lexer grammar; no host-Bash semantic equivalence; no full Bash/completeness/query-text claim |
| Raising/caught documented correspondence | Root151 actual raising/caught `initialState` exact status + seven root fields vs BufferRelay; root147 actual general-`st` same-post entry/catch | No arbitrary-Related raising theorem (scope-audit-152). Historical 131/138/146 are not active pending proofs. No complete OCaml-source / cross-kernel / whole-Bash claim |
| Bounded generated-Clight source connection | Root197: `relay_clight_execute` / `clight_calculus_initialState` / `clight_calculus_shared` after independent195 + cp18/19/20 hash review | Explicit TCB (clightgen/Python dump/reviewed Lean Clight subset/libc). Not CompCert step*/Vundef/full Bash. Historical lost ghost; pending is memory. Not in full30. Fresh196 accepted203; Claude200 terminal |

`head_bytes` uses the explicit stdio `CaseWorld.XWrite` contract, not `FullWrite`.
`wc_lines` uses SafeRead, error/quotearg/rawmemchr and output pointers; it does not call a
write routine. Finite mocked C tests support these case studies but do not replace VST proofs.
UTF-8 remains a separate completed bounded negative calibration, not C-conformance evidence.

## Translations and connections

1. **C text to Clight:** trusted CompCert frontend. Source/AST hashes identify the exact inputs;
   Coq checks the resulting definitions and proofs, not the parser implementation.
2. **Clight to VST contract to Coq protocol/shell:** checked within Coq under the stated
   external-call contracts. Universal scheduled-execution theorems are stronger than a single
   successful witness, but do not model every host OS behavior.
3. **Coq protocol versus Lean pointer model:** no checked bridge connects the kernels. Shared
   finite oracle comparisons are empirical agreement. Corresponding theorem statements do not
   by themselves prove equivalence. A general importer was not a separately mandated user task.
   Audit179 forbade treating empirical Coq/Lean agreement as discharge; that bar is preserved.
   Root197 accepts a **bounded** generated-`fRelay`→`BufferRelay`→Nested/script-atom connection
   under the explicit TCB above, not CompCert `step*` preservation.
4. **Spec-language text to parsed AST:** the pinned OCaml parser is executed. The original
   upstream semantic analyzer is incomplete; the project supplies a bounded adapter lowering,
   rejecting unsupported syntax. Aaron's parser parses the spec language, not Bash text.
5. **Parsed AST to Lean exported bodies:** root77 preserves the actual parser AST as a
   4,579-byte, 33-declaration S-expression and deterministically regenerates SpecAstExport.
   `exportedSpec_eq_hand` is axiom-free; `exported_lowers` uses `propext`. These establish
   constructor equality and the Lean lowering result for this input. They do not prove the
   parser/printer/generator or OCaml lower.ml source correct.
6. **Lean calculus versus OCaml execution:** the pinned interpreter plus the documented nested
   state/path patches is compared on identical inputs. The accepted 1,593 canonical comparisons
   are empirical; there is no proof of OCaml source equivalence. Full text-to-token-to-AST identities for all three exports are accepted117; harness133 and pinned tokenizer targeted158 are accepted. OCaml interpreter source remains unchecked.
7. **Actual calculus execution to a script/query property:** Shared70 now gives a checked
   arbitrary-state relay primitive with all seven fields, including residual schedules and
   cumulative counters. Root87 accepts general command encoding, derived compositional headroom and structural
   fuel, with11 exact standard-Lean axiom audits. Root92 accepts bounded query compilation and actual exported mark identity (17 query audits plus an axiom-free equality). Audit108 identified a real original-scope gap: the separate Coq Bash-subset parser does not
   feed encodeCmd. That gap is now bounded by parser135: a supported Lean text parser with
   independent TOKEN-grammar soundness composed with the Nested command/query theorem under
   explicit premises (38 fixtures). Do not invent a natural-language/query-text parser or
   generic Coq importer. Drafts are not accepted
   merely because they exist or print some successful theorem audits.
8. **Models to host Bash/libc/kernel:** finite host observations are evidence, not a checked
   identification of the models with all real executions.

## Original Lean-final requirement

The user requested that script and query compile to state calculus and that Lean prove their
behavior agrees. Root87/92 now prove the bounded CalculusNested command/query link on
top of Shared70. The query input is a Lean AST of status, counters, list lengths and Boolean
comparisons; query text parsing and exact-byte expressions are not claimed. A generic predicate-transfer theorem alone is not a query compiler. The
separate accepted Coq shell chain is useful evidence, but does not silently replace the
original Lean-final requirement. Neither a toy second interpreter nor an assumed primitive
simulation would close the remaining actual-calculus obligation.

The supported shell grammar, finite schedules, imported utility contracts and integer
headroom must stay visible in the final claim. No full Bash, verified OCaml frontend, host OS
or cross-kernel proof import is claimed.

## Replay and provenance

Current shared manifest **30**. Full30 replay174 is terminal exit 0
(`run20260908T213227Z`, summary sha256
`165a63d40cdf862605142d368c61a057a3571e4ae9d29f6c81e1b95b2f347aee`): 29 PASS and one
experimental host-OCaml skip, matching container PASS, fresh true, nofilter. Root183 is a
accepted artifact replay; independent receipt audit177 passed; root receipt recheck passed. Shared exception170 and shell173 are accepted; private 162/164 are no longer
pending. Frozen full27 (run20260908T195509Z) remains **historical** accepted at root121 after independent audit120:
26 PASS and one experimental host-OCaml skip, matching container PASS; root rehashed 404 logs
and 98 outputs (`root-full27-review-121/ROOT-REVIEW.json`). Supplemental188 accepted; fresh198 (`run20260908T223418Z`, summary
`a8528873723704287780d6973e53957bfd97ec3139e21580dcd3d81d94e3c781`): 23 fresh modules, 9 named
standard-axiom reports. It is not included in full30. Source197 is also not in full30.
Caches remain off. The evaluation (93 first-pass /
90 scored / 23 accepts; no new trials) and older proof archives remain frozen. Paper206 reviewed/rendered (source b515b98b… HTML 0f8135f…); do not edit paper.

Atlas and local OpenScience organize evidence; file/checker receipts establish acceptance.
Catalog205: Atlas **307** private nodes, local OpenScience **2379** nodes and **2436**
edges. These are dated catalog counts, not measures of theorem coverage. The root atlas.json
is a client-side contract, not the OpenScience CLI configuration or a cloud project identity.

Guard integration is accepted89, including read_block failure after bookkeeping and conditional
catch behavior (15new audits/4dependencies). Tokenizer identities117, harness133, and targeted
tokenizer158 are accepted. Parser135 is accepted within stated limits. Raising151/147 are
accepted at documented scope. **Bounded source connection accepted197** under explicit TCB;
179 empirical-only bar preserved. Fresh196 accepted203 (`run20260908T224120Z`, 18 modules, 18 axioms, 17 fixtures, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`); Claude200 original-requirement matrix terminal (no mandated proof gaps; 9 TCB boundaries). Goal is not packaging-only.
No new model trials are required; the evaluation and UTF-8 calibration remain frozen.
Trusted OCaml/C/cross-kernel boundaries remain explicit. Package-202 builder still being finalized; no final tar yet. Remaining delivery gate: archive build / extract / hash verify / final receipt catalog. No goal-complete declaration before tar verified. Research is not complete.
