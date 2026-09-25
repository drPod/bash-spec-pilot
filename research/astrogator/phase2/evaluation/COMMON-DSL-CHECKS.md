# Generated checks on a matched comparison cohort

Every method is restricted to the same **420 programs** with resolved execution labels in all included check arms. The separate primary judge/verifier table retains 422 programs. Excluded identities: dsl: qwen3-coder/p05/6, qwen3-coder/p05/7

Verifier mode: pinned upstream default permission semantics. Check repetitions are shown separately; reference gates supply additional information after generation. These are generated postcondition checks on shared researcher-authored fixtures.

| Strict-integrity labels: method | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---:|---:|---:|---:|---:|
| native_syntax | 280 | 134 | 0 | 6 | 0 |
| astrogator | 280 | 9 | 0 | 57 | 74 |
| astrogator_configured_heuristics | 275 | 0 | 5 | 66 | 74 |
| debian_metadata_heuristics | 280 | 0 | 0 | 66 | 74 |
| judge | 267 | 130 | 13 | 10 | 0 |
| gpt6 | 280 | 4 | 0 | 136 | 0 |
| opus55 | 279 | 9 | 1 | 131 | 0 |
| dsl_gpt6-r0 | 280 | 1 | 0 | 139 | 0 |
| dsl_gpt6-r1 | 280 | 1 | 0 | 139 | 0 |
| dsl_opus55-r0 | 280 | 1 | 0 | 139 | 0 |
| dsl_opus55-r1 | 280 | 9 | 0 | 131 | 0 |

All resolved generated-check execution labels match the independent label source under each declared interpretation. This is a consistency check, not proof that either oracle captures all intended behavior. Original and final-newline sensitivity tables are included in the JSON.
