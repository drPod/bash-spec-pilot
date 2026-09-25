# Evaluation evidence index

Start with [the cross-experiment findings](../EVALUATION-FINDINGS.md). The central paper figure combines compiler/effect agreement with actual downstream decision preservation across all21tasks; the correctness comparison remains a separate four-task study.

| Evidence | Main artifact | Data / runnable analysis |
|---|---|---|
| Paper-level formalization intervention | [Main figure PDF](figures-paper/paper-contribution.pdf) | [CSV](figures-paper/paper-contribution.csv), `plot_paper_contribution.py` |
| Full2,238-program pipeline stages | [Pipeline PDF](figures-pipeline/pipeline-stages.pdf) | [CSV](figures-pipeline/pipeline-stages.csv), `plot_pipeline.py` |
| Full422-program strong-model comparison | [Results](FRONTIER-FULL-COMPARISON.md) | `frontier-full-comparison.json`, `frontier_comparison.py --full --bootstrap` |
| Same420-program generated-DSL comparison | [Results](COMMON-DSL-CHECKS.md), [PDF](figures-dsl-checks/matched-checks.pdf) | `common-dsl-checks.json`, `compare_checks.py` |
| Actual verifier contribution beyond judges | [Exact complementarity](COMPLEMENTARITY.md) | `complementarity.json`, `complementarity.py` |
| Oracle integrity and final-newline sensitivity | [Results](ORACLE-SENSITIVITY.md) | `revised-summary.json`, `summarize_revised.py` |
| Metadata-only heuristic intervention and native syntax | [Results](ADDITIONAL-BASELINES.md) | `additional-baselines.json`, `additional_baselines.py` |
| Repetition / error-mechanism sensitivity | [Results](FRONTIER-ROBUSTNESS.md) | `frontier-robustness.json`, `frontier_robustness.py` |
| Exhaustive frontier disagreements | [Reasons](FRONTIER-DISAGREEMENTS.md) | `frontier-disagreements.json`, `review_disagreements.py` |
| Nested86-program environment sensitivity | [Results](CONTEXT-SENSITIVITY.md) | `context-sensitivity.json`, `context_sensitivity.py --arm environment-judge` |
| Actual generated Python source review | [Manual review](PYTHON-CHECK-REVIEW.md) | `python-check-source-inventory.json`, `audit_python_checks.py` |
| Completion / provenance checks | [Audit](audit.json) | `audit_evaluation.py`, `test_evaluation.py` |

The [protocol](PROTOCOL.md) defines denominators, label interpretations, abstention treatment, frozen runners, infrastructure recovery, and limitations. Every figure includes source hashes and captions. No new inference occurs in the analysis scripts. Candidate-running scripts require bounded disposable Docker environments as documented; do not execute candidate playbooks on the host. The original reports and labels remain unchanged.

The final Python/DSL/all-method comparison uses **416 jointly resolved programs**, with six excluded program identities explicitly listed in [COMMON-ALL-CHECKS.md](COMMON-ALL-CHECKS.md). Its [PDF](figures-all-checks/matched-checks.pdf) and [CSV](figures-all-checks/matched-checks.csv) retain all four Python and four DSL repetitions. Opus Python gate abstentions reflect conservative frozen-runner compatibility restrictions and are not counted as detected errors. Candidate timeouts remain unresolved and are not repaired with historical labels.
