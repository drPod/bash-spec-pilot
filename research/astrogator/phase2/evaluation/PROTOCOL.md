# Evaluation refinement protocol

This directory preserves new experiments and analyses separately from the original research package. The refinement is informed by the earlier study and its observed weaknesses; it is not a preregistered confirmatory study on an unseen benchmark.

## Measurement units and labels

The corpus slice contains 440 raw attempts on four tasks, 422 processed programs, and 844 original execution cases. A program passes only when both declared states pass. Missing processed artifacts, infrastructure failures, and timeouts are not incorrect-program labels. Ansible execution errors are retained as local failures but separated from behavioral-only failures in analysis.json.

An Astrogator accept is a successful unification under its model, with possible residual assumptions and effects. We export the printed differences but do not claim to discharge them. Unsupported lowering is an abstention. A deployment policy that blocks abstentions is reported separately from a detector that actually rejects a failure.

Verifier mode throughout this comparison is the pinned upstream default permission semantics. The experimental `--constant-modes` guard has its own analysis under `phase2/permission_semantics`; its outcomes are separate from these paired tables.

The original local execution uses Debian. The verifier's model includes other OS contexts. The Debian-metadata arm changes only heuristic metadata rows, keeping all verifier OS branches and original candidate/query bytes. It is a causal metadata ablation, not a fully environment-aligned proof.

## Whole-task oracle refinement

The original password fixture used a placeholder rather than a real password hash, and the marker-only check allowed malformed shadow records. The new version selects every processed a17 program before execution, establishes a valid crypt hash in the baseline, and checks conservative account-record integrity. Both existing-unlocked and existing-locked states remain. This establishes password-hash behavior, not PAM/SSH authentication.

All a06 programs are rerun with their original initial states. Exact bytes and a separate single-final-newline-tolerant creation check are recorded. Existing-file preservation remains exact. Neither interpretation is silently promoted to gold. The original labels and every changed identity remain visible.

The complete new suite is 410 candidate cases and four reference controls. Frozen candidate, runner, and image hashes prevent mixed versions. Reference controls must pass before candidates execute. The same observation supports several explicitly named label interpretations; these are sensitivity analyses, not independent experiments.

## Statistical reporting

Report decision coverage, failing fraction among accepted programs, rejection recall among all local failures, and rejection rate among local passes. These denominators answer different questions. Keep per-task results and undefined rates: a01 has zero local failures and thus no defined failure recall.

The eleven generator-model groups supply descriptive cluster-bootstrap units, preserving within-model program dependence. The four tasks are fixed and selected; these intervals do not support generalization to arbitrary Ansible tasks. A zero-width empirical interval from zero observed failures does not prove zero true risk. No significance tests are claimed.

Structural duplicate analysis removes only inserted top-level play names. Scalar tags, task names, parameters, duplicate mapping keys, and sequence order remain. Equal-cluster weighting gives each conservative structural group total weight one. It is a sensitivity analysis, not semantic equivalence.

## Strong-model comparison

Independent inference is owned by phase2/integration. The original frozen 86-program selection uses sample indices 0/1 across every generator/task cell; a separately frozen extension covers all remaining 336 programs. Evaluation joins by sample identity and candidate/prompt/configuration hashes. No full-slice model metrics are emitted until all 422 selected programs have terminal records. Invalid output, uncertainty, or exhausted infrastructure attempts remain abstentions.

Infrastructure-only retries preserve original attempts and must not select favorable model verdicts. Parent integration records the exact retry policy. Saved task prompts omit outcome labels, oracle source, and reference implementations. Global Claude CLI plugin session hooks remained active despite tool restrictions, so completely empty client context is not established; see the integration audit. Provider token budgets and CLI scaffolding differ; no matched-cost claim is justified.

## Reproduction

- `analyze.py`: selective metrics, generator-cluster bootstrap, residual export.
- `duplicates.py`: conservative YAML structures and equal-structure weighting; run with the existing project virtualenv for PyYAML.
- `run_revised.py`: bounded-container reference controls and whole-task oracle rerun; resume-safe.
- `summarize_revised.py`: explicit label transitions and method sensitivity.
- `debian_heuristics.py`: run inside the lab image; metadata-only actual-verifier ablation.
- `syntax_baseline.py`: run inside the lab image; four reference controls then all 422 native syntax checks.
- `additional_baselines.py`: joins completed conventional and metadata baseline records.
- `frontier_comparison.py --full --bootstrap`: joins the two frozen frontier phases and reports paired results.
- `test_evaluation.py`: targeted checks for abstention, identity normalization, transport invalidation, and malformed account records.

All heavy host analyses use agent-jobs.slice. Candidate execution is restricted to disposable, network-disabled, memory/CPU/PID-bounded Docker containers with the suite mounted read-only. The original source reports and labels are not modified.

## Completed joins and figures

- `compare_checks.py`: matched resolved-label cohort for DSL tests; `--include-python` adds Python only when its full summary is complete. Every resolved execution label must agree with the independent label source. All methods use the same intersection; excluded identities remain explicit.
- `review_disagreements.py`: all strong-model disagreements under every declared interpretation, preserving model reasons as attributed claims.
- `frontier_robustness.py`: strong-model structural-weight and behavioral-only/error-mechanism sensitivity.
- `complementarity.py`: exact strict-label identities uniquely rejected by either approach, separating verifier abstentions; deterministic Debian-heuristic conjunctions are explicitly retrospective.
- `audit_python_checks.py`: nonexecuting source inventory. `PYTHON-CHECK-REVIEW.md` records a manual read of all16 exact source hashes; it is not a general sandbox proof.
- `frontier_comparison.py --arm environment-judge`, then `context_sensitivity.py --arm environment-judge`: the nested86-program environment-context comparison. Only run after all172 terminal predictions exist.
- `plot_evaluation.py`: complete422 primary plots, PNG/PDF/CSV.
- `plot_checks.py` (optionally `--include-python`): separate matched-cohort check plots.
- `plot_pipeline.py`: both complete21-task pipeline guide arms; decision stages are not accuracy on the17 tasks without execution labels.
- `write_findings.py`: concise cross-experiment findings in `phase2/EVALUATION-FINDINGS.md`.
- `audit_evaluation.py`: completion, source identities, metric totals, frozen runner checks, and primary figure hashes.

Plotting uses isolated `uv run --no-project --with matplotlib==3.10.7 python SCRIPT`, with host resource caps and BLAS thread counts set to1. No project dependency file is changed. Each figure directory has the exact plotted CSV, captions, and source/output hashes. End-to-end source artifacts are owned by `phase2/end_to_end`; translations and program-query cells are shared across repetitions and must not be presented as independent problems. Broader supplied-query decision agreement is separate from the four-task bounded correctness experiment.
