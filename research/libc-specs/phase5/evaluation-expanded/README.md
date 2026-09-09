# Expanded multi-model proof-regeneration evaluation

Measure how often recorded model/harness combinations regenerate three held-out Lean nested-state proofs under a frozen checker, with helper ablation and a labeled agent-assisted baseline.

Scored matrix: 23 of 90 accepted after makeup for three checker collisions (original schedule 22/90). Accounting: [`REPORT.md`](REPORT.md), [`RESULTS-CORRECTED.json`](RESULTS-CORRECTED.json). This is Lean-to-Lean regeneration, not script or C generation. The paper’s proof-generation paragraph uses this 23/90 figure ([`../evaluation/DRAFT-PAPER.md`](../evaluation/DRAFT-PAPER.md)).

Model and harness are confounded; five observations per cell; one research program’s theorems. Do not regenerate templates from live `CalculusNested.lean`. Distinct from the earlier 12-call diagnostic in [`../evaluation/`](../evaluation/).

## Files

- `protocol.json` — frozen design: tasks, conditions, models, harness settings, controls.
- `make_tasks.py` — generates `tasks/*/{helper,base}.template.lean` + `tasks/manifest.json` from `phase5/integration/lean/CalculusNested.lean` (already run; templates committed).
- `extract_originals.py` — extracts each target’s checked proof body into `originals/` for checker controls only (never shown to a model).
- `check_attempt.py` — frozen checker (same five gates as `../evaluation/check_attempt.py`).
- `run_attempt.py` / `run_matrix.py` / `run_collaborative.py` / `summarize.py` — harness and aggregation.
- `originals/`, `tasks/` — frozen fixtures. Attempt ledgers live outside the repository under `~/agent-jobs/astra-research/phase5/claude-resume/evaluation-artifact-4/`.

## Why these three tasks

`CalculusNested.lean` is a hand transcription of the nested-state fragment of the State Calculus interpreter. Its three frame/preservation theorems were not used in the 12-cell diagnostic. Each task ablates the association-list lemma(s) the real proof calls (base-condition negative control: original proof rejects with “build failed” for all three). The earlier `partial_error` cell left `execute_contract` present in both conditions (`../evaluation/REPORT.md`).
