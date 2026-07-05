# Archive — prior research direction (v1)

The project's first direction now lives, in full, under `v1/`. It was moved here as one unit,
so every internal relative path is preserved and the tooling still runs (see below). This is a
git-tracked move, fully reversible.

## v1: man-page → Rust + differential testing (2026-05 to 2026-07)

Central question of v1: can an unreliable LLM turn a frozen Linux man page into a reliable
specification of a Bash utility? Method: generate a Rust reference implementation plus a Bash
test suite from the man page, differential-test both against the real GNU binary in a Debian
trixie container, and catalog the failure modes. Rust stood in for a not-yet-existent Bash
spec language. The research output was a failure taxonomy, not a score.

A later sub-thread mined divergences between the man page and the POSIX standard directly
(the "M-vs-POSIX" engine): ~185 divergences across 45 utilities, omission-dominant (~85%).

## Layout under `v1/`

- `v1/runs/` — all experiment outputs (per-util / per-session / per-round) plus the loose
  findings write-ups `_claude_sweep_*.md`, `_posix_divergence_catalog_*.md`,
  `_claude_round2_adversarial_*.md`.
- `v1/scripts/` — freeze → generate → test → classify pipeline.
- `v1/prompts/`, `v1/tests/`, `v1/utils/` — prompt templates, metamorphic properties, frozen man pages.
- `v1/dashboard/` + `v1/.streamlit/` — Streamlit app over the runs.
- `v1/docs/` — `openai/` and `posix/` doc mirrors (still authoritative if the new direction
  reuses them), plus `research/` (decisions log, failure taxonomy, setup, adversarial prior art).
- `v1/CLAUDE.md`, `v1/README.md`, `v1/AGENTS.md` — v1 project docs. The v1 `CLAUDE.md` routing
  describes the v1 pipeline only; it does not apply to the new direction.
- `v1/pyproject.toml`, `v1/requirements.txt`, `v1/uv.lock`, `v1/.venv/` — the v1 Python env.

## Running v1 tooling after the move

Run from inside `archive/v1/` (the dashboard computes its paths from its own file location, so a
unit move keeps them valid). If the venv needs rebuilding: `cd archive/v1 && uv sync`.

## Why the pivot

v1 verified behavior by testing, which only certifies the finite inputs actually tried. The new
direction replaces testing with machine-checked proof: state "the program satisfies the spec" as
a theorem and have a proof assistant (Lean) check it, so a passing proof covers all inputs. It
also swaps Astrogator's bespoke symbolic-execution verifier for an off-the-shelf proof kernel.

Active direction and its research: `../research/lean-verification/`.
