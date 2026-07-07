# formal-verification

Research repo for Prof. Vikram Adve's group at UIUC, extending Astrogator (formal verification
of LLM-generated code) to Bash utilities. Owner: Aaron Councilman (PhD). Doer: Darsh (undergrad).

## Current direction: proof-based verification with Lean

The central question: can an unreliable LLM produce a machine-checkable proof that a program
behaves according to a specification? Instead of testing a candidate against a real binary and
hoping the untested inputs also match, we state "the program satisfies the spec" as a theorem in
a proof assistant (Lean 4) and have its kernel check the proof. A passing proof covers every
input, and the kernel is the trust anchor: an unreliable LLM cannot fake a proof.

Anchor paper: VERINA (arXiv 2505.23135), which jointly generates code, specification, and proof
in Lean. Our problem differs in one hard way: the programs we care about (Unix utilities like
`cp`, `sudo`) are not written in Lean, so their behavior must first be modeled inside Lean.

The active research lives in `research/lean-verification/`. Start with its `README.md`.

## Layout

- `research/` — the active direction (Lean verification). New work goes here.
- `archive/v1/` — the prior direction (man-page → Rust + differential testing), moved intact.
  See `archive/README.md`.
- `literature/` — shared paper PDFs.

The concrete pipeline for the new direction is still being scoped; this README and the project
`CLAUDE.md` will grow as it firms up.
