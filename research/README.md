# Research — active direction: proof-based verification with Lean

This folder holds the new research direction for the project: verifying LLM-generated code
against a specification with a proof assistant (Lean 4), instead of differential-testing
against a real binary (the v1 approach, now inventoried in `../archive/`).

## The idea in one line

Replace the testing step with a proof step. State "the program behaves exactly like the
spec" as a theorem in Lean, have an LLM generate the proof, and let Lean's kernel check it.
A passing proof covers every input, not just the ones a test suite tried, and the kernel is
the trust anchor: an unreliable LLM cannot fake a proof, because a bad proof fails to check.

## Anchor paper

VERINA: Benchmarking Verifiable Code Generation (arXiv 2505.23135, Ye et al.). Sent by Aaron
as the starting point. VERINA jointly generates code + specification + proof, all in Lean.
Our problem differs in one hard way: the program under verification (a Unix utility like `cp`
or `sudo`) is not written in Lean, so its semantics must first be modeled inside Lean.

## Documents in this folder

- `lean-verification/01_verina_deepdive.md` — what VERINA is, its benchmark, metrics, results
  (notably a very low proof-generation success rate), and what transfers to our problem.
- `lean-verification/02_prior_art_landscape.md` — the LLM-assisted verified-code-generation
  landscape (Dafny, Verus/Rust, Lean, Coq, Isabelle; ATP vs ITP), and the open gap.
- `lean-verification/03_foreign_language_semantics_gap.md` — the crux: how to reason in Lean
  about a non-Lean program (deep vs shallow embedding, non-termination, I/O), Smoosh, and
  what is actually tractable for a first experiment.
- `lean-verification/00_positioning_and_experiment.md` — synthesis: how this relates to
  Astrogator, SLMFix, and v1, plus a concrete first-experiment sketch. (Written last.)
