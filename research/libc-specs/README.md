# Verifying shell scripts from utility implementations

Can a verifier use a command's C implementation to reason about a shell script, instead of requiring a new behavioral specification for every command?

This project builds a small prototype of that approach. It connects a byte-copying utility to a formal script interpreter, proves properties of supported command compositions, tests contract reuse in other C functions, and measures LLM proof generation on selected tasks.

**Start with the [research paper (PDF)](phase5/evaluation/paper.pdf)** for the question, method, findings and limitations. The [Markdown manuscript](phase5/evaluation/DRAFT-PAPER.md) has the same content.

## Findings

- The relay utility's generated C representation can be connected to script-level reasoning in Lean, with explicit trusted translation and modeling steps.
- Partial I/O and state shared across commands must be tracked to prove the supported compositions. Output or exit status alone can hide failures.
- Read contracts transfer to selected `head` and `wc` functions; buffered output needs a different contract.
- The UTF-8 calibration completed extensive testing but did not achieve its intended C-conformance proof.
- The expanded LLM experiment accepted 23/90 scored proof submissions. It measures proof regeneration on these tasks, not general script-generation accuracy.

The prototype does not verify arbitrary Bash or establish that a formal query captures a user's natural-language intent. Only relay has the source connection into the Lean script fragment; the other C case studies have separate Coq/VST proofs.

## Where to look

| Purpose | Document |
|---|---|
| Understand the research | [Paper](phase5/evaluation/paper.pdf) |
| Check the final scope and artifact | [Delivery record](phase5/FINAL-DELIVERY.md), [frozen source archive](phase5/deliverables/release-212/README.md) |
| Find individual proofs and assumptions | [Requirements](phase5/REQUIREMENTS.md), [proof chain](phase5/integration/PROOF-CHAIN.md) |
| Examine proof-generation results | [Expanded experiment](phase5/evaluation-expanded/README.md) |
| Understand the library choices | [Library survey](01_libc_spec_survey.md), [I/O prior art](04_io_prior_art.md) |
| Find catalog and provenance records | [Research organization](phase5/organization/README.md) |

## Earlier experiments

The numbered reports and phases below record stages of the investigation. Their results remain useful, but their proposed next steps are historical. The paper and delivery record describe the completed prototype.

| Stage | Question |
|---|---|
| [Initial review](03_review_and_results.md) and [proposal](02_spec_generation_approach.md) | What did the first models establish, and what was missing? |
| [MiniC example](example/README.md) | Can a small, manually represented program count newlines? |
| [Raw-byte experiment](byte-experiment/README.md) | Does the input representation preserve enough information to count correctly? |
| [Memory experiment](memory-experiment/README.md) | Can buffer effects and bounded counters be related to mathematical models? |
| [Phase 2](phase2/README.md), [phase 3](phase3/README.md), [phase 4](phase4/README.md) | How do the utility, composition and C verification models develop? |

Replay the initial Lean experiments from the repository root:

```sh
uv run --no-project python research/libc-specs/check_experiments.py
```

This checks the initial experiments, not the complete phase5 artifact. The [artifact guide](phase5/artifact/README.md) covers the later replay. Model API credentials are not needed to check existing proofs.
