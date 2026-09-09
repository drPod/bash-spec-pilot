# Gaps recorded in the initial catalog

This is a historical inventory, not a list of current tasks. Later work closed several of these gaps. The [paper](../evaluation/paper.pdf) and [final delivery](../FINAL-DELIVERY.md) describe the completed prototype and its remaining limitations.

## Evidence available at the checkpoint

| Record | Evidence at the initial inventory | What that evidence did not establish |
|---|---|---|
| `PH5-CALC-004` | Draft `CalculusExport.lean` (733 lines), `ExportMain.lean`, and build configuration edits. A build was invoked but no successful compiled output was found. | A checked source-to-calculus theorem. The draft existed; describing the attempt as leaving no artifact was incorrect. |
| `PH5-CASE-001` | Checked mathematical relations `HeadOutcome` and `WcLinesShort`. | At that checkpoint, the corresponding `head_bytes` and `wc_lines` C body proofs were not closed. They were completed later. |
| `PH5-SHELL-004` | Four accepted and four rejected text-frontend examples. | Parser soundness beyond those examples. |
| `PH5-UTF8-001` | Independent specification work and roughly 1.19 million differential cases. | The VST C-conformance body proof and gettext caller transfer. This remains a negative calibration result. |
| `PH5-ARTIFACT-001` | A single-command smoke replay. | The full behavioral proof chain and evaluation matrix. Later artifact replays provide broader coverage. |
| `PH5-EVAL-002/003` | A completed 90-cell matrix, before its report was finalized; limited assisted results. | A general model ranking or a reliable assisted-baseline estimate. See the [corrected evaluation report](../evaluation-expanded/REPORT.md). |

## Superseded attempts

`adequacy-resume-2`, `calculus-resume-2`, `calculus-semantics`, the original `utility-reuse`, and `utility-linking-3` ended before producing final reports. Successor records carried forward the usable work. Their relationships are recorded in the `prior_or_superseded` fields of `PH5-UTIL-001`, `PH5-UTIL-002` and `PH5-CALC-002`; cite those successor records rather than an interrupted job as proof evidence.

## Distinctions retained in the catalog

- A lemma about a mathematical model is not a proof about a C body until the connection is established. Both additional utility cases reuse reading contracts; the initial catalog's suggestion of FullWrite reuse in `wc_lines` was incorrect.
- Linking four verification components does not verify GNU `cat`'s `main` function or argument parsing.
- The relay witness (`PH5-RELAY-007`), universal scheduled result (`PH5-RELAY-008`) and safety theorem (`PH5-RELAY-005`) have different quantifiers and assumptions. The safety result retains a `Jsub` premise; the two returned-outcome results do not.
- Finite OCaml comparisons and checked fixture identities do not prove the OCaml implementation correct for all inputs.
- A specified pipe scheduler is a model, not a proof about the host kernel's scheduling behavior.
- A typechecked VST contract is not a completed `semax_body` proof.

The original catalog audit requested independent checks of trial counts, shell scope, open case-study obligations and relay theorem assumptions. Subsequent receipts and milestone imports record those checks. The detailed historical record remains in `catalog.json` and the version history of this document.
