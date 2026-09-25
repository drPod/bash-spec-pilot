# Generated checks on a matched comparison cohort

Every method is restricted to the same **416 programs** with resolved execution labels in all included check arms. The separate primary judge/verifier table retains 422 programs. Excluded identities: dsl: qwen3-coder/p05/6, qwen3-coder/p05/7; python: qwen2.5-coder/p05/3, qwen2.5-coder/p05/4, qwen2.5-coder/p05/7, qwen2.5-coder/p05/8

Verifier mode: pinned upstream default permission semantics. Check repetitions are shown separately; reference gates supply additional information after generation. These are generated postcondition checks on shared researcher-authored fixtures.

| Strict-integrity labels: method | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---:|---:|---:|---:|---:|
| native_syntax | 276 | 134 | 0 | 6 | 0 |
| astrogator | 276 | 9 | 0 | 57 | 74 |
| astrogator_configured_heuristics | 271 | 0 | 5 | 66 | 74 |
| debian_metadata_heuristics | 276 | 0 | 0 | 66 | 74 |
| Qwen 2.5 1.5B judge | 263 | 130 | 13 | 10 | 0 |
| gpt6 | 276 | 4 | 0 | 136 | 0 |
| opus55 | 275 | 9 | 1 | 131 | 0 |
| dsl_gpt6-r0 | 276 | 1 | 0 | 139 | 0 |
| dsl_gpt6-r1 | 276 | 1 | 0 | 139 | 0 |
| dsl_opus55-r0 | 276 | 1 | 0 | 139 | 0 |
| dsl_opus55-r1 | 276 | 9 | 0 | 131 | 0 |
| python_gpt6-r0 | 276 | 1 | 0 | 139 | 0 |
| python_gpt6-r1 | 276 | 1 | 0 | 139 | 0 |
| python_opus55-r0 | 200 | 0 | 0 | 11 | 205 |
| python_opus55-r1 | 218 | 16 | 0 | 76 | 106 |

All resolved generated-check execution labels match the independent label source under each declared interpretation. This is a consistency check, not proof that either oracle captures all intended behavior. Original and final-newline sensitivity tables are included in the JSON.

Python gate abstentions are distinct from the four unresolved execution-timeout programs excluded above. Opus r0 is unavailable on205resolved programs because a06r0 and a17r0 are ineligible; Opus r1 is unavailable on106because a17r1 is ineligible. These are conservative runner restrictions: a06r0 writes only stdout/stderr but triggers the generic forbidden-call gate; the a17 checks use variables in otherwise read-only getent arguments, rejected by literal-argument validation. The exact-source review found no explicit tested-state mutation. Thus these counts are compatibility limits of this frozen test runner, not demonstrated semantic failures of the generated tests. The gates were not relaxed after outcomes.
