# Experiment protocol and scope

This is a development artifact for the resubmission, not a finished paper evaluation.
Experiments use an available quantized Qwen2.5-1.5B-Instruct model. They do not
establish the performance of frontier models, nor settle whether in-context learning
is sufficient in general. No accuracy figure is inferred from verifier acceptance.

## Shared units and denominators

- Task IDs `a01`–`a21` map to the supplied paper order; `legacy_id` maps to archive paths.
- Sample identity is `(model-folder, legacy-task, file-index)`. Index 0 means upstream
  response number 10. Folder labels are not independently verified model snapshots.
- Raw generation attempts: 2,310. Processed artifacts: 2,238. The missing 72 remain
  visible; do not count them as semantic errors without a justified generation policy.
- Distinguish parser failure, semantic lowering failure, unsupported Ansible, verifier
  rejection, residual-dependent acceptance, timeout, and harness failure.
- The original full-corpus verifier sweep uses normalized supplied FQL and the declared
  p17 domain substitution. No heuristic flags are enabled. This is a pinned current-source
  rerun, not a reproduction of a historical paper table.

## Benchmark expansion

The 49 additions are author-designed behavioral challenges, not 49 independently mined
real-world workloads. Each has two initial states, a reference, an intentionally wrong
variant, and independent Python checks. References are run twice to test retained state.
Changed-count idempotence is not evaluated. Mutation rejection demonstrates that a check
can catch its selected bug; it does not prove oracle completeness.

Initial validation uses a disposable Debian 13 container, Ansible core 2.19.11, root, and
no external network. It does not cover Debian 12, Ubuntu, Red Hat, systemd, multiple hosts,
or real controller/remote separation. SysV cron cases exercise real service processes
and boot links inside the container. Offline packages are real locally built .deb files.
An init process reaps terminated daemons. No generated playbook runs on the host.

FQL status and runtime status are independent. Some candidate queries require new
language operations or knowledge entries. Even successfully lowered queries may leave
preservation/negative-action obligations to residual review. A count of runnable tasks
must never be described as a count of fully supported, reviewed formal specifications.

## NL → FQL

Arms: grammar guidance only; guidance plus three demonstrations; same demonstrations
plus a conservative GBNF generation subset. The GBNF is not an equivalent replacement
for the actual parser. Every output is rechecked with upstream's parser, semantic analyzer,
and module-language code generator. Full module lowering is exercised separately by verification.

Demonstrations exclude the target's manually assigned task family. In the revised runs,
the three demonstrations also come from distinct families. The early six-task pilot exposed
an ambiguous slash notation in the guide, which was fixed and tested in separate runs;
its results are not pooled with the revised guide. The same six development tasks remain
in the 21-task sweep. Results are exploratory, not untouched holdout estimates.

Record syntax validity, nonempty output, semantic/codegen success, exact parsed AST match,
and exact semantic AST fingerprint match when fingerprinting is available. Knowledge-base
closures make some semantic fingerprints unavailable. Neither fingerprint mismatch nor
match is a complete semantic-quality evaluation. Empty queries are rejected explicitly.
Timeouts and token-limit truncation stay in the denominator. No output is hand-repaired.

### Grammar audit and diagnostic feedback extension

The original `fql-subset.gbnf` excludes canonical supplied references a11, a16,
a18, and a19. Its results are retained as development observations, not a fair
full-coverage constrained baseline. `fql-subset-v2.gbnf` admits all 21 canonical
references according to an independently parsed GBNF/Lark membership check. The
real upstream parser confirms that quoting/spacing canonicalization preserves
each reference AST. This proves coverage of these examples, not grammar equality.

The corrected-grammar run repeats all 21 tasks. A separate one-retry condition
retains the four already-lowered seed outputs and makes 17 new model calls using
only actual validation diagnostics and the original prompt. It receives no gold
query or correctness label. Report 21 final task outputs and 17 additional calls;
do not count the four retained records as fresh inference. The retry token budget
is 320, so this arm changes both feedback and available inference, not feedback alone.

`fql_json.ml` serializes the upstream semantic AST, materializing knowledge-base
alternatives with stable binders. Normalization flattens sequences, removes End,
renames unknown variables consistently, and sorts supplemental group sets. Eleven
positive/negative controls exercise these rules. Exact normalized effect-tree
agreement is a reproducible proxy; unequal trees may still be equivalent, and
matching a supplied reference does not independently establish user-intent fidelity.
The field-level differences and full effects remain in `fql-effect-comparison.jsonl`.

For publication: independently review requirement-level fidelity; create contrastive
wrong-query cases; split by task family before tuning; use repeated model samples;
measure downstream verification with reviewed versus generated FQL. A parser-success
result alone does not establish that a query preserves user intent.

## Error-detection baselines

1. Direct judge: request + candidate program; structured accept/reject/uncertain response.
2. Generated Python tests: request + public initial-state facts, no reference code or oracle.
   A read-only contract screen rejects unsupported imports, dynamic execution, writes,
   attempted Ansible execution, and programs without assertions. This is not a security
   proof; execution is additionally confined to disposable bounded containers.
3. Generated declarative checks: a separate, restricted baseline where the model chooses
   predicates and expected values from a documented read-only assertion language.
   JSON-constrained output does not imply valid schema or correct tests.
4. Astrogator: supplied or authored FQL plus program, preserving stage failures and residuals.

The synthetic comparison uses six selected task/reference/mutant pairs. The supplied-code
pilot uses sample index 0 from gpt-5-mini and starcoder on a01, a02, a06, a17: eight programs,
selected by identity before measuring execution. Top-level model-identifying play names
are removed only from judge prompts. Actual executed programs remain byte-identical.
Independent checks are the same for both candidate models. Reference solutions also run
on both states. These are test-backed labels for this local environment, not Aaron's
original multi-OS ground truth.

### Frozen four-task full slice

`four-task-full-v1` selects every raw attempt on a01, a02, a06, and a17: 440
attempts, 422 processed candidates, and 18 missing processed files. Eight reference
controls pass before candidate execution. Each candidate executes once in each of
two fresh initial states (844 cases), unlike the older twice-executed pilot. Image,
runner, candidate, fixture, and oracle hashes are frozen. Timeout and infrastructure
errors remain unresolved even if another scenario fails; missing scenarios are pending.

The separate schema-constrained direct judge receives candidate code, request, and
public initial states, with top-level play names anonymized. It never reads execution
labels or reference solutions. `paired_comparison.py` joins exact sample IDs and
verifies candidate byte hashes. It reports decision coverage, agreement with local
checks on decided cases, and a common-decision subset. Unsupported verifier inputs
and uncertain/invalid judge outputs remain distinct abstentions. Pending ordered
prefixes are not random samples and must not support comparative conclusions.

### Gated generated checks on the same slice

`four-task-tests-v1` generates four task-level declarative check sets, with schema
constraints and a 400-token budget, from requests and public initial states only.
Generation reads neither candidate code nor correctness labels. Check-language
validation rejects one artifact; the remaining three reject at least one known-good
reference state. All four task gates therefore abstain: there are no candidate test
executions in this arm and no test accuracy estimate. The failed control outputs
are retained. This gate uses reference information after generation and is an
explicit advantage over ungated tests; it is not pooled with the earlier baseline.

### Retrieval ablation

The two retrieval arms use identical four-shot prompts, a 320-token budget, and
no decoding grammar. They differ only in the available demonstration pool:
20 other original tasks versus those tasks plus 31 lowered expansion candidates.
Lexical TF-IDF cosine retrieval uses natural-language text, excludes the target ID,
and allows same-family examples. The target's reference FQL is never supplied.
This is within-suite development, not a held-out-family generalization estimate.
Expanded demonstration queries lack independent intent review; their validation
status and every selected demonstration ID are retained. Do not pool these arms
with the earlier three-shot family-excluded experiments.

The matched constrained-retrieval extension reuses each expanded-pool prompt's
exact messages and 320-token budget, adding only the corrected v2 grammar. It makes
a fresh single model call per task without a matched random seed. No prior answer,
validation feedback, or reference query is added to the prompt.

### Configured heuristic verifier arm

`heuristic_verification.py` reads the task-to-metadata mapping from the pinned
upstream evaluator without executing that evaluator. It enables users, groups,
packages, non-strict files, reboot, and writes checks, preserving all file hashes
and exact flags per record. Strict-files is not enabled. This is an explicitly
configured current-source arm, not a reconstruction of the paper's unpublished
command line. Its metadata describe upstream environments, not the local container
fixtures; paired disagreements require context review. Base and heuristic results
remain separate, and unsupported inputs remain abstentions in both.

Generated tests run before the independent oracle. A test that rejects a known-good
reference is faulty. A test that accepts the selected wrong program misses that bug.
Execution errors should count as rejected code only under an explicitly declared policy;
missing, invalid, or crashing test artifacts are reported separately from semantic rejection.
Require both initial states to pass for program acceptance. Aggregate per program and
task, not per assertion; avoid treating correlated variants as independent samples.

## Next paper-grade runs

Use Aaron's VM snapshots and independent labels for a paired full-corpus comparison;
freeze module definitions, FQL, heuristic flags, preprocessing and model snapshots.
Compare base and heuristic-enhanced Astrogator separately. Give competing methods the
same environment facts and disclose the reviewed-FQL advantage. Report false accepts,
false rejects, abstention/unsupported coverage, cost and latency; bootstrap by task rather
than by individual generated sample. Have a second reviewer adjudicate disagreements.
Never substitute a model judgment or Astrogator acceptance for the correctness oracle.
