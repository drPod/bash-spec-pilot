# pipeline

LLM-in-the-loop verification pipeline: an LLM writes a Lean 4 model of a Unix
utility together with a specification and proofs; Lean's kernel checks the
proofs; the compiled model is then run differentially against the real GNU
binary. The method is general (any terminating program P and property q); the
coreutils targets here are the first instance set.

## Two-layer trust

1. **model ⊨ spec** (proven). `lake build` type-checks the generated proofs;
   an axiom gate (`#print axioms`) confirms nothing beyond core axioms
   (`propext`, `Classical.choice`, `Quot.sound`) was smuggled in. An
   unreliable LLM cannot fake this layer.
2. **model ≈ binary** (tested). The trusted `Main.lean` shim compiles the
   generated `run` function into an executable, and `validate.py` runs it
   against the GNU binary on seeded random inputs.

A kernel-accepted model that diverges from the binary is a finding, not a
failure: the proofs hold about the model, and the differential layer shows
where the model misreads the documented behavior. Example: gpt-5.6-luna's
first uniq attempt proved its spec but deduplicated non-adjacent lines
(64.5% fidelity, `runs/uniq/2026-07-16T07-32-42Z`).

## Contract

Every generated module defines

```lean
Pipeline.Generated.run : List String → List String → List String × UInt32
```

mapping (argv, stdin lines) to (stdout lines, exit code), plus 3-6 proved
spec theorems. Forbidden in generated code: `import`, `partial`, `unsafe`,
`axiom`, `sorry`, `admit`, `opaque`, `native_decide`, `macro`, `elab`,
`@[extern]`, `@[implemented_by]` (static guard in `check.py`).

## Layout

- `lean/`: lake project (Lean 4.31.0, core only). `Main.lean` is the trusted
  IO shim; `Pipeline/Generated.lean` is overwritten with each candidate.
- `check.py`: generator-agnostic gate sequence: static guard → `lake build`
  (rejects `sorry` warnings) → axiom gate → differential. Artifact JSON in,
  machine-readable failures out.
- `generate.py`: OpenAI backend (Responses API, strict JSON schema) driving
  check.py in a feedback loop. Default model `gpt-5.6-luna` (cheap-first);
  frontier runs use `--model gpt-5.5-2026-04-23`.
- `targets.py`: target registry of scoped slices of uniq, fold, cut, basename,
  dirname, wc, with POSIX doc sources and input generators.
- `validate.py`: seeded differential runner (GNU oracle; `g`-prefixed
  binaries on macOS via brew coreutils).
- `prompts/generate.md`: the general P↔q prompt template.
- `runs/`: every round's prompt, raw response, Lean source, build log, and
  result, plus one `log.jsonl` summary row per round. Git-versioned; this is
  the experimental record.

## Usage

```sh
uv sync                                     # once
uv run generate.py --target uniq            # OpenAI loop (needs OPENAI_API_KEY)
uv run check.py --target uniq --artifact a.json --trials 200   # any generator
uv run validate.py uniq 200                 # differential only, current build
```

Claude subagents are the free prototyping generator: each works in a private
copy of `lean/`, writes an artifact JSON, and the main session runs check.py
serially (the lean dir is shared state, so never check two artifacts in
parallel). `generate.py` is reserved for deliberate, measured runs; reasoning
models reject `temperature`/`seed`/`top_p`, so the driver never sends them.
