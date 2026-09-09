# Phase 1: checked models and explicit gaps

2026-09-07. Astra orchestration; two bounded Astra workers plus two sequentially introduced
Claude Fable 5.1 CLI contributions. At most three workers were active; the first Claude's files
were reviewed read-only until it exited. No controlled model comparison was performed.

The substantive result is a small set of checked refinement ingredients, together with concrete
counterexamples to overly strong claims about the original pipeline. **This is not a paper-ready
verification of C utilities or Bash.** Source and reusable replay commands are in this directory;
`data/phase1_results.json` records hashes, tool versions, measured results and the axiom manifests.
Private worker conversations and runtime logs are not part of the source tree.

## What the Lean kernel checked

| Artifact | General claim | Boundary |
|---|---|---|
| Original `example/WcFromC.lean` | finite-input loop terminates with enough fuel and counts newlines under its invariant | manually authored MiniC, Unicode characters, unbounded integers, idealized libc |
| `byte-experiment/RawWc.lean` | the same AST executes on every finite UInt8 list and prints the decimal LF count with modeled status 0 | byte injection is proved; C parsing/translation and native IO are not |
| `no_line_factorization` | the actual old pure line decoder cannot support an exact newline counter for all strings | two-point impossibility witness; richer line encodings can work |
| `MemoryTransfer.lean` | bounded memory writes preserve other bytes; successful reads load back the consumed prefix; every finite successful relay trace preserves exact content and counts | one allocated object; chosen no-effect errors; infallible emit; no progress guarantee |
| `CounterRefinement.lean` | finite bounded counter computes `(initial + countLF input) mod modulus`; exact unbounded agreement under the no-overflow premise | arithmetic model, not C instruction semantics |
| `MemoryCounterComposition.lean` | successful memory relay output has the corresponding modular count, and exact prefix count when it fits | composition of these mathematical models, not composition of real shell processes |

All 43 printed declarations across the raw-byte and three memory/counter modules pass the standard
axiom whitelist (`propext`, `Classical.choice`, `Quot.sound`). The manifest contains exact names and
dependencies; this count includes helper definitions and concrete witnesses, and is **not a count
of independent utility correctness specifications**. The replay refuses missing/unexpected axiom
reports or `sorryAx`. Original MiniC source was retained byte-for-byte; its SHA is included.

The no-overflow condition matters. The parameterized 8-bit illustration checks 255 newline bytes
produce 255, while 256 produce 0, unlike the original unbounded counter. This illustrates a gap;
8 bits is not the host's `size_t` width. A simulation between machine-typed MiniC and the original
AST is still missing. Likewise, the buffer proofs do not establish that a parsed C program always
satisfies their preconditions.

## Independent byte validation

A second Claude worker wrote a C companion and raw subprocess validator independently. Astra
reviewed the driver, staged/rebuilt the final sources, and reran the fixed corpus. Linux x86_64,
glibc 2.39, GCC 13.3.0, Lean 4.31.0, GNU coreutils 9.4; C compiled with `-std=c11 -O2 -Wall -Wextra`.
Every comparison uses exact stdout bytes, exact empty stderr and exit status 0.

| Subject | Agreement with the independent byte-count expectation |
|---|---:|
| Raw MiniC executable | 1,000/1,000 |
| Minimal C executable | 1,000/1,000 |
| GNU `wc -l` on stdin | 1,000/1,000 |
| Original line-shim executable | 192/1,000 |

Corpus: 38 directed entries, 596 exhaustive entries over two small alphabets/length bounds, and
366 seeded random entries; categories can contain duplicate byte strings. Directed cases include
NUL, all byte values, malformed UTF-8, CR/CRLF, missing final LF and approximately 1 MiB inputs.
Seed/hash and exact construction are recorded in `byte-experiment/validate.py` and results JSON.
Of the old-shim disagreements, 221 are final-newline losses and 587 are invalid-UTF-8 exceptions.
The negative-control run with the old shim in the candidate slot detected all 808 discrepancies.

These are finite observations on normal local I/O. No systematic read/write error injection,
size_t overflow, filenames/options, scheduling, infinite inputs or filesystem state was tested.
The C program is textbook source transcribed from the MiniC comment, not GNU `src/wc.c`.

## Measurements and compute decisions

Sequential integrated checks on OVH (single observed runs; no statistical speed claim):

| Check | Elapsed seconds | Peak RSS KiB |
|---|---:|---:|
| Raw-byte executable build | 2.44 | 541,056 |
| Raw-byte module kernel recheck | 0.63 | 506,640 |
| Memory transfer | 0.77 | 790,444 |
| Modular counter | 0.47 | 779,284 |
| Memory/counter composition | 0.36 | 755,036 |

These are GNU time process-tree high-water measurements, **not simultaneous total host RAM**.
Lean4.31 and core/Std caches were already installed; the executable measurement includes a fresh
small project build, not downloading/building the toolchain. Build concurrency was limited, and
all generated build files stayed outside the source/sync tree. The small proof workload does not
justify a Mac runner or remote setup. No Mac execution occurred. Interpreter runtime RSS on the
prototype's approximately 1 MiB cases reached roughly 58–140 MiB; larger workloads need separate
measurement and likely a better environment representation.

## Checker identity finding and repair

`pipeline/check.py` originally rejected implementation overrides only directly after `@[`. The
negative specimen `data/checker_identity_witness.lean` puts `inline` first. Lean's kernel proves
its `run` returns `999`, while compiled evaluation returns the input-line count; all printed axiom
reports are clean. This demonstrates an executable/proof identity gap, not unsound Lean logic.
The original `WcFromC` does not contain this override.

The checker now rejects `extern`/`implemented_by` tokens regardless of attribute position, including
`attribute` commands and helpers. Seven negative syntax forms and an ordinary accepted definition
are covered by `pipeline/test_guard.py`. A private full checker run rejects the specimen before
build; the unchanged Wc artifact still passes build/axiom gates and 200/200 original trials.

This is a **known-bypass repair**, not complete adversarial enforcement. Command/environment
validation, isolation, frozen theorem types and baseline-aware dependency checking remain needed.
The theorem-name gate still does not establish theorem strength, uniqueness, or even declaration
kind. Trusted Lean core also intentionally uses native implementations (including `Nat.reprFast`);
axiom inspection alone does not verify their correspondence to logical definitions.

## Survey corrections and paper positioning

The first Claude survey usefully collected default headers and sources, but several conclusions
were too broad. They have been revised:

- VeriFast `bin/stdio_simple.h` carries content-bearing I/O protocols and failure branches;
  `examples/abstract_io` demonstrates buffering/flush layering. ESOP 2015 is direct relevant work.
- DeepWeb/interaction trees connect C, effect specifications and executable testing. Their external
  operation assumptions and historical artifact versions must be stated; inspected summer-school
  files with admissions are not a reproduced final-paper proof.
- Ordinary C embeddings in proof assistants are established prior art. A new Lean/Bash workflow
  requires a narrower novelty argument; none is established by this phase.
- A 224-name regex inventory is not a verified libc call graph. Its ±10% accuracy assertion had no
  validation and was removed. It is triage data with known false positives/indirect-call omissions.
- The proofs were agent-authored through compiler feedback. “No LLM/hand-written” was inaccurate;
  there was no controlled proof-generation experiment or measured success rate.

Primary citations and version-specific caveats are in [the I/O review](04_io_prior_art.md);
the [revised approach](02_spec_generation_approach.md) fixes semantic/theorem obligations before
measuring generation. These corrections strengthen the research question by grounding it in actual
reuse and refinement work instead of an unsupported claim that I/O specifications do not exist.

## A defensible next phase

Freeze one small buffer-using C program, supported syntax, ABI/overflow policy, primitive I/O
contracts and exact observation theorem. Build a frontend mapping that exposes rather than erases
unsupported behavior; prove buffer safety and a retry invariant under an explicit progress
assumption. Adapt the discovered I/O protocol patterns. Then connect a bounded shell fragment and
query to the chosen trace/state semantics, with a proved representation into State Calculus.

Only after these boundaries are fixed should a repeated generation study compare proof-only,
contract-discovery and translation tasks. Preserve failures and independent runs. Candidate paper
claims are about semantic adequacy and the value/cost of reusable contracts; they remain hypotheses.
No publication, outreach, purchase, remote execution or fabricated proof/benchmark claim occurred.
