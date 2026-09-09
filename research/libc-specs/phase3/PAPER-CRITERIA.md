# Paper contribution and evidence criteria

State a falsifiable working question and gates that would be needed before a submission claim. This is criteria, not established novelty or acceptance.

**Working question.** Can reusable, observation-aware library contracts and checked utility summaries make verification of generated shell fragments more reliable and less repetitive than hand-specifying each utility?

The relay pilot is too small to support a systems-conference claim by itself. Later whole-program Lean results and the UTF-8 negative calibration are recorded in [`../phase5/evaluation/DRAFT-PAPER.md`](../phase5/evaluation/DRAFT-PAPER.md); they do not automatically satisfy every gate below.

## Candidate contribution

The strongest candidate is a certificate-based connection from **fixed utility
implementations to a compositional script observation model**, including partial
I/O effects and failure. The library contracts, utility summaries and query
obligations are frozen independently of generated proof text. A checker validates
the claimed refinement and refuses unsupported translations. Agent assistance is
a development/generation mechanism, not a trust assumption.

To support this contribution, the result must do more than embed a handwritten
copy of a program in Lean. It needs an executable or relational semantics for the
accepted source, checked links across representations, and an explicit statement
of the parser/compiler/library/OS assumptions. It also needs enough examples to
show reusable contracts survive different utility control flows and contexts.

The comparison must include the functional I/O verification of
[Penninckx et al.](https://www.willemp.be/cw/input-output-verification/esop2015-ioverif.pdf),
the C/ITree refinement of
[DeepWeb](https://www.cis.upenn.edu/~bcpierce/papers/deepweb-cpp-2019.pdf),
[AutoCorres2's correspondence-producing lifting](https://isa-afp.org/browser_info/current/AFP/AutoCorres2/Chapter1_MinMax.html),
[Smoosh's shell semantics](https://mgree.github.io/papers/popl2020_smoosh.pdf),
and [Fulminate's executable ownership contracts](https://www.cl.cam.ac.uk/~pes20/cn-testing-popl2025.pdf).
These references rule out framing the work as the first functional libc/I/O
specification, the first executable formal effect model, or the first use of C
as the input to formal reasoning.

## Evidence gates before a submission claim

| Gate | What would establish it | What does not establish it |
|---|---|---|
| Source fidelity | Fixed C semantics and checked AST-to-summary refinement, with parser boundary declared | AST hashes; model alias theorem; C/Python agreement alone |
| Reusable library contracts | Same reviewed contracts instantiated across distinct control/data patterns | Several flags on one recognizer template |
| Composition | Theorems for the accepted shell grammar and environmental model | Concatenating complete stdout strings and calling it a pipe |
| Adequate observations | Mutation/counterexample suite for bytes, status, partial effects, descriptors and admissibility | Output-only examples on successful runs |
| Nonvacuity | Reachable execution witnesses and separate progress/termination conditions | Conditional theorem with an impossible precondition; empty behavior relation |
| Intent fidelity | Fixed, independently reviewed queries and ambiguity policy | Code and query generated together and judged only by their mutual agreement |
| Automation value | Repeated frozen tasks, retained failures, measured human intervention and budget | Number of agent-written declarations or one successful interactive run |
| External validity | Diverse pinned real utility slices, including reported unsupported examples | Treating the purpose-built relay as GNU cat |
| Artifact reliability | Single bounded replay, exact source/corpus/proof identities, explicit trusted dependencies | A narrative that hides failed runs, skipped tests or weakened statements |

No fixed task count can guarantee acceptance. Begin an evaluation with at least
three structurally different utilities and several contexts per utility, then
expand until the scope claimed by the paper is represented. State exactly which
implementations and options are included. Candidate next slices (proposed, not
completed here): a byte counter, a newline counter with a real buffer loop, a
prefix-limited copier, and a buffered delimiter transform; select actual source
only after checking the frontend surface.

## Separate the three LLM problems

1. Contract discovery: propose library contracts from primary standards and
   existing formal artifacts. Evaluate observation coverage, consistency,
   counterexamples and independent adjudication. A plausible contract is not
   ground truth merely because the implementation can satisfy it.
2. Proof generation: give each worker the same frozen semantics, contracts,
   program and theorem types. Permit only proof-region edits. Record each initial
   attempt and each feedback round, model identity, command limits, elapsed time,
   and expert repairs. Collaborative development of this repository is not that study.
3. Intent-to-query generation: keep the human task description, accepted query,
   assumptions and alternative readings separate. Evaluate this independently;
   it remains outside the checked relay experiment.

Use a hand-authored/existing-contract baseline, a description-based utility
summary baseline, and a C-derived summary condition where supported. Compare the
same observable tasks. Ablate byte effects, exit status, and residual ownership
to show which false claims weaker contracts admit. Count unsupported translation,
invalid contract, failed proof, resource timeout and actual counterexample as
different outcomes. Do not call a solver timeout evidence that a theorem is false.

## Decision rules

If the source-to-model gap cannot be closed at a useful scale, narrow the paper's
claim explicitly to semantic infrastructure or adopt an established C verifier;
do not hide that gap under generated syntax. If the contract approach merely
reproduces known compositional I/O proofs without a new technical result or
measured benefit, the work is preparation for a paper, not its contribution.
If the shell observation model cannot represent realistic failure and descriptor
behavior, restrict the supported grammar/environment visibly and measure the
resulting coverage. Venue selection should follow the demonstrated contribution
and current calls for papers; no venue deadline or acceptance prediction is made here.
