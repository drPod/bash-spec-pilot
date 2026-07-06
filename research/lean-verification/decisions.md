# Decisions (first demo)

`00_positioning_and_experiment.md` ends with open questions. These are the picks made
to get something runnable in front of Aaron. Each is scoped to the first demo, not a
final strategic commitment; where the call is really Aaron's, that is flagged.

## 1. Backend: Lean for now (not Verus/Dafny)

Picked **Lean**. Reasons:
- Aaron's anchor paper (VERINA) is Lean; SLMFix (same group) already targets Lean.
- Wall B (single-digit proof rate) is about LLM auto-proving *hard* problems. For
  trivial terminating utilities the goals close with named core lemmas / basic tactics,
  so the low auto-proof rate is not a blocker for a first demo.

Verus/Dafny remain the documented escape hatch if/when auto-proof automation becomes the
bottleneck on non-trivial utilities. The long-term substrate choice stays Aaron's; this
is only "what makes the first demo real."

## 2. Trust model: adopt the two-layer story

Prove `model ⊨ spec` in Lean (kernel-checked, all inputs); test `model ≈ binary`
against real GNU (`ghead`) empirically. No claim of formal `binary ⊨ spec`; that needs
the embedding no one has built (Wall A). This is strictly more than v1 had and honest
about where the guarantee stops. For Aaron to bless as *the* framing.

## 3. Spec language: Lean propositions directly

Specs are Lean theorems stated directly over each model's inputs and outputs
(e.g. `(headModel k input).length ≤ k`). Both an explicit `State` record
(argv, stdin, stdout, exit) and a dedicated spec DSL closer to Astrogator's `S` are
premature at four utilities; revisit when specs get repetitive enough to justify
the shared frame. (YAGNI.)

## 4. SLMFix: out of the loop for the first demo

Doc-grounded Lean that compiles by construction. SLMFix fits later as a compile-fixer
once there is an LLM auto-proof loop whose output needs repairing.

## 5. Modeling: total functions for terminating utilities

`true`/`false`/`echo`/`head` all terminate, so models are plain total functions: both
executable (for the differential layer) and directly provable. Inductive `Prop` + fuel
is reserved for utilities that loop or fork, which the first demo scopes out.

## What is shown

`demo/` instantiates all of the above on `head -n k` (plus the three trivial utilities):
a kernel-checked proof that the model meets its spec for all inputs, and a differential
run that both confirms fidelity on the modeled domain and surfaces one honest model gap
(negative counts). See `demo/README.md`.
