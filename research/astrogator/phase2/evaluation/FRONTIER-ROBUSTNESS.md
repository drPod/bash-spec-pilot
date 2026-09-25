# Frontier robustness on original local labels

| Method | Pooled accepted-failure risk | Equal-structure accepted-failure risk | Behavioral-only failures rejected /64 | Execution-error failures rejected /75 |
|---|---:|---:|---:|---:|
| astrogator | 3.09% | 6.47% | 51 | 5 |
| astrogator_configured_heuristics | 0.00% | 0.00% | 60 | 5 |
| gpt6 | 1.05% | 2.24% | 62 | 74 |
| opus55 | 3.10% | 5.91% | 55 | 75 |

233 conservative YAML structures receive equal total weight. This controls one form of repetition, not task selection. Behavioral-only failures exclude any program with an execution error in either scenario; native runtime errors and behavioral failures are not interchangeable. All rates are descriptive, on original local labels.
