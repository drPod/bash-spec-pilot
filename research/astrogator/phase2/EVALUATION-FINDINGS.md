# Evaluation findings for the resubmission

**Compiler-grounded guidance substantially improves the preservation of verification decisions across all 21 tasks.** The contribution is an end-to-end natural-language-to-FQL study with actual downstream verification, complemented by a bounded correctness comparison against strong judges and generated checks. Agreement with supplied queries is separated from correctness.

Correctness-comparison scope: all 422 processed programs on a01, a02, a06, and a17; 18 missing processed artifacts remain excluded. Execution uses Debian 13 / Ansible-core 2.19.11. Verifier results use upstream commit `7c62afa51986d87033af5112cdccd3b104b1c120`, **default permission semantics**, and separately named heuristic configurations. The experimental constant-mode guard has a separate evaluation.

## End-to-end research question

Across the 21-task benchmark, the compact guide compiles 36/63 GPT queries and 33/63 Opus queries; the compiler-grounded handbook compiles 63/63 and 60/63. Normalized reference-effect agreement improves from 27/63 for each model to 53/63 GPT and 57/63 Opus. These are three generations per task, not 63 independent problems. The handbook changes information content and prompt length, and draws on task-related source knowledge; it is not an unseen-domain or equal-token comparison.

The actual downstream comparison evaluates 2,238 processed programs, retaining each of three repetitions. On the same 1,528 programs decided by the verbatim supplied-query control, compact GPT preserves 872/872/949 decisions and compact Opus preserves 926/926/926. Handbook GPT preserves 1,525/1,525/1,525, with zero losses to unavailability and three decision flips per repetition; handbook Opus preserves 1,469/1,469/1,469, with 57 losses and two flips per repetition. Flips are not automatically errors or corrections. The other 710 supplied-query-unavailable programs remain visible in the full-corpus stage table. Nine a18 control differences from the older corpus sweep arise from that sweep’s domain substitution and are recorded separately.

A concrete counterexample shows why compiler success alone is insufficient. For “delete the contents of the directory,” compact GPT generates `delete contents of directory at /home/mydata/web`, which the original semantic analyzer interprets as deleting the directory itself. This changes 43 supplied rejections to acceptance and 13 acceptances to rejection on a03. The deliberately selected `deepseek/p15/0` actually removes the containing directory in both frozen diagnostic states, despite successful execution. The compact query accepts it; the supplied query and all six handbook translations reject it. This is one post-hoc mechanism counterexample, not a newly labeled 110-program task. Runtime checks support relevant Debian-branch assumptions without proving the entire residual abstraction. See [the mechanism and execution evidence](end_to_end/A03-MECHANISM.md).

See the [main paper figure](evaluation/figures-paper/paper-contribution.png), its [PDF](evaluation/figures-paper/paper-contribution.pdf), [plotted CSV](evaluation/figures-paper/paper-contribution.csv), and [all-task results](end_to_end/ALL-RESULTS.md).

Can an LLM produce a formal query that preserves useful verification, and how does that pipeline compare with direct judgment and generated tests? In the completed compact-guide arm, both models produce the supplied queries for all four selected tasks in every one of three repetitions. Consequently all six 422-program runs preserve the supplied-query decisions: 348 decisions, 74 unavailable, nine accepted strict-integrity failures, and no rejected strict-integrity passes. The 2,532 program/query cells reuse 422 programs and 24 task-level translations; they are not independent examples. This is a null translation effect on a narrow cohort, not evidence of general translation faithfulness. Both guide arms preserve the same decisions on this four-task cohort; the broader 21-task losses above would be invisible if evaluation stopped here. No execution labels are invented for the other seventeen tasks.

The supplied-query base pipeline accepts nine locally failing programs; the stronger GPT judge accepts four under strict-integrity labels with full decision coverage. The verifier with Debian-scoped heuristic metadata accepts no observed local failures but leaves 74 programs unavailable. Thus selective reliability, coverage, and model assumptions must be stated together. A blanket claim that formal verification beats frontier models is unsupported by this cohort.

See [end-to-end results](end_to_end/summary.json) for each model and repetition. Supplied queries are controls, not independently validated gold.

## Findings supported by completed experiments

- **Five apparent heuristic false alarms were metadata-scope disagreements.** Restricting only heuristic metadata to Debian rows flips exactly five `www-data` programs from rejection to acceptance across all 422 programs; every other decision is unchanged. Verifier OS branches remain unchanged. This tests the scope explanation directly, rather than relabeling cases by inspection.
- **One original passing label admitted corrupt account data.** `granite/p10/4` writes an eleven-field shadow entry, including a hash in an aging field. All 106 password-task programs were rerun with a verified real hash and a declared account-integrity check. The real hash alone changes no labels; structural integrity changes exactly this program from pass to fail. The change is an outcome-informed oracle refinement requiring human review, not new gold evidence.
- **A final newline changes eight apparent errors.** All 99 conditional-file programs were rerun. Allowing one final LF only when creating the file changes eight failures to passes; existing-file preservation remains exact. Seven of those programs are verifier rejections and one is unsupported. This interpretation creates seven apparent false alarms, so neither interpretation should silently replace the other.
- **Semantic detection is different from syntax checking and abstention.** Native Ansible syntax checking rejects six of 139 original local failures. Of 64 programs failing only behavioral checks, base Astrogator rejects 51 and configured heuristics reject 60. All 74 unavailable verifier programs fail locally; blocking them is a deployment policy, not proof that the verifier rejected their behavior.
- **Repeated easy programs inflate pooled agreement.** Conservative YAML normalization leaves 233 structures from 422 programs. Giving each structure total weight one changes base accepted-failure risk from 3.1% to 6.5%, and the small judge's from 32.3% to 44.1%. The easy directory-creation task has no local failures. Per-task, leave-one-task-out, and generator-cluster analyses are preserved.

The 410 repeated candidate-state observations exactly reproduce the old-oracle case classifications: 177 passes, 86 behavioral rejections, and 147 execution errors. Four known-good controls pass. Two Docker startup failures were retried under a recorded infrastructure-only policy; original attempts remain available.

## Full paired comparison

Original declared local checks: 283 passing and 139 failing programs. “Unavailable” includes unsupported lowering and invalid/uncertain model decisions.

| Method | Failing / accepted | Failing rejected | Passing rejected | Unavailable |
|---|---:|---:|---:|---:|
| Ansible syntax check | 133 / 416 | 6 | 0 | 0 |
| Astrogator base | 9 / 291 | 56 | 1 | 74 |
| Astrogator + supplied all-OS heuristics | 0 / 277 | 65 | 6 | 74 |
| Astrogator + Debian-only heuristic metadata | 0 / 282 | 65 | 1 | 74 |
| Qwen 2.5 1.5B judge | 129 / 399 | 10 | 13 | 0 |
| GPT-6 Astra judge (requested model) | 3 / 286 | 136 | 0 | 0 |
| Opus 5.5 judge | 9 / 290 | 130 | 2 | 0 |

The apparent ranking is interpretation-sensitive: under final-newline sensitivity Opus has one accepted failure and one rejected pass, while GPT has three accepted failures and seven rejected passes. Under strict-integrity labels those counts are Opus nine/one and GPT four/zero. These are alternative declared interpretations, not an oracle chosen to favor a model. The same predictions are also scored under both revised interpretations, with all changed identities retained. The full tables include deterministic judge-on-abstention and conjunction policies; these are retrospective compositions, not extra inference experiments. Saved task prompts omit outcome labels and oracle code, but global Claude CLI session hooks remained active; completely empty client context is not established. Provider inference budgets differ.

## What verification adds beyond a strong judge

Under strict-integrity labels, the base verifier and both heuristic configurations reject one GPT-accepted failure: `granite/p10/4`, the malformed eleven-field shadow entry. Three other GPT-accepted failures are verifier-unavailable, so blocking them must not be described as verifier detection. Against Opus, verification rejects eight accepted failures: seven final-newline cases and `qwen3-coder/p10/5`, which sets an empty password. The seven newline cases cease to be failures under the explicitly reported tolerant interpretation. Both strong judges reject all nine failures accepted by the base verifier.

A retrospective conjunction of Debian-scoped heuristics and GPT accepts all 282 strict-integrity passes, accepts no observed failures, rejects 137 failures, and leaves three unavailable. This is a deterministic policy examined after seeing outcomes, not a prospectively validated system or a zero-risk guarantee. The corresponding Opus conjunction accepts 281 passes, rejects one pass and 139 failures, and leaves one unavailable. See [identity-level complementarity](evaluation/COMPLEMENTARITY.md).

Concrete reasons explain why local counts are not human truth. GPT accepts `starcoder/p13/8` despite a failed final assertion because the desired file state exists; our execution policy counts the failed run. GPT accepts `granite/p10/5` because it considers the incomplete crypt hash unusable, whereas the declared oracle requires a lock marker. Opus interprets “disable password” as deleting the password in `qwen3-coder/p10/5`; the declared oracle requires locking password authentication instead. The reasons are recorded model text, not independently validated security judgments. All disagreement identities and prediction sources are preserved in [the review table](evaluation/FRONTIER-DISAGREEMENTS.md).

## Generated checks on a matched cohort

All methods are compared on the same 420 programs with resolved generated-check execution labels. Two programs with persistent harness failures are excluded from every method in this table, while the primary comparison above retains 422. Three of four DSL check repetitions accept one strict-integrity failure and reject 139; Opus r1 accepts nine and rejects 131. All four accept all 280 locally passing programs. The repetitions are reported separately, without best-of selection. These are generated postconditions on researcher-authored fixtures, with reference gates after generation; they do not automate fixture discovery.

See [matched comparison](evaluation/COMMON-DSL-CHECKS.md) and [Python source review](evaluation/PYTHON-CHECK-REVIEW.md). The source review identifies check incompleteness, including weak preservation checks and missing shadow-field integrity.

## Executed Python-generated checks

The completed Python and DSL arms are compared with every other method on the same 416 programs, the intersection with resolved labels in both execution runs. The table below retains every Python generation repetition under strict-integrity labels; the full matched table includes all methods.

| Python check repetition | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---:|---:|---:|---:|---:|
| python_gpt6-r0 | 276 | 1 | 0 | 139 | 0 |
| python_gpt6-r1 | 276 | 1 | 0 | 139 | 0 |
| python_opus55-r0 | 200 | 0 | 0 | 11 | 205 |
| python_opus55-r1 | 218 | 16 | 0 | 76 | 106 |

These programs were generated from researcher-authored task/scenario descriptions and subjected to reference gates. Opus r0 has 205 gate-based abstentions and r1 has 106: stdout/stderr writes trigger a conservative generic call restriction, and variable-based getent arguments fail literal validation. These are frozen-runner compatibility limits, not demonstrated semantic failures; the gates were not relaxed after outcomes. Candidate execution timeouts leave labels unresolved and are excluded from every method in the joint cohort; the frozen policy does not retry them as infrastructure failures or borrow historical labels. Descendant cleanup can extend inner timeout wall time, with a 110-second outer container cap. They do not establish independent fixture generation or comprehensive correctness. See [all-method matched results](evaluation/COMMON-ALL-CHECKS.md), [matched figure](evaluation/figures-all-checks/matched-checks.png), and the exact-source review above.

## Environment-context sensitivity

On the same nested 86-program identity slice, explicit execution context changes GPT from one to three accepted original-label failures and Opus from zero to three unavailable judgments, with four accepted failures unchanged. These are one-call-per-condition observations; context and sampling variability cannot be separated. They do not establish that context hurts model quality. All changed identities and both oracle sensitivities are in [the context comparison](evaluation/CONTEXT-SENSITIVITY.md).

## Defensible claim

On this fixed development slice, the package makes disagreement sources auditable and tests whether different methods provide complementary coverage. It does **not** establish general Ansible accuracy, independently reviewed gold specifications, or unconditional correctness from `VERIFIED`. Printed residual obligations remain conditional; zero observed accepted failures is not proof of zero true risk. Provider inference budgets differ. Four selected tasks cannot establish unseen-task generalization.

See [paired results](evaluation/FRONTIER-FULL-COMPARISON.md), [oracle sensitivity](evaluation/ORACLE-SENSITIVITY.md), [conventional and metadata baselines](evaluation/ADDITIONAL-BASELINES.md), and [protocol](evaluation/PROTOCOL.md).
