# Research design: using C behavior in script verification

Historical proposal, 7 September 2026. This document records the design after the initial experiments. See the [paper](phase5/evaluation/paper.pdf) for the subsequent implementation and findings, and [initial results](03_review_and_results.md) for the evidence available when this proposal was written.

The hypothesis is that reusable library contracts and proofs connecting utility implementations to a common execution model can reduce repeated specification work. Using C as a
specification does not remove the need to define C execution, memory, environmental behavior, the
translation, and the observation boundary. The implementation can also contain bugs or deliberate
choices that differ from the user's query. A successful proof must connect these distinct objects.

## 1. Fix the obligations before asking for generated proofs

Keep the C source/version, semantic definitions, admissible initial states, observation function,
and theorem statement outside the worker's editable proof region. For an executable deterministic
slice, require a theorem of the form `∀ s, Pre s → observe (exec program s) = query s`.
For nondeterministic I/O use trace inclusion/refinement and make environment assumptions explicit;
a single host trace cannot establish that every allowed behavior satisfies the query.

Separate two experiments:

1. **Specification discovery:** the worker proposes a contract from standards, source and existing
   formal specifications. Review consistency and scope independently. This does not measure proof
   generation against a fixed problem.
2. **Proof generation:** freeze the accepted contract, program, semantics and theorem type. Permit
   proof edits only. Retain every attempt and compiler response; record initial success and success
   after a fixed feedback budget. No unmeasured proof-rate forecast follows from this pilot.

Generated source and theorem names passing a regex/axiom check are insufficient. The current
pipeline permits self-selected declarations and does not enforce theorem strength. Its known
`implemented_by` attribute bypass is now rejected lexically, but a robust adversarial system needs
command/environment validation and isolation. The experiments here use reviewed source and an
explicit axiom manifest; they are not evidence of a complete malicious-code sandbox.

## 2. A reusable library model needs memory and traces

For an initial byte-buffer slice, represent bytes by `UInt8`, pointers by object identity plus
offset, memory by bounded allocated objects, and input/output by explicit byte sequences.
Distinguish invalid accesses (outside the defined execution domain), ordinary API failures,
EOF, and successful short transfers. State which memory locations and external components may
change. `Option` alone can lose distinctions among UB, errors, exhaustion and insufficient fuel.

The checked `memory-experiment/MemoryTransfer.lean` is a small instance: one finite object,
full-request bounds, a chosen no-effect error branch, bounded prefix reads, pointwise and disjoint
range framing, and successful relay trace composition. Its `emit` is infallible. It has no file
buffering, allocation/lifetime, general provenance, actual errno, blocking or concurrency semantics.
A zero quota can stall; finite-trace conservation is not a termination theorem.

`CounterRefinement.lean` separates machine-width arithmetic from mathematical counts. It proves
modular counting and exact agreement under a no-overflow premise. This is an arithmetic model,
not a proof of a C frontend's type conversion or integer instruction semantics.

Reuse functional memory predicates and I/O trace specifications from prior work, including VST,
VeriFast's **stdio_simple.h** and I/O examples, and interaction trees. Porting between their logics
and Lean must preserve their assumptions; it is not merely a syntax translation. The [I/O review](04_io_prior_art.md) documents existing functional specifications.

## 3. Order the library work by observable effects

| Initial slice | Needed state/assumptions | What can be reused or tested |
|---|---|---|
| bounded `memcpy`/`memmove`/`strlen` | allocation, initialized readable bytes, writable ranges, separation/overlap, terminator bounds | ACSL/VST/VeriFast predicates and postconditions; compare concrete valid buffers |
| buffer input and output | full request validity, byte contents, short counts, EOF/errors; retry progress assumptions | current prefix-transfer proof; VST/VeriFast I/O contracts and trace methods |
| formatted stdio | format typing, varargs, locale, buffering, errors and flush | begin with one fixed format and say so; compare exact bytes and statuses |
| descriptor/filesystem operations | descriptor table, offsets, sharing, file contents and allowed nondeterminism | SibylFS and process-specific standards; compare membership in allowed outcomes |
| process/environment/locale | exit/cleanup, environment, locale and signals | defer until utility slice needs them; never erase cleanup/error/exit effects as no-ops |

The preliminary `data/coreutils_libc_surface.json` contains a **lexical inventory** of 224 names
at its recorded source revision, not a verified call graph or complete libc boundary. It includes
a known `void` artifact and excludes indirect calls. There is no validated ±10% error bound.
Use the list for triage only. Next extraction should retain the script, source hashes, preprocessor
configuration, callsites, and manual validation of a sample; gnulib dependencies require traversal.

## 4. Validation and discrimination gates

- Kernel-check fixed obligations with an explicit axiom manifest and no admission. Hash the entire
  model/proof/runtime input set. Preserve stdout/status/error observations through the IO shim.
- Prove frame properties where possible; randomized snapshots complement them, not replace them.
  An ACSL footprint is a source to interpret with its preconditions, not an infallible oracle.
- Run a small C companion against the actual libc on **defined inputs**. Compare raw bytes, return
  values and memory effects. Record host ABI, libc/compiler version, input corpus/seed/hash, and
  error-injection method. Ordinary pipes do not systematically explore short-read/error behavior.
- Use justified, non-equivalent mutants. A failed proof attempt does not establish a false theorem;
  find a counterexample or show a trusted fixed contract rejects it. A surviving mutant may be
  equivalent, irrelevant to the intended property, or expose a weak contract. Do not label all
  survivors vacuous.
- For a later measured study, preregister task selection, repetitions, feedback budget and success
  criteria. Include proof-only, contract-discovery and translation conditions separately.

## 5. Translation and shell composition remain proof obligations

The current `WcFromC` AST is manually authored from textbook C. Its new byte wrapper repairs the
observation boundary but does not certify the translation. A C frontend should reject unsupported
constructs explicitly and expose an AST whose semantics can be related to the selected C model.
CompCert/Clight or Cerberus can supply substantial infrastructure; importing an AST or printing it
to Lean does not automatically yield a verified C-to-Lean pipeline. Check each frontend's exact
correctness boundary rather than calling a tool invocation a verified translation.

A subsequent utility proof should connect a buffer-using C program to the memory contracts and
establish buffer validity, progress and error handling. Then prove a bounded shell composition,
such as successful byte-stream concatenation feeding a fixed newline counter, against a trace
query. Existing append/relay theorems supply ingredients, **not Bash parsing, pipe, scheduling,
redirection or process semantics**. The mapping into State Calculus must specify heap, stream and process observations and prove a simulation. That translation had not been implemented at this stage.

## 6. Planned sequence (historical)

1. **Completed here:** arbitrary-byte MiniC execution; information-loss impossibility theorem;
   finite-buffer frame/relay proofs; modular arithmetic and no-overflow refinement; independent
   byte differential validation; known checker bypass regression.
2. **Next:** one buffer-using C program, frozen syntax subset, explicit frontend mapping, bounds and
   retry invariant, concrete failure/short-transfer tests. Report unsupported syntax and failed
   obligations instead of silently simplifying the program.
3. **Then:** fixed-query composition using a specified shell fragment and trace semantics; prove
   the representation relation to State Calculus or explain a mismatch.
4. **Measured generation phase:** repeated independent attempts against frozen obligations,
   with adequate task diversity and failures retained. Compare against hand-authored and existing
   contract baselines. Current agent-assisted development is not such an evaluation.

The paper should follow demonstrated refinement and empirical evidence. We have not established
novelty, scalability, a complete libc, GNU/binary correctness or correctness of arbitrary Bash.
