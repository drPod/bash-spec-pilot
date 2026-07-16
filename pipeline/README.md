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

## Results so far (2026-07-16)

One measured session per model per target, up to 4 refinement rounds, 200
differential trials per round. Kernel acceptance was 6/6 for every model;
the table shows differential fidelity and the round it was reached.

| target | gpt-5.6-luna | gpt-5.5-2026-04-23 | claude (subagent) |
|---|---|---|---|
| uniq | 100% (r4) | 100% (r2) | 100% (r1) |
| fold | 73.5%, stuck | 100% (r2) | 100% (r1) |
| cut | 100% (r2) | 100% (r2) | 100% (r1) |
| basename | 100% (r1) | 100% (r1) | 100% (r1) |
| dirname | 70.5%, stuck | 100% (r1) | 100% (r1) |
| wc | 100% (r1) | 100% (r1) | 100% (r1) |

The full luna sweep cost $0.34 (68k input / 45k output tokens); the frontier
sweep used 40k input / 65k output tokens, 51k of them reasoning. Every
prompt, response, generated Lean source, build log, and differential result
is committed under `runs/`.

What the data says:

1. **Kernel acceptance is not the bottleneck; spec fidelity is.** VERINA-style
   reasoning predicted single-digit proof rates. With compiler feedback, even
   the cheapest model got every target past the kernel within 4 rounds. What
   the cheap model could not do was read POSIX correctly.
2. **Kernel-accepted-but-divergent is real and crisp.** Three instances, all
   clean documentation misreadings: uniq deduplicating non-adjacent lines
   (64.5%), fold dropping empty input lines (73.5%), dirname skipping POSIX's
   second trailing-slash strip so `/usr/lib` gives `/usr/` (70.5%). Each is a
   proof of true theorems about the wrong model, which is exactly the failure
   mode the differential layer exists to expose and which spec-only
   benchmarks cannot see.
3. **One compiler-feedback round does almost all the proof work; differential
   feedback is much weaker.** Round-1 build failures were near-universal
   (frontier included), recovery at round 2 near-universal. But mismatch
   examples did not reliably steer the cheap model: dirname's fidelity
   wandered 160 -> 174 -> 141 of 200 across rounds. Better refinement
   feedback is an open tooling problem.
4. **Single runs are anecdotes.** Same model, same prompt: uniq scored 64.5%
   in one session and 100% in another. Reported numbers need repeated
   sessions.

## Status: what exists vs what the paper needs

Exists: the general P <-> q harness with anti-cheat gates, six instantiated
targets, and the qualitative findings above with committed evidence.

Needed for a paper, in rough order:

1. **Repeated-session statistics.** Every table cell above is n=1 and finding 4
   shows the variance. ~5-10 sessions per target per model; mean and spread.
2. **Harder targets to map the failure boundary.** The current six are
   terminating, stateless, and deliberately scoped down (uniq without
   options, cut with one `-c` range). Widen scopes and add utilities where
   options interact or filesystem/environment state bites, so the method's
   limits are measured rather than avoided.
3. **A stronger differential layer.** Inputs come from small fixed word/path
   pools; 100% fidelity means 100% on that distribution. Grammar-based or
   adversarial input generation would make the fidelity claim defensible.
4. **The spec-quality study (the actual paper).** Nothing yet measures whether
   the proved theorems pin down behavior or are vacuously weak (`run_exit_success`
   passes the theorem-count gate). VERINA's spec soundness/completeness
   method with the binary as ground truth is the missing centerpiece, and the
   piece worth designing together before building.
5. **Ablations.** No-feedback vs compiler-only vs compiler+differential;
   comparison against VERINA's published numbers on comparable tasks.

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
