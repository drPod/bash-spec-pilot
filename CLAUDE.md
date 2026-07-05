# Project

Research repo, Prof. Vikram Adve's group (UIUC). Extends Astrogator (formal verification of
LLM-generated code) to Bash. Owner: Aaron Councilman (PhD). Doer: Darsh (undergrad).

Direction (as of 2026-07, fresh start): verify LLM-generated code against a spec with a proof
assistant (Lean 4) rather than by differential testing. State "program satisfies spec" as a Lean
theorem; an LLM generates the proof; Lean's kernel checks it. A passing proof covers all inputs;
the kernel is the trust anchor (an unreliable LLM cannot fake a proof). This replaces Astrogator's
bespoke symbolic-execution verifier with an off-the-shelf proof kernel.

Anchor paper: VERINA (arXiv 2505.23135) — jointly generate code + spec + proof in Lean.

## Confirmed constraints (from the literature so far)

- The hard, novel part: our target programs are NOT written in Lean (Bash / real Unix binaries),
  so their semantics must be embedded in Lean before anything can be proved about them. No prior
  system does foreign-non-verification-language embedding this way.
- Lean's logic is total: every function must be proven terminating. Shell programs can loop
  forever, so model execution as an inductive relation (big-step / small-step `Prop`) or with
  fuel / step-indexing, not as a plain total function.
- Auto-proving in Lean is hard: VERINA reports single-digit proof-success pass@1 for code
  correctness; SMT-backed ATP (Dafny, Verus) is far more automatable. Scope first experiments
  accordingly.

## Routing

- Active research + findings: `research/lean-verification/` (read its `README.md` first).
- Prior direction (v1, archived intact): `archive/v1/`. Its `CLAUDE.md` describes the v1 pipeline
  ONLY and does not apply here. Reusable doc mirrors are at `archive/v1/docs/openai/` (OpenAI SDK,
  ground truth, do not WebFetch) and `archive/v1/docs/posix/` (POSIX standard mirror).
- Literature PDFs: `literature/`. Index papers into delphi (`mcp__synsci-delphi__*`, Docker must
  be running) before querying; never paraphrase prior art from memory.

## Conventions (carried over, still in force)

- Model: GPT-5.5 reasoning snapshot. NO `temperature` / `seed` / `top_p` (reasoning model rejects them).
- Python: `uv`. Logging: plain JSONL + git-versioned artifacts, no MLflow/W&B.
- The concrete pipeline for this direction is not designed yet. Do not invent pipeline structure;
  flesh this file out as decisions are made.
