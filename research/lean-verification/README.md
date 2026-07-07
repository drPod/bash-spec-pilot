# Verifying LLM-generated models of Unix utilities in Lean

*The one-stop report. Everything below is grounded in the sibling docs (`00`-`03`,
`decisions.md`) and in a runnable, CI-checked demo (`demo/`); read those for depth,
read this to get the whole picture.*

## The question

Can an unreliable LLM produce a machine-checkable proof that a program behaves according
to a specification derived from documentation?

The previous direction (v1, archived in `archive/v1/`) answered a weaker question by
differential testing: does the candidate match the real GNU binary on the inputs we
tried? Testing certifies only the inputs tried. A proof, checked by Lean's kernel,
certifies all of them, and the kernel is a trust anchor an unreliable LLM cannot fool:
a wrong proof simply fails to check. The anchor paper is VERINA (arXiv 2505.23135),
which jointly generates code, a formal spec, and a Lean proof. Our targets differ in one
hard way: `cp`, `head`, `sudo` are not Lean functions. They are foreign binaries.

## Two walls, quantified

The literature review (`02`, `03`) found two independent blockers to the naive goal of
"formally prove the real GNU binary correct."

**Wall A, the embedding wall.** To prove anything in Lean about a program not written in
Lean, that language's semantics must first be encoded in Lean. No existing system embeds
a foreign, not-designed-for-verification language this way: the entire verified-codegen
field verifies programs already written in the verification language (Dafny, Verus-annotated
Rust, or Lean/Coq directly). The closest formal shell semantics, Smoosh, has no Lean
backend and stops at the utility boundary anyway (`cp` runs via `execve` and is opaque to
it). Building a faithful Lean semantics of POSIX utilities is a multi-year effort.

**Wall B, the proof-rate wall.** Even in VERINA's easy setting, where the program already
is a pure, terminating Lean function, auto-proving barely works: 4.9% proof success at
pass@1 for the best general model, 11.2% for the best specialized prover, ~20% after 64
refinement rounds, 3.2% end-to-end. SMT-backed verifiers (Dafny, Verus) reach 52-90% on
comparable tasks. The ITP-vs-ATP gap is roughly 5-10x and persists even for frontier
provers.

Stacked, the walls mean "auto-prove real Bash correct" is not a near-term target, and any
framing that promises it will disappoint.

## The reframing: two-layer trust

Instead of climbing Wall A, dissolve it. The LLM generates a Lean *model* of the utility,
plus a spec, plus a proof that the model satisfies the spec; the real GNU binary is used
only to differential-validate the model. Two layers, two kinds of evidence:

1. **`model ⊨ spec`, proven.** A Lean theorem, checked by the kernel, covering every
   input. This is the VERINA task transplanted onto utilities.
2. **`model ≈ binary`, tested.** The same Lean model, compiled to an executable, run
   head-to-head against real GNU over random inputs. This is exactly the v1 oracle,
   repurposed.

The honest trust chain: the user validates the spec; Lean proves `model ⊨ spec`; the
differential run gives evidence `model ≈ binary`. There is no formal `binary ⊨ spec`
claim, because that requires Wall A. This is strictly more than v1 (which had only the
test layer) and explicit about where the formal guarantee stops. The `model ≈ binary`
link is the soft spot, and it lands precisely where the group already has tooling and a
failure taxonomy.

In Astrogator's formalism, two things change: the Verifier becomes the Lean kernel
checking an LLM-generated proof (an off-the-shelf, trusted checker instead of the
bespoke symbolic engine whose scalability the POPL draft flags), and `p` becomes an
LLM-generated Lean model of the utility, with the model-to-binary gap discharged
empirically rather than symbolically.

## The demo, built and verified

`demo/` instantiates the reframing on four terminating utilities: `true`, `false`,
`echo`, `head -n k`. All models are plain total Lean functions (never `partial def`,
which the kernel treats as opaque); utilities that loop or fork would move to an
inductive `Prop` semantics and are scoped out.

`Demo/Basic.lean` proves, for **all** `k` and **all** inputs:

| Theorem | Statement |
|---|---|
| `head_length_le_k` | output has at most `k` lines |
| `head_length_le_input` | output is never longer than the input |
| `head_is_prefix` | output is a genuine prefix of the input (order and content preserved) |
| `head_saturates` | if the input has `≤ k` lines, output equals the input |
| `head_zero` | `head -n 0` is empty |
| `head_succ` | consuming one more line prepends exactly the next line |

plus `true_succeeds`, `false_fails`, `echo_one_line`. The core of it:

```lean
def headModel (k : Nat) (input : List String) : List String := input.take k

theorem head_is_prefix (k : Nat) (input : List String) :
    headModel k input <+: input :=
  ⟨input.drop k, by simp [headModel, List.take_append_drop]⟩
```

Verification status, both layers, both environments:

- **Layer 1 (kernel).** `lake build` green: "Build completed successfully (9 jobs)".
  First in GitHub Actions (run 28792218917), then reproduced locally (Lean 4.31.0 via
  elan). Lemma names were taken from the Lean core docs, not from memory; the kernel is
  the final arbiter regardless.
- **Layer 2 (differential).** `validate.py` compiles the proven model into a CLI and runs
  it against real GNU `head`. Suite A (`k ≥ 0`, the modeled domain): **300/300 match**.
- **CI.** `.github/workflows/lean-demo.yml` reruns both layers on every push touching
  `demo/`, with Ubuntu's GNU `/usr/bin/head` as the oracle.

Suite B deliberately probes `head -n -2` (count from the end). `headModel` takes a `Nat`
and cannot express negative counts, so the differential layer surfaces a model gap
rather than hiding it. That is the method working: the two-layer structure tells you
exactly where the formal guarantee ends.

## Decisions made for the demo (and what stays open)

Scoped picks, recorded in `decisions.md`; the strategic calls remain Aaron's.

1. **Lean, not Verus/Dafny, for now.** Wall B is about auto-proving hard problems; for
   trivial terminating utilities the goals close with named core lemmas, so the
   single-digit auto-proof rate does not block a first demo. Verus/Dafny stay the
   documented escape hatch once proof automation becomes the bottleneck.
2. **Two-layer trust as the framing.** For Aaron to bless as *the* contribution shape.
3. **Specs as Lean propositions directly.** A `State` record and a spec DSL closer to
   Astrogator's `S` are premature at four utilities; revisit when specs get repetitive.
4. **SLMFix out of the loop.** It fits later as a compile-fixer inside an LLM auto-proof
   loop, once such a loop exists.
5. **Total functions for terminating utilities**; inductive `Prop` plus fuel reserved for
   ones that loop.

Open questions that gate what comes next:

1. **Backend.** Stay Lean (aligned with a future Lean Bash spec language, single-digit
   auto-proof rates on hard goals) or move to Verus/Dafny (5-10x automation, less
   aligned)? This sets the rest of the project.
2. **Is two-layer trust acceptable as the contribution**, given no formal `binary ⊨ spec`
   is possible without the multi-year embedding?
3. **Spec language**: raw Lean propositions, or a small DSL compiling to the backend?
4. **How much SLMFix**, and when?

## What counts as a contribution even if proofs mostly fail

Given Wall B, most non-trivial auto-generated proofs will not go through, and that is a
finding, not a failure. The deliverables: a worked end-to-end demonstration of the
generate-model-spec-proof shape on Unix utilities with the real binary as an automatic
ground-truth oracle (which VERINA lacks); an honest, quantified map of where Walls A and
B block "verify real Bash"; and evidence on a question VERINA cannot ask, namely how
contested ground truth (man page vs POSIX vs binary, the v1 finding) propagates into spec
soundness and proof failure.

## Next steps

1. Put the LLM in the loop: have it generate model + spec + proof for held-out utilities
   and measure kernel acceptance, with a compiler-feedback refinement loop.
2. Scale past four utilities toward ones with real spec weight (`wc`, `cut`, `uniq`),
   watching where totality and state (filesystem, environment) start to bite.
3. Apply VERINA's spec soundness/completeness method with the binary as ground truth.

## Reading map

- `00_positioning_and_experiment.md` — full positioning and experiment design.
- `01_verina_deepdive.md` — the anchor paper.
- `02_prior_art_landscape.md` — the verified-codegen field.
- `03_foreign_language_semantics_gap.md` — Wall A in detail.
- `decisions.md` — the demo-scoped picks.
- `demo/` — the runnable artifact (`lake build`, `python3 validate.py`).
