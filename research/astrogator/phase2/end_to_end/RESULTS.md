# End-to-end natural-language specification generation and verification

422 fixed programs nested within4 tasks;3 shared task-level translations permodel/guide. Repetitions andprogram-query cells are not independent problems.

All results use original pinned Astrogator with default permission semantics. Each row lists repeats r0/r1/r2; no repeat is selected using local correctness labels.

| Guide | Model | Decisions /422 | Accepted local failures | Rejected local passes | Unavailable |
|---|---|---|---|---|---|
| compact | gpt6 | 348 / 348 / 348 | 9 / 9 / 9 | 0 / 0 / 0 | 74 / 74 / 74 |
| compact | opus55 | 348 / 348 / 348 | 9 / 9 / 9 | 0 / 0 / 0 | 74 / 74 / 74 |
| handbook | gpt6 | 348 / 348 / 348 | 9 / 9 / 9 | 0 / 0 / 0 | 74 / 74 / 74 |
| handbook | opus55 | 348 / 348 / 348 | 9 / 9 / 9 | 0 / 0 / 0 | 74 / 74 / 74 |

Supplied-query control on the same strict-integrity labels: 348/422 decisions; 9 accepted local failures; 0 rejected local passes; 74 unavailable. This is not a gold-correctness guarantee.

The table uses strict-integrity labels. Full original-oracle and newline-sensitivity counts, per-repeat stage failures, supplied-query transitions, raw residuals, and all logical cells are retained in the JSON artifacts.

- Local behavioral labels are bounded fixture checks, not universal program correctness.
- Supplied-query control is not independently validated gold.
- No oracle-based selection among repeats and no query repair.
- Translation and judge inference budgets differ; no equal-compute claim.
- Fourtaskcohort omits broaderbenchmarktasks and generalization is not established.
