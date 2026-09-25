# End-to-end natural language → FQL → original Astrogator

**Final study has two scopes.** The [all 21-task paired-decision study](ALL-RESULTS.md) applies every model/guide/repeat to all 2,238 processed programs (26,856 logical cells). It measures agreement and coverage relative to supplied queries, with no correctness claim for the 17 tasks lacking execution labels. The [four-task behavioral study](RESULTS.md) uses the 422-program labeled subset and retains all 5,064 logical cells. The [a03 diagnostic](A03-MECHANISM.md) adds two explicitly selected runtime states explaining a query-interpretation failure. These scopes must not be pooled as independent evidence.

## Four-task behavioral study

This experiment evaluates the specification-generation stage on the already frozen four-task execution cohort. It compares the compact guide and source-handbook guide for both frontier models, retaining all three independent translations per task. The pipeline uses the **original pinned verifier, default permission semantics**, not the experimental permission patches.

The target is 5,064 processed program/query cells: 422 programs × 2 models × 2 guide arms × 3 repetitions. The 18 missing processed attempts are retained for each repetition, giving 5,280 total attempt cells. These are **not 5,064 independent programs or tasks**: there are 422 fixed programs nested in four tasks, and each task-level query is shared across its programs.

A supplied-query control uses exactly the same programs and verifier. The supplied FQL is a control, not independently validated gold. Every translated query is used as generated; there is no choice among repeats, oracle-assisted repair, or selection by downstream outcomes. This adds a measured experiment for a previously unevaluated formalizer stage; it does not assume the paper required a perfect formalizer or eliminate the role of user review.

## Stages retained separately

- Generation failure or tool-contaminated output.
- Query parse, empty-query, semantic, or code-generation failure.
- Candidate Ansible lowering failure.
- Verifier rejection.
- Acceptance **with initial-state assumptions and possible residual effects**.
- Missing processed candidate.

Query diagnostics and complete verifier stdout/stderr are stored in content-addressed files. Exact identical query bytes plus identical candidate bytes under identical binary/module hashes share one invocation, while every logical cell remains in the results. Caching does not merge semantically similar queries or rewrite candidate programs.

`frozen-compact.json` and `frozen-handbook.json` are created only after their declared settlement marker. Original model output records are copied into `inputs/`; per-record, query, prompt, source-config, cohort, and runner hashes are retained. The supplied-query control can be computed before generation settles because it does not read generated outputs.

## Interpretation

`RESULTS.md` reports each repeat separately against strict-integrity local labels. `summary.json` also retains original-oracle and newline-sensitivity labels, detailed stage counts, and transitions relative to the supplied-query control. Accepted local failures, rejected local passes, and unavailable programs are separate quantities. The labels are bounded execution checks, not universal correctness judgments.

`TRACES.md` and `traces.json` provide deterministic post-hoc examples, including natural language, generated and supplied queries, concrete candidate source, semantic-effect agreement as a proxy, full residuals, and underlying runtime observations. Trace selection affects presentation only, never inference or scoring. Different semantic trees are not automatically labeled “wrong”; the changed obligations and observed downstream effects need interpretation.

The execution-labeled study has four tasks and cannot establish behavioral accuracy across the whole 21-task benchmark or unseen domains. The separate all 21-task study measures paired decisions only. The handbook exposes existing task-related compiler knowledge. Direct code judges and this pipeline use different inference budgets; a head-to-head result is not an equal-compute comparison.

## Reproduction

1. `freeze.py compact` waits for the compact settlement marker; `freeze.py handbook` requires complete handbook translation summaries.
2. Run `run.py ARM` inside the pinned lab image with the artifact root mounted at `/suite`. It verifies programs symbolically; it never executes candidate playbooks.
3. Run `effects.py compact handbook` in that image for actual semantic-AST diagnostics.
4. Run `summarize.py` and `traces.py` on the host using the project's locked Python environment.

Use the workspace's bounded job slice and explicit Docker limits. Set Docker-client `GOMAXPROCS=2` to avoid exhausting the shared slice's thread budget. `environment.json` identifies the original binary and module hashes. Raw stage errors remain data, not silently repaired predictions.

## Completed all-task extension

`ALL-RESULTS.md` and `all-summary.json` add all 21 original tasks and all 2,238 processed programs: 26,856 logical processed cells across both models, guides and three repetitions, plus 864 missing-attempt cells. This extension measures **paired decisions and availability only**. The main agreement denominator is the 1,528 programs decided by the supplied-query control; its 710 lowering failures are kept separate. The four-task behavioral analysis above remains unchanged and is a subset, not another independent sample.

On that 1,528-program denominator, the compact guide preserves 872/872/949 decisions for GPT and 926/926/926 for Opus. The handbook preserves 1,525 in every GPT repeat and 1,469 in every Opus repeat. GPT's remaining differences are one acceptance-to-rejection and two rejection-to-acceptance changes; Opus additionally has 57 unavailable programs. These are agreements with a control, not correctness rates. The four-task behavioral cohort has identical decisions under all generated-query arms: 348 decisions, nine accepted strict local failures, no rejected strict local passes, and 74 unavailable programs per repetition.

The all-task comparison retains the supplied and generated queries verbatim. An earlier corpus sweep substituted the a18/p17 URL domain from `example.com` to `acc240.com` to match processed candidate files. Consequently nine earlier acceptances become rejections under the present verbatim supplied control (900 acceptances and 628 rejections). Those nine differences are recorded separately and are not attributed to translation.

`A03-MECHANISM.md` traces a successful but unintended query interpretation through actual verification and bounded Ansible execution. The compact translation of contents deletion becomes directory deletion; the source-handbook translation restores the intended target. This diagnostic was selected after observing a disagreement and does not extend the corpus's behavioral labels.

`AUDIT.json` and `ALL-AUDIT.json` validate every cell identity, frozen source/output hash, candidate hash and referenced verification-cache key. Reproduction of the settled handbook uses `freeze_handbook.py` and `freeze_all_handbook.py`: the actual final marker is `phase2/integration/translation-summary.json`. These separate launchers preserve the already-frozen compact launcher bytes. Use `freeze_all.py compact-all`, `run.py ARM`, `summarize_all.py compact-all handbook-all`, and `audit_all.py` for the broader extension. `traces_all.py` retains descriptive examples without assigning new truth labels.
