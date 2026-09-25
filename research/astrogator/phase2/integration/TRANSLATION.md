# Strong-model NL to FQL: matched source-handbook ablation

| Prompt | Model | Complete | Parsed | Lowered | Reference-effect matches |
|---|---|---|---:|---:|---:|
| compact | gpt-6-astra | True | 60/63 | 36/63 | 27/63 |
| compact | claude-opus-5-5 | True | 60/63 | 33/63 | 27/63 |
| handbook | gpt-6-astra | True | 63/63 | 63/63 | 53/63 |
| handbook | claude-opus-5-5 | True | 63/63 | 60/63 | 57/63 |

21 tasks, three fresh generations per task/model/arm; 63 outputs are not63independentproblems.

- Normalized semantic-effect matching is a reference-agreement proxy, not proof of intent fidelity.
- Same four demonstrations and targets; handbook changes both information content and prompt length.
- Existing source KB is task-related domain engineering; no unseen-domain claim.
- Fresh calls lack matched random seeds; paired cells share tasks, not generation randomness.
- No gold target FQL or parser feedback supplied to either generation arm.
- Code generation validated with original pinned source; code patches are evaluated separately.
