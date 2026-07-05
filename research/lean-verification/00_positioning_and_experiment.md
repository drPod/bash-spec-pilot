# Positioning and first experiment

This is the synthesis of the three sibling docs in this folder. It states where the new
direction sits against the literature and against the group's own prior work, gives an honest
feasibility read, and proposes a concrete first experiment. Read `01`, `02`, `03` for the
grounding; this doc assumes their findings.

- `01_verina_deepdive.md` — the anchor paper (VERINA).
- `02_prior_art_landscape.md` — the LLM-assisted verified-code-generation field.
- `03_foreign_language_semantics_gap.md` — the crux: reasoning about a non-Lean program in Lean.

## The question

Can an unreliable LLM produce a machine-checkable proof that a program behaves according to a
specification derived from documentation? The v1 direction answered a weaker question by testing:
does the candidate match the real GNU binary on the inputs we tried? Testing certifies only those
inputs. A proof, checked by a kernel, certifies all of them, and the kernel is a trust anchor an
unreliable LLM cannot fool: a wrong proof fails to check.

VERINA (arXiv 2505.23135) is the anchor because it does exactly this shape, jointly generating
code, a formal pre/post-condition specification, and a Lean proof that the code satisfies the
spec. Our target is different in one hard way: the programs we care about (`cp`, `sudo`, `find`)
are not Lean functions. They are foreign binaries that touch the filesystem, read the environment,
and may not terminate.

## Two walls between us and "prove real Bash correct"

Naively, the goal is a formal guarantee about the real utility. Two independent walls block that
as a near-term target, and both are quantified in the sibling docs.

Wall A, the embedding wall (`03`). To prove anything in Lean about a program not written in Lean,
you must first encode that language's semantics in Lean and prove things about the encoded model.
No existing system embeds a foreign, not-designed-for-verification language this way. The whole
verified-codegen field (`02`) verifies programs already written in the verification language:
Dafny, Verus-annotated Rust, or Lean/Coq/Isabelle directly. The one near-miss, Aeneas (Rust to
Lean), uses a deterministic compiler pass that exploits Rust's type system, not an LLM, and Rust
is already verification-friendly. Smoosh, the closest formal shell semantics, is written in Lem
(no Lean backend) and stops at the utility boundary anyway: `cp` and `sudo` run via `execve` and
are opaque to it. A faithful Lean semantics of POSIX utilities does not exist, and building one is
a multi-year effort, not an undergrad project.

Wall B, the proof-rate wall (`01`, `02`). Even where the program is already a pure, terminating
Lean function (VERINA's setting, the easy case), auto-proving correctness barely works. VERINA
reports 4.9% proof success at pass@1 for the best general model (o3) and 11.2% for the best
specialized prover (Goedel-Prover-V2 32B), rising to only ~20.1% after 64 rounds of
compiler-feedback refinement. End-to-end (code and spec and proof together) the best models reach
3.2%. By contrast, SMT-backed automated theorem proving (Dafny, Verus) reaches 52 to 90% on
comparable proof tasks. The gap between interactive theorem proving (ITP: Lean, Coq) and automated
theorem proving (ATP: Dafny, Verus) is roughly 5 to 10x and persists even for frontier provers
that clear 84 to 90% on competition math.

The two walls are independent. Wall B says proving is hard even when there is no foreign language.
Wall A says there is a foreign language and no model of it. Stacking them, auto-proving properties
of real GNU utilities is not a near-term automatable target, and any framing that promises it will
disappoint. This is worth saying plainly to Aaron up front.

## The tractable reframing: generate a Lean model, validate it against the binary

The crux doc's recommendation dissolves Wall A instead of climbing it. Do not embed the real
utility. Have the LLM generate a Lean model of the utility, together with a spec and a proof that
the model satisfies the spec, and use the real GNU binary only to differential-validate the model.

This splits the problem into two layers with two different kinds of evidence:

1. Model satisfies spec: established formally, by a Lean proof the kernel checks. This is the
   VERINA task, transplanted onto utilities.
2. Model matches reality: established empirically, by differential-testing the executable Lean
   model against the real GNU binary in the trixie container, which is exactly the v1 oracle.

The honest trust chain is therefore: the user validates the spec `s`; Lean proves `model ⊨ s`;
differential testing gives evidence `model ≈ binary`. What we do not get is a formal proof that
`binary ⊨ s`, because that would require Wall A. We get `(model ⊨ s)` proven and `(model ≈ binary)`
tested. That is strictly more than v1, which had only the test layer, and it is honest about where
the formal guarantee stops. The `model ≈ binary` link is the soft spot, and it is precisely the
place the group already has tooling and a failure taxonomy for.

## Mapping onto Astrogator's formalism

Astrogator formalizes verification as: target language `T`, user intent `U ⊆ T`, spec language `S`
with semantics `⟦·⟧ : S → P(T)`, a formalizer `F : NL → S` (an LLM), and a Verifier that decides
`p ∈ ⟦s⟧`. Astrogator's Verifier is a bespoke symbolic interpreter plus a unification algorithm,
built per target language, and the POPL draft flags scalability as the hard part.

The new direction changes two things. The Verifier becomes the Lean kernel checking an
LLM-generated proof, an off-the-shelf, trusted checker instead of a bespoke engine. And `p` becomes
an LLM-generated Lean model of the utility rather than the real binary, with the model-to-binary
gap discharged empirically rather than symbolically. The spec `s` is a Lean proposition over an
explicit state (arguments, environment, a filesystem model, stdout, exit status). This is a clean
story for Aaron: it reuses Astrogator's problem framing, swaps the unscalable verifier for a kernel,
and is explicit that the price is a model-fidelity obligation offloaded to differential testing.

## Backend decision to surface: Lean (ITP) vs Verus/Dafny (ATP)

The single most consequential open decision. Wall B says raw Lean proof success is single digits,
while SMT-backed ATP (Verus for Rust, Dafny) reaches 52 to 90%. That is a large argument for making
the spec/model target an SMT-backed verifier rather than raw Lean.

- Arguments for Lean: matches the group's likely long-term direction; SLMFix already treats Lean as
  one of its four DSLs, so there is in-house muscle; Lean is more expressive for rich behavioral
  specs; the anchor paper is in Lean.
- Arguments for Verus/Dafny: 5 to 10x higher proof automation; the proof burden on the LLM is far
  smaller because the SMT solver discharges most obligations; a first experiment is much likelier to
  produce non-trivial passing proofs.

Recommendation: raise this explicitly with Aaron before committing. If the near-term goal is a
worked demonstration with some proofs actually going through, ATP is the safer substrate. If the
goal is to stay aligned with an eventual Lean-based Bash spec language, accept the low proof rate
and scope proofs to trivial utilities. These pull in opposite directions and the choice sets the
rest of the project.

## What we reuse from prior work

- The v1 trixie real-GNU oracle: repurposed from "is the Rust impl correct" to "does the Lean model
  match the binary." This is the model-validation layer, already built.
- SLMFix (same group): purpose-built to fix statically-detected errors in LLM-generated DSL code,
  including Lean. It fits as a compile-fixer pass so the proof step only sees Lean that already
  type-checks, unbundling "make it compile" from "make it prove."
- VERINA's spec-quality method: soundness and completeness of an LLM-generated spec checked by
  positive/negative test cases (proof, then `decide`, then property-based testing via `plausible`,
  then unknown). Notably, in VERINA itself the proof-based spec check succeeds under 4% of the time
  while the testing-based check succeeds over 40%, so testing carries spec evaluation today. We can
  apply the same method with our differential oracle supplying ground truth, which VERINA lacks (it
  needs hand-verified ground-truth specs; we get behavioral ground truth from the binary for free).
- The existing OpenAI driver and JSONL logging conventions.

## Concrete first experiment

Scope hard. Pick terminating, effect-light utilities so Wall B is as small as possible and Wall A
is sidestepped by the model-not-binary framing.

Targets, in order: `true`, `false`, `echo`, then `head -n k`. All terminate, so a fuel bound at most
is needed and coinduction is avoided. `head -n k` is the first that touches input and is a real but
bounded behavioral spec.

Steps:

1. State model. Define an explicit Lean state: argv, environment, a minimal filesystem model
   (a map from path to bytes for `head`), stdout, stderr, exit status.
2. Model. The LLM generates a Lean model of the utility over that state, as an inductive `Prop`
   relation (big-step operational semantics), or a fuel-indexed total function proven sound against
   the relation when we want to execute it. Not `partial def`: the kernel treats it as opaque and
   nothing can be proved about it.
3. Spec. The LLM (and/or a human) writes a pre/post-condition spec over the state, sourced from the
   man page and POSIX. This is the `F : NL → S` step, and NL ambiguity is the known limiter.
4. Proof. The LLM generates a Lean proof that the model satisfies the spec, with a compiler-feedback
   refinement loop (and SLMFix as the compile-fixer). Expect low success for anything past `echo`.
5. Model validation. Execute the (fuel-total) model and differential-test it against the real GNU
   binary in trixie across N inputs, reusing v1 infrastructure. Report the model-fidelity rate.
6. Spec quality. Apply VERINA's soundness/completeness method using the binary as ground truth.

Metrics: model-fidelity rate (model vs binary), spec soundness and completeness, proof success rate,
and a per-utility failure map keyed to whether the blocker was Wall A (modeling), Wall B (proving),
or spec ambiguity.

## What counts as a contribution even if proofs mostly fail

The deliverable is not a headline pass rate. Given Wall B, most non-trivial proofs will not go
through, and that is a finding, not a failure of the experiment. The contributions are:

- A worked, end-to-end demonstration of the generate-model-plus-spec-plus-proof shape applied to
  Unix utilities, with the real binary as an automatic ground-truth oracle (which VERINA lacks).
- An honest, quantified map of where Wall A and Wall B block "verify real Bash," so the group knows
  which sub-problems are worth attacking and which are multi-year.
- Evidence on a question VERINA could not ask: when the ground-truth spec is contested (man page vs
  POSIX vs binary, the v1 finding), how does that ambiguity propagate into spec soundness and proof
  failure? This connects the v1 divergence work to the verification story.

## Open questions for Aaron

1. Backend: Lean (aligned, expressive, ~single-digit proof rate) or Verus/Dafny (higher automation,
   less aligned with a Lean Bash spec language)? This gates everything else.
2. Is the two-layer trust model (prove `model ⊨ spec`, test `model ≈ binary`) acceptable as the
   contribution, given no formal `binary ⊨ spec` guarantee is possible without the multi-year
   embedding effort?
3. Should the spec language be Lean propositions directly, or a smaller DSL that compiles to the
   backend, closer to Astrogator's `S`?
4. How much should SLMFix be in the loop for the first experiment versus a later optimization?
