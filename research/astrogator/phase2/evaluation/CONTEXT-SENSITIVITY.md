# Environment-context sensitivity

The same 86 identity-selected programs are judged with and without explicit execution-environment context. This subset is nested within the 422-program primary cohort. Each condition has one fresh call, so changes cannot be attributed solely to context rather than sampling variation.

| Original local labels: method/condition | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---:|---:|---:|---:|---:|
| gpt6_original | 57 | 1 | 0 | 28 | 0 |
| gpt6_context | 57 | 3 | 0 | 26 | 0 |
| opus55_original | 57 | 4 | 0 | 25 | 0 |
| opus55_context | 55 | 4 | 0 | 24 | 3 |

Paired discordances, every changed identity, and revised-oracle label sensitivities are in context-sensitivity.json.
