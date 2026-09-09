# Next bounded VST adoption milestone

Specify the executable work for a VST adoption milestone.

Backend chosen in [DECISION.md](DECISION.md). This is a work specification, not a claimed completed proof.

At this 2026-09-07 writing, VST 2.15 source had been inspected but the toolchain had not been built. Later Coq/VST case studies in [`../phase5/evaluation/DRAFT-PAPER.md`](../phase5/evaluation/DRAFT-PAPER.md) should not be read back into this unbuilt-pilot record.

1. Resolve the released opam metadata into a user-local isolated environment, pinning
   Coq 8.20.0, CompCert 3.15, VST 2.15 and VST-zlist 2.13. Record the final Flocq/OCaml versions.
   Inspect dependency plan/download sizes first. Use one compiler and per-command memory,
   CPU/wall limits; retain caches for bounded continuation. Do not use the stale opam file
   in the VST source tag or suppress compatibility checks to hide a mismatched installation.
2. Generate Clight from the frozen relay under an explicit LP64 preprocessing/header
   configuration. Record source, preprocessed and generated AST identities; inspect casts,
   loops and external signatures. State the actual trusted input translation components.
   Do not handwrite another relay AST and call it generated-source verification.
3. Reuse VST data-array and integer/pointer reasoning. Model owned input/output and a
   byte-bearing external-call protocol. A read request 32 transfers a prefix of unread input
   to the buffer, initializes only that prefix, and returns its length; distinguish EOF
   from error. A write consumes a prefix of the requested initialized slice and appends
   exactly those bytes; distinguish -1, 0 and positive results. Retain no-transfer errors
   only as the explicitly chosen environment restriction.
4. Inner invariant: off≤n≤32; full initialized chunk owned; delivered chunk prefix has
   length off; pending is its suffix. Outer invariant: no pending bytes before next read;
   delivered plus unread equals original input. Preserve concrete signed error tests before
   casts. Prove the actual body contract, audit assumptions, then derive its precise
   external/Clight execution consequence. Inspect the Jsub requirement instead of assuming
   the example's top-level theorem is axiom-free.
5. Add a separate finite-input/scheduled-call progress argument. VST safety or partial
   correctness alone does not rule out zero-write loops. Keep blocking/diverging real
   environments outside the termination claim, visibly.
6. Required observations: bytes delivered, unread and privately pending; exit status;
   add call counts/full request events when the intended comparison observes them. Cases:
   abc with reads [3,-1] yields abc/status 1; abcdef with reads [4], writes [2,0] yields ab,
   unread ef, pending cd, status 2. The code may discard private pending at process exit,
   without restoring already-consumed input.
7. Functional negative controls must include wrong-pointer retries and false-success on
   read error. Progress controls include zero-write retries. A checker pass with a weaker
   postcondition is not success. Keep specification and theorem types frozen during proof
   generation; record proof edits and annotation burden rather than treating collaborative
   interactive development as an automation benchmark.
8. State the smallest composition result and exact assistant boundary. Preserve Lean's
   checked reference; a backend-native conditional/sequence proof is an alternative to a
   certified cross-assistant import, not evidence such an import already exists. The
   actual parser/interpreter remains a separately checked integration obligation.

Completion evidence: replayable C-to-Clight generation, real body proof and audited
semantic theorem, explicit termination/assumption scope, meaningful rejected controls,
source/version hashes, resource and manual-effort logs. The intended paper still requires
multiple real utility implementations and measured contract reuse/automation beyond relay.
