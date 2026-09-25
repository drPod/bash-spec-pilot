# What does the verifier add to the strong judges?

Strict-integrity labels on the same422programs. Every identity is retained in JSON. Rejection and abstention are separated.

| Verifier vs judge | Verifier rejects / judge accepts failures | Verifier unavailable / judge accepts failures | Judge rejects / verifier accepts failures | Both accept failures |
|---|---:|---:|---:|---:|
| astrogator vs gpt6 | 1 | 3 | 9 | 0 |
| astrogator vs opus55 | 8 | 1 | 9 | 0 |
| astrogator_configured_heuristics vs gpt6 | 1 | 3 | 0 | 0 |
| astrogator_configured_heuristics vs opus55 | 8 | 1 | 0 | 0 |
| debian_metadata_heuristics vs gpt6 | 1 | 3 | 0 | 0 |
| debian_metadata_heuristics vs opus55 | 8 | 1 | 0 | 0 |

## Complementary rejection identities

- astrogator vs gpt6: `granite/p10/4`.
- astrogator vs opus55: `gpt-5-mini/p13/1`, `gpt-oss/p13/0`, `gpt-oss/p13/1`, `gpt-5-mini/p13/3`, `gpt-5-mini/p13/8`, `gpt-oss/p13/2`, `gpt-oss/p13/9`, `qwen3-coder/p10/5`.
- astrogator_configured_heuristics vs gpt6: `granite/p10/4`.
- astrogator_configured_heuristics vs opus55: `gpt-5-mini/p13/1`, `gpt-oss/p13/0`, `gpt-oss/p13/1`, `gpt-5-mini/p13/3`, `gpt-5-mini/p13/8`, `gpt-oss/p13/2`, `gpt-oss/p13/9`, `qwen3-coder/p10/5`.
- debian_metadata_heuristics vs gpt6: `granite/p10/4`.
- debian_metadata_heuristics vs opus55: `gpt-5-mini/p13/1`, `gpt-oss/p13/0`, `gpt-oss/p13/1`, `gpt-5-mini/p13/3`, `gpt-5-mini/p13/8`, `gpt-oss/p13/2`, `gpt-oss/p13/9`, `qwen3-coder/p10/5`.

## Retrospective conjunction

Reject if either rejects; accept only if both accept; otherwise unavailable. Deterministic retrospective composition of existing predictions; no new inference or equal-cost claim.

| Policy | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---:|---:|---:|---:|---:|
| debian_and_gpt6 | 282 | 0 | 0 | 137 | 3 |
| debian_and_opus55 | 281 | 0 | 1 | 139 | 1 |

These development-suite compositions were examined after seeing outcomes. Zero observed accepted failures is not a validated risk guarantee. The corpus, model budgets, environmental scope, and oracle interpretations remain fixed.
