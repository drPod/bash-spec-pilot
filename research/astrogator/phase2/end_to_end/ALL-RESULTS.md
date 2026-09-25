# All21-task end-to-end paired decisions

Supplied-query agreement and coverage are reported here; neither is accuracy. Actual behavioral labels remain restricted to the separate four-task experiment. Each row lists r0/r1/r2.

| Guide | Model | Decisions /2238 | Status changes | Accept→reject | Accept→unavailable | Reject→accept | Unavailable→accept |
|---|---|---|---|---|---|---|---|
| compact-all | gpt6 | 1012 / 1012 / 1012 | 1091 / 1091 / 1014 | 97 / 97 / 20 | 262 / 262 / 262 | 43 / 43 / 43 | 0 / 0 / 0 |
| compact-all | opus55 | 933 / 933 / 933 | 1068 / 1068 / 1068 | 7 / 7 / 7 | 275 / 275 / 275 | 0 / 0 / 0 | 0 / 0 / 0 |
| handbook-all | gpt6 | 1528 / 1528 / 1528 | 3 / 3 / 3 | 1 / 1 / 1 | 0 / 0 / 0 | 2 / 2 / 2 | 0 / 0 / 0 |
| handbook-all | opus55 | 1471 / 1471 / 1471 | 110 / 110 / 110 | 0 / 0 / 0 | 0 / 0 / 0 | 2 / 2 / 2 | 0 / 0 / 0 |

The verbatim supplied-query control has900 acceptances,628 rejections,710 lowering failures and72 missing attempts. Earlier corpus results used an explicit a18/p17 example.com→acc240.com domain substitution and had909 acceptances/619 rejections. The9 differences are retained separately; they are not translation-caused changes. Generated queries and control here both retain the prompt domain verbatim.

Primary agreement denominator: the1,528 supplied-query-decided programs, excluding710 control-lowering failures.

| Guide | Model | Same decision /1528 | Became unavailable | Accept→reject | Reject→accept |
|---|---|---|---|---|---|
| compact-all | gpt6 | 872 / 872 / 949 | 516 / 516 / 516 | 97 / 97 / 20 | 43 / 43 / 43 |
| compact-all | opus55 | 926 / 926 / 926 | 595 / 595 / 595 | 7 / 7 / 7 | 0 / 0 / 0 |
| handbook-all | gpt6 | 1525 / 1525 / 1525 | 0 / 0 / 0 | 1 / 1 / 1 | 2 / 2 / 2 |
| handbook-all | opus55 | 1469 / 1469 / 1469 | 57 / 57 / 57 | 0 / 0 / 0 | 2 / 2 / 2 |

Query-format failures, semantic/code-generation failures, program lowering failures, rejection, and acceptance remain distinct in JSON. A status change is not automatically a correction or a new bug. Acceptance retains verifier assumptions and residuals. All three repeats are kept; no best-repeat selection.
