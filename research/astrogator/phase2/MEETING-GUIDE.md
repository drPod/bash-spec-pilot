# Explaining the contribution to Aaron

## The short version

“I evaluated the formalizer that the paper proposes but does not yet measure, and connected its outputs to the real verifier. A guide built from FQL's compiler and knowledge base recovers most of the verifier decisions lost under a compact prompt. I also traced one complete failure from natural language through a valid-looking but wrong query to an accepted program that deletes the wrong object. Stronger comparison baselines change the story, so the new evaluation makes the benefits and limits explicit.”

## Understand these three results

**Compilation is not intent fidelity.** The generated phrase `delete contents of directory at /home/mydata/web` compiles, but the semantic analyzer turns it into directory deletion. The concrete corpus program removes the parent in both diagnostic states. Supplied and handbook-generated queries reject it. This is why a syntax success rate alone would not validate the formalizer.

**The handbook changes the complete pipeline.** Of 1,528 programs decided by the supplied-query control, GPT preserves 872–949 decisions under the compact guide and 1,525 under the handbook. Opus improves from 926 to 1,469. Every repetition is retained. These are paired decisions on fixed programs, not 1,528 independently validated specifications or an accuracy estimate. The remaining compiler-effect mismatches still matter even where the sampled programs do not distinguish them.

**The strong baselines must be taken seriously.** On strict local labels for the four-task study, GPT accepts four failing programs; default Astrogator accepts nine and cannot analyze 74. Astrogator rejects one GPT-accepted malformed-shadow case; the other three are unavailable. Generated executable checks are also strong on these fixtures. We cannot claim that Astrogator generally beats modern LLMs in accuracy. Formal guarantees relative to a query, coverage, residual assumptions, and specification fidelity are different dimensions of evidence.

## Questions you should be ready for

- **Is this a new prompting algorithm?** No. The contribution is a working, measured formalization component and its downstream effects in Astrogator. Related work already generates and validates specifications.
- **Did the model see the target answer?** Target IDs are excluded from demonstrations; the handbook is global and source-derived. Same-family examples and a task-related knowledge base are allowed, so this is not unseen-domain generalization.
- **Is the handbook improvement caused specifically by the KB?** That is not isolated. The intervention bundles signatures, semantics, KB entries, instructions, and more input tokens.
- **Why are there 26,856 cells but only 21 tasks?** Two guide arms × two models × three attempts × 2,238 programs. Queries are shared by programs within each task, and identical inputs are cached. Do not treat repeated cells as independent samples.
- **Do the new 70 tasks all work with the verifier?** No: 70 candidates include 21 original tasks and 49 additions; 52 queries process successfully and 18 expose unsupported features. Runtime checks and adequate specifications are separate gates; human review is still needed.
- **Are the permission patches the main contribution?** They are supporting diagnostic repairs. The normalizer benefits a controlled panel but sacrifices 57 decisions in the original corpus, so it is not a blanket improvement.

## Decisions to make together

Choose the central evaluation claim based on the complete results; confirm how users should inspect and discharge residual assumptions; review the FQL permission and preservation contracts; and select the benchmark candidates that warrant human intent review. A broader execution-labeled task sample and matched-information baseline study would support stronger generalization claims.

The main figure and research brief can replace a weak evaluation narrative. Extensive patches, failed attempts, and case listings can remain in the supporting artifact. Nothing has been sent to Aaron.
