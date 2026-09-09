# C utility specifications, memory and observable behavior

Research direction: use C implementations as utility specifications, model their library effects,
and connect execution to shell queries through checked refinement. **The C semantics, translation,
memory and observation boundaries remain part of the proof obligation.**

This phase combines Claude Fable 5.1 development/independent testing with Astra semantics, proofs
and critical review. The artifacts are agent-authored through compiler feedback; no controlled
proof-generation evaluation or proof-success-rate measurement was performed.

| Read | Evidence |
|---|---|
| [Phase review and results](03_review_and_results.md) | findings, measurements, corrections and remaining trust gaps |
| [Survey](01_libc_spec_survey.md) and [I/O prior-art correction](04_io_prior_art.md) | source-specific reusable contracts; functional I/O work omitted from the first survey |
| [Generation approach](02_spec_generation_approach.md) | revised proposal with frozen obligations, memory/trace state and explicit validation boundaries |
| [Original MiniC example](example/README.md) | loop invariant and whole-program proof; 200/200 on the original restricted line distribution |
| [Raw-byte extension](byte-experiment/README.md) | arbitrary-byte execution theorem and proof that the existing lossy line abstraction cannot preserve newline counts |
| [Memory and bounded counters](memory-experiment/README.md) | frame/readback/bounds, arbitrary finite successful relay traces, modular arithmetic and composition |
| [Lexical inventory](data/coreutils_libc_surface.json) | preliminary 224-name source scan, not a verified call graph or measured accuracy estimate |

Functional memory and I/O contracts exist in prior systems. Their scope, host logic and assumptions
determine reuse; inspecting a weak default stdio header does not establish absence of stronger work.
The present checked models are deliberately small. They do not constitute a verified C frontend,
complete libc, GNU utility, State Calculus translation or Bash verifier.

Replay all new Lean checks, keeping dependency and build caches local and outside the synced tree:

```sh
uv run --no-project python research/libc-specs/check_experiments.py
```

The command prints the result file and raw-byte executable path. See the byte experiment README
for independent raw subprocess validation. No model API credentials are needed to replay results.
