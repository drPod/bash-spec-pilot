# Expanded proof-regeneration evaluation: corrected accounting

This report describes the frozen experiment of 7 September 2026. Its counts were independently recalculated from the attempt ledger without making new model calls. [`RESULTS-CORRECTED.json`](RESULTS-CORRECTED.json) preserves finalize8 accounting; [`REPORT-ACCOUNTING.json`](REPORT-ACCOUNTING.json) records source hashes and counts. Older RESULTS-SUMMARY.json mixes first-pass, makeup and assisted records — not a single first-pass denominator.

This 23/90 scored figure is what [`../evaluation/DRAFT-PAPER.md`](../evaluation/DRAFT-PAPER.md) cites. The earlier 12-call diagnostic, with seven accepted proofs, is reported separately.

## Design

The experiment used three held-out nested-state proofs, two helper conditions, three model/harness combinations and five attempts per cell, giving 90 scheduled calls. Tasks, statements, definitions and checking rules were frozen before the calls. The checker verified source and template identity, rejected prohibited shortcuts, compiled with Lean 4.31.0, inspected assumptions and checked the resulting theorem type. The [protocol](protocol.json) records the controls. These tasks measure proof regeneration over Lean definitions, not the generation of C, Bash or natural-language specifications.

## First-pass accounting

| Population | Calls | Accepted |
|---|---:|---:|
| Original schedule, collisions as nonaccepts | 90 | 22 |
| Makeup replacing three checker collisions | 3 | 1 |
| Scored matrix with those replacements | 90 | 23 |

All 93 first-pass calls are retained. The three collisions produced model responses, but stale checker directories prevented scoring. Counting those calls as failures gives 22/90; substituting their makeups gives 23/90. The replacement-based scored set contains 61 build failures, six timeout or missing-code outcomes and 23 accepted proofs.

| Recorded model/harness | Scored calls | Accepted |
|---|---:|---:|
| Claude Fable / Claude CLI | 30 | 18 |
| Claude Sonnet / Claude CLI | 30 | 2 |
| Grok 4.6 / Pi | 30 | 3 |

These counts describe the recorded configurations. Model and harness vary together, there are only five observations per cell, and all tasks come from one research program. The results therefore do not establish a general model ranking.

## Helpers and feedback

All seven accepted base-condition proofs came from the recorded Fable combination. Deleting the designated helper did not prevent alternative proofs. Rejecting the original proof under helper-deletion shows that proof depends on the helper, not that every proof does. No general causal claim about helper reuse.

Three assisted attempt records contain two calls each: six feedback calls, all rejected. This exceeded the protocol’s planned three extra calls, a deviation retained in the record. A separate three-run agent-assisted collaboration experiment accepted one proof and rejected two. It was not a human baseline and is not directly comparable to first-pass attempts.

## Integrity

Immutable evaluation archive SHA256 `36525e18cde92225dcaef9d30077565f1124a7c96782b22ef3e3366c75783587`. Live `CalculusNested.lean` has evolved; do not regenerate templates from it. Prompt hashes recovered from saved files (provenance, not a new experiment). Neither this study nor the 12-call diagnostic establishes broad automation effectiveness.
