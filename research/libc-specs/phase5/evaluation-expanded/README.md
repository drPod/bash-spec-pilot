# Expanded multi-model evaluation (2026-09-07)

Independent redesign of `../evaluation/` (the 12-cell, single-model diagnostic), addressing
its own recorded gaps: ≥3 distinct models, ≥5 attempts/cell, an effective helper ablation (the
prior `partial_error` cell's ablation was ineffective — see `../evaluation/REPORT.md`), bounded
assisted-feedback rounds, and an explicitly-labeled agent-assisted collaborative baseline
(never a human baseline).

## Files

- `protocol.json` — frozen design: tasks, conditions, models, harness settings, controls.
- `make_tasks.py` — generates `tasks/*/{helper,base}.template.lean` + `tasks/manifest.json`
  from `phase5/integration/lean/CalculusNested.lean`. Already run; templates are committed.
- `extract_originals.py` — extracts each target's real (already-checked) proof body into
  `originals/` for checker controls ONLY (never shown to a model).
- `check_attempt.py` — the frozen checker (same 5 gates as `../evaluation/check_attempt.py`,
  adapted for this self-contained single-file module).
- `run_attempt.py` — one bounded, fresh-context model attempt (`pi:xai/grok-4.6`,
  `claude:sonnet`, or `claude:fable`), with optional bounded assisted-feedback rounds.
- `run_matrix.py` — drives the full 90-cell first-pass matrix; resumable/idempotent.
- `run_collaborative.py` — the agent-assisted collaborative baseline (real tool access, bounded
  wall budget, independently rechecked by the same frozen checker).
- `summarize.py` — aggregates `attempts.jsonl` into `results.json` / `RESULTS-SUMMARY.json`.
- `originals/`, `tasks/` — frozen fixtures. `attempts.jsonl`, per-attempt directories, and
  check receipts live OUTSIDE the repository, under
  `~/agent-jobs/astra-research/phase5/claude-resume/evaluation-artifact-4/`.

## Why these three tasks

`CalculusNested.lean` (phase5/integration/lean/) is a hand transcription of the nested-state
fragment of the pinned State Calculus interpreter used by the Aaron-frontend adapter
(`calculus-bytes/`). Its three frame/preservation theorems were NEVER used in the prior
diagnostic (which drew from phase2/phase3 files only) and are self-contained (zero imports),
so the checker needs no cross-project dependency resolution — see `check_attempt.py`'s
docstring. Each task ablates exactly the association-list lemma(s) its target's real proof
actually calls (verified: the base-condition negative control with the ORIGINAL proof rejects
with "build failed" for all three, before any model call), unlike the prior diagnostic's
`partial_error` cell, whose ablation left the real dependency (`execute_contract`) present in
both conditions.

## Frozen experiment

Read [REPORT.md](REPORT.md) and [RESULTS-CORRECTED.json](RESULTS-CORRECTED.json) for the
accepted accounting. The older RESULTS-SUMMARY.json combines different attempt classes.
Do not regenerate these frozen templates from the live development module or rerun model
trials as part of artifact verification. The artifact uses the immutable evaluation archive.

See `REPORT.md` for the results and every limitation.
