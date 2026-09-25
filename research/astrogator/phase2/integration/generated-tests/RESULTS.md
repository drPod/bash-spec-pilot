# Frontier-generated declarative checks

Complete: True. 844/844 candidate-state executions; 16/16 check sets pass the reference gate.

| Label interpretation | Test set | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---|---:|---:|---:|---:|---:|
| new_fixture_original_oracle | gpt6-r0 | 281 | 0 | 0 | 139 | 0 |
| new_fixture_original_oracle | gpt6-r1 | 281 | 0 | 0 | 139 | 0 |
| new_fixture_original_oracle | opus55-r0 | 281 | 0 | 0 | 139 | 0 |
| new_fixture_original_oracle | opus55-r1 | 281 | 8 | 0 | 131 | 0 |
| strict_integrity | gpt6-r0 | 280 | 1 | 0 | 139 | 0 |
| strict_integrity | gpt6-r1 | 280 | 1 | 0 | 139 | 0 |
| strict_integrity | opus55-r0 | 280 | 1 | 0 | 139 | 0 |
| strict_integrity | opus55-r1 | 280 | 9 | 0 | 131 | 0 |
| newline_sensitivity | gpt6-r0 | 280 | 1 | 8 | 131 | 0 |
| newline_sensitivity | gpt6-r1 | 280 | 1 | 8 | 131 | 0 |
| newline_sensitivity | opus55-r0 | 280 | 1 | 8 | 131 | 0 |
| newline_sensitivity | opus55-r1 | 288 | 1 | 0 | 131 | 0 |

Completeness above means every selected candidate-state has a terminal record; it does not mean every execution produced a usable label.
- new_fixture_original_oracle: 420/422 programs have resolved labels; 2 unresolved programs are excluded from that metric table, not counted as correct or incorrect.
- strict_integrity: 420/422 programs have resolved labels; 2 unresolved programs are excluded from that metric table, not counted as correct or incorrect.
- newline_sensitivity: 420/422 programs have resolved labels; 2 unresolved programs are excluded from that metric table, not counted as correct or incorrect.

- Declarative read-only check language, not unrestricted Python test generation.
- Known-good reference gate supplies additional information after generation.
- Execution errors reject independently of generated assertions; separate from semantic detection.
- Two complete independently generated test sets per model; no best-of-two selection.
- Password predicate can miss structural damage; strengthened oracle is deliberately separate.
- Tests and independent oracle inspect the same fresh execution, so paired labels need not equal older fixture labels.
- Four original tasks only; passing these checks does not prove universal correctness.
