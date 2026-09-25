# Strong-model paired comparison

Frozen selection: 422 processed programs from 440 task/model/index cells; 18 missing processed files. GPT-6 complete: True; Opus 5.5 complete: True.

Saved task prompts omit outcome labels, target solutions, and oracle code; fresh CLI sessions and tool-use checks were used. Global Claude CLI plugin session hooks remained active, so completely empty client context is not established. Inputs and outputs are hash-checked. Original local labels and revised-oracle sensitivities are reported separately. Verifier mode: pinned upstream default permission semantics, with a separate configured-heuristic arm.

| Label variant | Method | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---|---:|---:|---:|---:|---:|
| original | astrogator | 282 | 9 | 1 | 56 | 74 |
| original | astrogator_configured_heuristics | 277 | 0 | 6 | 65 | 74 |
| original | judge | 270 | 129 | 13 | 10 | 0 |
| original | gpt6 | 283 | 3 | 0 | 136 | 0 |
| original | opus55 | 281 | 9 | 2 | 130 | 0 |
| original | always_accept | 283 | 139 | 0 | 0 | 0 |
| new_fixture_old_oracle | astrogator | 282 | 9 | 1 | 56 | 74 |
| new_fixture_old_oracle | astrogator_configured_heuristics | 277 | 0 | 6 | 65 | 74 |
| new_fixture_old_oracle | judge | 270 | 129 | 13 | 10 | 0 |
| new_fixture_old_oracle | gpt6 | 283 | 3 | 0 | 136 | 0 |
| new_fixture_old_oracle | opus55 | 281 | 9 | 2 | 130 | 0 |
| new_fixture_old_oracle | always_accept | 283 | 139 | 0 | 0 | 0 |
| strict_integrity | astrogator | 282 | 9 | 0 | 57 | 74 |
| strict_integrity | astrogator_configured_heuristics | 277 | 0 | 5 | 66 | 74 |
| strict_integrity | judge | 269 | 130 | 13 | 10 | 0 |
| strict_integrity | gpt6 | 282 | 4 | 0 | 136 | 0 |
| strict_integrity | opus55 | 281 | 9 | 1 | 131 | 0 |
| strict_integrity | always_accept | 282 | 140 | 0 | 0 | 0 |
| newline_sensitivity | astrogator | 282 | 9 | 7 | 50 | 74 |
| newline_sensitivity | astrogator_configured_heuristics | 277 | 0 | 12 | 59 | 74 |
| newline_sensitivity | judge | 277 | 122 | 13 | 10 | 0 |
| newline_sensitivity | gpt6 | 283 | 3 | 7 | 129 | 0 |
| newline_sensitivity | opus55 | 289 | 1 | 1 | 131 | 0 |
| newline_sensitivity | always_accept | 290 | 132 | 0 | 0 | 0 |

## Retrospective hybrid policies

Fallback consults the existing judge prediction only on verifier abstentions. Conjunction accepts only when both accept, rejects when either rejects, and otherwise abstains. These are deterministic reanalyses, not extra model calls or matched-cost comparisons.

| Original labels: policy | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---:|---:|---:|---:|---:|
| base_then_gpt6_on_abstention | 282 | 12 | 1 | 127 | 0 |
| heuristics_then_gpt6_on_abstention | 277 | 3 | 6 | 136 | 0 |
| heuristics_and_gpt6 | 277 | 0 | 6 | 136 | 3 |
| base_then_opus55_on_abstention | 282 | 10 | 1 | 129 | 0 |
| heuristics_then_opus55_on_abstention | 277 | 1 | 6 | 138 | 0 |
| heuristics_and_opus55 | 276 | 0 | 7 | 138 | 1 |

This subset does not establish performance over all tasks or production workloads. a01 contains no local failures. See per-task tables and unavailable outcomes before comparing methods.
