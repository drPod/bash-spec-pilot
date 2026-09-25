# Strong-model paired comparison

Frozen selection: 86 processed programs from 88 task/model/index cells; 2 missing processed files. GPT-6 complete: True; Opus 5.5 complete: True.

Saved task prompts omit outcome labels, target solutions, and oracle code; fresh CLI sessions and tool-use checks were used. Global Claude CLI plugin session hooks remained active, so completely empty client context is not established. Inputs and outputs are hash-checked. Original local labels and revised-oracle sensitivities are reported separately. Verifier mode: pinned upstream default permission semantics, with a separate configured-heuristic arm.

| Label variant | Method | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---|---:|---:|---:|---:|---:|
| original | astrogator | 57 | 0 | 0 | 15 | 14 |
| original | astrogator_configured_heuristics | 56 | 0 | 1 | 15 | 14 |
| original | Qwen 2.5 1.5B judge | 55 | 27 | 2 | 2 | 0 |
| original | gpt6 | 57 | 1 | 0 | 28 | 0 |
| original | opus55 | 57 | 4 | 0 | 25 | 0 |
| original | always_accept | 57 | 29 | 0 | 0 | 0 |
| new_fixture_old_oracle | astrogator | 57 | 0 | 0 | 15 | 14 |
| new_fixture_old_oracle | astrogator_configured_heuristics | 56 | 0 | 1 | 15 | 14 |
| new_fixture_old_oracle | Qwen 2.5 1.5B judge | 55 | 27 | 2 | 2 | 0 |
| new_fixture_old_oracle | gpt6 | 57 | 1 | 0 | 28 | 0 |
| new_fixture_old_oracle | opus55 | 57 | 4 | 0 | 25 | 0 |
| new_fixture_old_oracle | always_accept | 57 | 29 | 0 | 0 | 0 |
| strict_integrity | astrogator | 57 | 0 | 0 | 15 | 14 |
| strict_integrity | astrogator_configured_heuristics | 56 | 0 | 1 | 15 | 14 |
| strict_integrity | Qwen 2.5 1.5B judge | 55 | 27 | 2 | 2 | 0 |
| strict_integrity | gpt6 | 57 | 1 | 0 | 28 | 0 |
| strict_integrity | opus55 | 57 | 4 | 0 | 25 | 0 |
| strict_integrity | always_accept | 57 | 29 | 0 | 0 | 0 |
| newline_sensitivity | astrogator | 57 | 0 | 3 | 12 | 14 |
| newline_sensitivity | astrogator_configured_heuristics | 56 | 0 | 4 | 12 | 14 |
| newline_sensitivity | Qwen 2.5 1.5B judge | 59 | 23 | 2 | 2 | 0 |
| newline_sensitivity | gpt6 | 58 | 0 | 3 | 25 | 0 |
| newline_sensitivity | opus55 | 61 | 0 | 0 | 25 | 0 |
| newline_sensitivity | always_accept | 61 | 25 | 0 | 0 | 0 |

## Retrospective hybrid policies

Fallback consults the existing judge prediction only on verifier abstentions. Conjunction accepts only when both accept, rejects when either rejects, and otherwise abstains. These are deterministic reanalyses, not extra model calls or matched-cost comparisons.

| Original labels: policy | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---:|---:|---:|---:|---:|
| base_then_gpt6_on_abstention | 57 | 1 | 0 | 28 | 0 |
| heuristics_then_gpt6_on_abstention | 56 | 1 | 1 | 28 | 0 |
| heuristics_and_gpt6 | 56 | 0 | 1 | 28 | 1 |
| base_then_opus55_on_abstention | 57 | 1 | 0 | 28 | 0 |
| heuristics_then_opus55_on_abstention | 56 | 1 | 1 | 28 | 0 |
| heuristics_and_opus55 | 56 | 0 | 1 | 28 | 1 |

This subset does not establish performance over all tasks or production workloads. a01 contains no local failures. See per-task tables and unavailable outcomes before comparing methods.
