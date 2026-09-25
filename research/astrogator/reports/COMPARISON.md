# Four-task paired comparison

Execution complete: **True**. Judge complete: **True**. Configured heuristic sweep complete for this slice: **True**.

Labels mean passing or failing the declared local checks/execution, not universal correctness. Missing processed files are excluded from the table; uncertain, unsupported, invalid, and pending method outcomes remain unavailable decisions.

| Method | Accept local pass | Reject local pass | Accept local fail | Reject local fail | Unavailable |
|---|---:|---:|---:|---:|---:|
| astrogator | 282 | 1 | 9 | 56 | 74 |
| astrogator_configured_heuristics | 277 | 6 | 0 | 65 | 74 |
| judge | 270 | 13 | 129 | 10 | 0 |
| generated_checks_gated | 0 | 0 | 0 | 0 | 422 |

Do not rank methods from incomplete ordered prefixes. The JSON includes per-task results and a common-decision subset for the base verifier and judge, plus explicit coverage and stage counts. All 110 directory-creation candidates pass the local check, so pooled totals can obscure performance on the harder tasks.

[Oracle and specification disagreements](DISAGREEMENTS.md) · [Execution audit](four-task-execution-audit.json) · [Machine-readable results](four-task-comparison.json) · [CSV](four-task-comparison.csv)

- Two initial states on Debian; local checks are not universal correctness.
- Base verifier accepts may carry residual obligations; heuristics disabled.
- Unsupported outputs are abstentions, not automatic rejections.
- Generated checks have a known-good reference gate: a separate advantage over an ungated baseline.
- Configured heuristics use pinned upstream metadata, not reconstructed local-container facts; disagreements need context review.
- Partial runs are ordered, nonrandom prefixes; do not rank methods from interim results.
- Four tasks are not representative of all 21 tasks or all Ansible workloads.
