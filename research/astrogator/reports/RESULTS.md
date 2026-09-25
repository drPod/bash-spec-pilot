# Astrogator resubmission: working results

**70 task records; 49/49 new reference solutions validated; 49/49 selected wrong variants caught.**

This package covers all three requested workstreams. It is a reproducible development study, not a publication-ready claim of general accuracy. The current model experiments use a local quantized Qwen2.5-1.5B-Instruct model; one sample per condition.

## 1. Benchmark expansion

The original 21 tasks are preserved. The 49 additions span 8 families and include a reference playbook, candidate FQL, two initial-state scenarios, independent state checks, and one deliberate semantic fault each.
References pass in 98 task/scenario combinations, with two executions per passing combination. Each of 49 selected wrong variants fails in at least one scenario. Runtime validation is Debian 13 / Ansible core 2.19.11 only.

| Family | New tasks |
|---|---:|
| archives | 2 |
| configuration | 10 |
| filesystem | 15 |
| identity | 11 |
| packages | 4 |
| scheduling | 1 |
| services | 3 |
| version-control | 3 |

**FQL support is a separate gate:** all 21 supplied queries pass the parser, semantic analyzer and module-language code generator; 31/49 new candidate queries do. Lowering is not proof that a query captures all stated obligations. The other candidates expose capability gaps rather than silently counting as supported Astrogator benchmarks.

Notable gaps include links, regex replacement/removal, supplemental-membership updates, generic package/service knowledge, service enablement, scheduling, and archives. Existing FQL also leaves many preservation and negative-action obligations to residual review.

[Browse every task and its status](review.html). [Raw execution results](expansion-execution.jsonl), [environment-fix and additional-task results](expansion-execution-v2.jsonl), [FQL diagnostics](fql-queries.jsonl).

## 2. Natural language → FQL

| Run / condition | N | Parsed | Semantic + codegen | Exact parsed AST match | Normalized effect match |
|---|---:|---:|---:|---:|---:|
| qwen-diverse-pilot/fql-3shot | 6 | 5 | 3 | 1 | 1 |
| qwen-diverse-pilot/fql-3shot-constrained | 6 | 6 | 3 | 1 | 1 |
| qwen-full/fql-0shot | 21 | 3 | 0 | 0 | 0 |
| qwen-full/fql-3shot | 21 | 8 | 4 | 2 | 2 |
| qwen-full/fql-3shot-constrained | 21 | 20 | 5 | 2 | 2 |
| qwen-grammar-v2-repair/fql-3shot-constrained-repair1 | 21 | 19 | 6 | 1 | 1 |
| qwen-grammar-v2/fql-3shot-constrained | 21 | 18 | 4 | 1 | 1 |
| qwen-local-pilot/fql-0shot | 6 | 0 | 0 | 0 | 0 |
| qwen-local-pilot/fql-3shot | 6 | 4 | 2 | 1 | 1 |
| qwen-retrieval-expanded-constrained/fql-4shot-retrieved-constrained | 21 | 21 | 9 | 7 | 7 |
| qwen-retrieval-expanded/fql-4shot-retrieved | 21 | 13 | 9 | 7 | 7 |
| qwen-retrieval-original/fql-4shot-retrieved | 21 | 14 | 9 | 6 | 6 |

**Grammar audit:** v1 admits only 17/21 canonical reference queries and excludes a11, a16, a18, a19. Its constrained results are development observations. Corrected v2 admits all 21, with canonical formatting independently checked to preserve the actual parser AST. Coverage of these references does not prove equivalence to the parser grammar.

**Diagnostic retry:** the v2 repair arm retains four valid seed outputs and makes 17 additional calls with actual machine diagnostics, no reference FQL. Its 21 records are final task outputs, not 21 fresh calls. It raises lowering success from 4 to 6, while normalized semantic effect matches remain 1. The retry also uses a larger token budget, so this is not a feedback-only ablation.

Normalized effect matches use a readable upstream semantic-AST serializer with eleven positive/negative controls. They are a proxy, not a proof of semantic equivalence or independent intent fidelity. [Inspect the actual effects and differences](fql-effect-comparison.jsonl).

**Larger comparison:** all 844 state executions for the frozen 422-program slice are complete, with 283 programs passing both local checks and 139 failing execution or a check. Eight reference controls pass. All judge and configured heuristic outputs are complete. [Full paired comparison](COMPARISON.md) includes per-task results, coverage, and the environment/oracle disagreements.

**Matched retrieval/grammar result:** the expanded retrieval pool gives 13/21 parsed, 9/21 lowered, and 7/21 normalized effect matches. Adding v2 constraints to the same prompts gives 21/21 parsed, with the other counts unchanged. Original-only retrieval gives 6/21 effect matches; the one-match difference is exploratory, not a reliable gain estimate.

**Configured heuristic sweep:** 183 of the base verifier’s 909 accepts become heuristic rejections; 726 remain accepted with possible residuals. Other stage counts are unchanged. Exact flags and metadata hashes are recorded. [Paired comparison and environment-scope caveats](COMPARISON.md).

**End-to-end transfer is complete:** repaired queries were applied to all 2,238 processed programs. Invalid generated queries block 1,590; the six lowered queries cover 648. Relative to supplied queries, 125 programs change from acceptance to rejection and three change the other way. These are outcome changes, not accuracy. [Concrete semantic differences and transfer results](TRANSLATION-REVIEW.md).

**Generated-check reference gate:** one of four new task-level check sets is invalid; the other three reject known-good reference states. This gated arm abstains across the four-task slice, with no candidate test executions and no test accuracy estimate. The gate uses reference information after generation and is separate from ungated baselines. [Control evidence](../experiments/four-task-tests-v1/gates.json).

[Review local-oracle disagreements before interpreting comparison labels](DISAGREEMENTS.md).

The earlier three-shot demonstrations exclude the target task family; revised three-shot runs also use distinct demonstration families. Retrieval arms instead allow same-family examples and exclude the target task ID. Original-only and expanded-pool retrieval use the same four-shot format and token budget. Expanded candidate demos are not independently reviewed gold. A conservative GBNF subset constrains the final arm; all outputs still go through the actual upstream parser. Early six-task runs are development runs and are not pooled with the revised full sweep.

**Finding:** syntactic validity and intent preservation are different. In the early pilot, the generated `if os is Debian then reboot` passed lowering but omitted “if it is needed.” In the full constrained run, the one unparsable output hit the token limit mid-string; constraints do not guarantee a complete output within a finite token budget. Exact AST match is a useful reproducible proxy, not a complete semantic-equivalence metric. The current outputs require requirement-level review before being designated correct translations.

[Every request and response](../experiments/). [Machine-readable translation checks](fql-translations.jsonl).

## 3. Error-detection comparisons

### Full supplied corpus: actual verifier rerun

| Outcome | Count |
|---|---:|
| accepted_with_possible_residuals | 909 |
| ansible_lowering_error | 710 |
| missing_processed | 72 |
| verification_rejected | 619 |

These are outcomes, **not accuracy**. Acceptance may carry residual assumptions/actions. The pinned upstream revision differs from the historical paper version; no heuristics were enabled. The 72 missing processed files remain explicit.

### Complete four-task slice: 422 processed programs

The base verifier accepts 282 local passes and 9 local failures, rejects 1 local pass and 56 local failures, and cannot lower 74 programs. With configured heuristics, the counts are 277, 0, 6, and 65 respectively, with the same 74 unsupported inputs. Five additional local-pass rejections involve www-data and the upstream Red Hat metadata; the remaining rejected local pass exposes a narrow shadow-file oracle.

The small-model judge accepts 270 local passes and 129 local failures, and rejects 13 local passes and 10 local failures. All four newly generated task-level check sets fail the reference gate, so that arm abstains for all 422 candidates. These are local-check agreement counts, not universal correctness or frontier-model results.

[Paired tables, per-task breakdowns, CSV, and scope caveats](COMPARISON.md).

### Earlier eight-program development pilot

Fixed selection: sample index 0 for gpt-5-mini and starcoder on directory creation, directory deletion, conditional file creation, and password disabling. All four supplied references pass both local initial states. Labels below are only for this declared environment and oracle.

| Sample | Local label | Astrogator | LLM judge | Generated checks |
|---|---|---|---|---|
| gpt-5-mini/p01/0 | correct | accept | accept | reject |
| gpt-5-mini/p05/0 | correct | accept | accept | reject |
| gpt-5-mini/p10/0 | correct | accept | accept | accept |
| gpt-5-mini/p13/0 | correct | accept | accept | invalid_or_unavailable |
| starcoder/p01/0 | correct | accept | accept | reject |
| starcoder/p05/0 | correct | accept | accept | reject |
| starcoder/p10/0 | correct | accept | accept | accept |
| starcoder/p13/0 | incorrect | unsupported_or_error | invalid | invalid_or_unavailable |

The StarCoder conditional-file candidate adds a newline through `echo`; the local oracle follows the reference’s exact `beginning` bytes. Astrogator cannot lower its shell module. Treat this as a scoped disagreement, not evidence of general superiority.

### Six controlled task/reference/mutant pairs

| Method | Correct accepted | Correct rejected | Incorrect accepted | Incorrect rejected | Unresolved |
|---|---:|---:|---:|---:|---:|
| astrogator | 1 | 1 | 1 | 1 | 8 |
| judge | 6 | 0 | 6 | 0 | 0 |
| checks | 0 | 2 | 0 | 2 | 8 |
| checks-0shot-schema | 0 | 4 | 0 | 4 | 4 |
| tests | 0 | 1 | 0 | 1 | 10 |

Each method sees six correct references and six selected wrong variants. Unsupported formal features and invalid test artifacts remain unresolved, not automatic semantic rejections. Generated Python tests and generated declarative checks are distinct baselines; schema-constrained checks are a separate development arm. Tests receive no reference solution or independent oracle.

**Finding:** generated tests must themselves be validated. The small model sometimes checks the initial state instead of the required final state, asserts incompatible conditions, or tries to execute Ansible again. Rejecting a good reference is a test-quality failure, not evidence that the reference is wrong.

### Concrete specification-review cases

The base verifier accepts both the reference and selected wrong variant on a25 (overwriting an initialized config), a44 (removing a home that should remain), a46 (destroying a retained password hash), a61 (changing an existing group GID), a64 (recursively changing child ownership), a68 (creating a cache without its marker), and a70 (copying the enclosing directory rather than its contents). Independent execution checks distinguish each pair. These are specification/model/residual-review cases, not a claim that the formal verifier is unsound. The candidate query may omit an obligation, and the verifier may report extra effects or assumptions. All residual traces are retained in `expansion-verifier.jsonl`.

## Reproducibility and limits

- Upstream: `counc009/state_based`, commit `7c62afa51986d87033af5112cdccd3b104b1c120`; source archive retained.
- Three explicit OCaml String compatibility shims; 678 bounded checks against an independent Python oracle pass. No verifier algorithm or module model was changed.
- Original source files remain byte-identical. CSV normalization and the p17 domain substitution are documented. File index 0 maps to response number 10.
- Eight processed files fail plain PyYAML construction; most involve custom tags. These are not automatically YAML syntax failures or invalid Ansible.
- The expanded verifier adapter removes only `gather_facts: false`, unsupported by the upstream parser; all task bodies remain unchanged. The as-given failures are retained.
- Early package fixtures lacked python3-apt; these failures were fixed in the image and rerun. A stopped-daemon zombie issue was fixed using Docker init. Raw failed runs remain available.
- No human-independent review, multi-OS execution, frontier-model comparison, or original full-corpus accuracy claim is complete.

[Reproduce the work](../README.md). [Full protocol](../experiments/protocol.md). [Machine-readable summary](summary.json).
