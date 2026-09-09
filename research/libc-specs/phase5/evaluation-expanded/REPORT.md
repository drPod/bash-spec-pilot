# Expanded proof-regeneration evaluation: corrected accounting

This report describes the frozen 2026-09-07 experiment. Root98 independently re-tallied the
immutable attempt ledger; no new model calls were made and no submissions were changed.
[RESULTS-CORRECTED.json](RESULTS-CORRECTED.json) preserves the accounting from finalize8;
[REPORT-ACCOUNTING.json](REPORT-ACCOUNTING.json) records the independent source hashes and counts.
The older RESULTS-SUMMARY.json aggregates first-pass, makeup and assisted records and must not
be used as a single first-pass denominator.

## Design

Three held-out nested-state frame/preservation proofs, two helper conditions, three recorded
model/harness combinations and five attempts per cell gave90 scheduled calls. Tasks, statements,
definitions and checker gates were frozen before calls. The checker enforced source/template
identity, prohibited proof shortcuts, invoked Lean4.31.0, audited axioms and checked the theorem
type. The [protocol](protocol.json) records controls, harness settings and intended budgets.
These are proof-regeneration tasks over Lean definitions, not an evaluation of generating
correct C, Bash scripts, utility contracts or natural-language specifications.

## First-pass accounting

| Population | Calls | Accepted |
|---|---:|---:|
| Original schedule, counting checker collisions as nonaccepts |90|22|
| Makeup calls replacing the three checker collisions |3|1|
| Scored matrix, with those replacements |90|23|

All93 first-pass model calls are retained. The three collisions had actual model responses
but stale checker directories prevented scoring; they are not absent calls. Both22/90 original
and23/90 makeup-substituted results must be disclosed. The scored matrix has61 build failures
and6 timeout/no-code-block outcomes in addition to23 acceptances.

| Recorded model/harness combination | Scored calls | Accepted |
|---|---:|---:|
| Claude Fable / Claude CLI |30|18|
| Claude Sonnet / Claude CLI |30|2|
| Grok4.6 / Pi |30|3|

These are descriptive counts, not a model ranking: model and harness are confounded, there
are only five observations per task/condition/model cell, and the tasks come from one research
program. The protocol's model labels identify the historical runs; they are not current model
availability claims.

## Helpers and feedback

All seven accepted base-condition proofs came from the recorded Fable combination. Thus deleting
the designated helper did not prevent alternative proofs. Rejection of the original proof under
a helper-deleted control is evidence that that proof depends on the helper, not that every
proof does. The experiment does not establish a general causal improvement from helper reuse.

Three assisted attempt records contain two calls each: six actual feedback calls, all rejected,
against the protocol's planned three extra calls. This budget deviation is disclosed and has
not been retroactively corrected. The separate three-run agent-assisted collaborative baseline
had one accepted proof and two failures according to the saved finalize8 report and checker
receipts. It is not a human baseline and is not directly comparable to first-pass trials.

## Integrity and interpretation

The original source is the immutable evaluation archive, SHA256
`36525e18cde92225dcaef9d30077565f1124a7c96782b22ef3e3366c75783587`.
The live development CalculusNested.lean has since evolved. Do not regenerate this study's
templates from that live file. Original protocol, templates, submissions and attempt ledger
remain unchanged. Prompt hashes were recovered from saved prompt files by finalize8; this is
provenance recovery, not a new experiment. This study is distinct from the earlier12-call,
single-model diagnostic (7accepted), and neither establishes broad automation effectiveness.
