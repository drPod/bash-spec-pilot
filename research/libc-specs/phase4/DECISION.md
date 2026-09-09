# Backend decision: reuse VST/CompCert for the C proof

Decision date: 2026-09-07. **Choose VST/CompCert as the primary C proof backend.**
Use VeriFast for fast contract-development experiments and as an automation comparator.
Keep AutoCorres2 as the fallback if the VST semantic-adequacy experiment exposes a
substantially worse proof boundary. Do not build a general C semantics or frontend in Lean.

This is a reasoned adoption decision with a checked VeriFast feasibility experiment.
It is not a claim that a VST relay proof has already been completed, or an experimental
performance ranking of all four systems. No VST/Coq/Isabelle/Frama-C build ran in this phase.

## Why this choice

The missing research result is a connection from actual utility C behavior to the
observations a shell query needs. VST's Verifiable C logic has an established soundness
connection to CompCert C semantics. It offers existing memory ownership, C types/casts,
loop reasoning and external-function contracts. Those are exactly the components we
should reuse instead of expanding our own small Lean model into a C verifier.
[Primary VST description](https://vst.cs.princeton.edu/).

The I/O precedent is particularly relevant. VST's existing I/O assertions and DeepWeb's
C-to-effect-model development supply patterns for connecting concrete buffers to effect
protocols. They still need adaptation for block reads, short writes, distinct EOF/errors
and our chosen observations. Borrow the relevant pieces; importing all of DeepWeb is not
a prerequisite. See [the earlier pinned artifact review](../04_io_prior_art.md).

| Option | Role chosen | Reason and remaining cost |
|---|---|---|
| VST/CompCert | Primary source-proof path | Established C/memory semantics and kernel-checked logic; annotation effort and whole-program I/O adequacy remain real work |
| AutoCorres2 | Strong fallback | Existing correspondence-producing C abstraction in Isabelle; assess its nonfailure/termination conditions and external-call modeling against our target |
| VeriFast | Contract-development comparator | Real relay and upstream buffered-I/O examples checked cheaply using existing predicates; the verifier's success verdict is not a Lean/Rocq certificate about CompCert C |
| Frama-C WP | Later automation baseline | Existing ACSL/VC-generation/solver infrastructure; proving generated VCs does not by itself verify the C-to-VC translation |

Sources: [AutoCorres2 infrastructure](https://isa-afp.org/browser_info/current/AFP/AutoCorres2/AutoCorresInfrastructure.html),
[VeriFast release](https://github.com/verifast/verifast/releases/tag/26.01),
[WP documentation](https://www.frama-c.com/fc-plugins/wp.html).
No numerical scores or timings were invented for unexecuted candidates. Installation
convenience is not the deciding criterion for the paper's trust argument.

## What we actually reused and checked

The phase4 experiment verifies the original relay's **123 executable/header tokens**, with
only comments/annotations added. Verification uses an explicit replacement `unistd.h`
contract and VeriFast's LP64 built-in type declarations, not the host library implementation.
Existing `chars`, `chars_`, split/join and signed/unsigned byte-ownership conversion lemmas
handle the buffer. We wrote no replacement heap model or new memory lemma.

The check covers allocated/initialized request ranges, guarded casts, bounded pointer
advance, stack ownership and result0..2 on return. Read/write are assumed modular
contracts. There is no input stream or output log in this small contract, so neither EOF,
byte delivery nor termination is established by it.

| Experiment | Actual outcome |
|---|---|
| Original annotated relay | VeriFast accepts;25 statements checked |
| Read request33 into32-byte buffer | Rejected at the declared read precondition |
| Retry requests n instead of n-off | Rejected for insufficient initialized suffix ownership |
| Retry after zero write | Accepted: partial correctness permits divergence |
| Retry writes from buffer base | Accepted after adjusting ghost partition to that actual range: memory safety does not imply correct bytes |
| Upstream buffered-I/O implementation | Accepted;60 statements checked |

For the zero-retry and wrong-pointer controls, annotations are adjusted to the changed
control flow/range while the same external and public function contracts remain fixed.
This tests the contract's strength, rather than exploiting an obsolete proof annotation.
All six observed outcomes match expectations. The complete replay is below one second
on this host; exact times/RSS are in [results.json](results.json). This is a small
engineering measurement, not a verifier speed benchmark or evidence of novel I/O logic.

This experiment supports reuse and identifies the next requirement: **a byte-effect
contract plus a separate progress argument**. A memory-only pass will not count as
successful functional verification in the VST pilot either.

## Version and assumption discipline

Use the released **VST2.15 / Coq8.20.0 / CompCert3.15** combination, with VST pinned at
`5736832b383a4e882e82a4925b335dfc401e39c2`. The release description, Makefile and actual
released opam package metadata support this choice. The VST repository's own opam file
at that tag has stale constraints; use the released package metadata, not a naive pin
of that file. Moving master also has different bundled/dependency versions. See
[backend-lock.json](backend-lock.json); it distinguishes source inspection from installation.
[Release](https://github.com/PrincetonUniversity/VST/releases/tag/v2.15),
[released package](https://raw.githubusercontent.com/coq/opam-coq-archive/master/released/packages/coq-vst/coq-vst.2.15/opam).

The pinned release's [verif_io.v](https://github.com/PrincetonUniversity/VST/blob/5736832b383a4e882e82a4925b335dfc401e39c2/progs/verif_io.v)
contains `Axiom (Jsub: ...)` used by its external/OS correctness theorems. Do not copy these
results and call the resulting bridge axiom-free. The pilot must print the assumptions
of its own final theorem, discharge the required external-operation compatibility facts
for our restricted protocol or state those assumptions explicitly, and distinguish
source/Clight, compiler and host-OS claims. A body proof alone is not the final adequacy
result. No verified host-libc claim follows from assumed external contracts.

## Lean and Aaron's State Calculus

VST proofs live in Rocq/Coq. **No automatic checked import into Lean has been established.**
Preserve the existing Lean reference/proofs and record the requested Lean-final-checker
connection as unresolved; do not silently declare that requirement satisfied or discarded.
A Lean theorem assuming a utility simulation remains conditional on that assumption.

For the smallest end-to-end research experiment, backend-native command composition is
an attractive alternative: prove the small sequencing/conditional observation grammar
in the same assistant as the C theorem. Treat that as an explicit architectural option,
not an already approved replacement for a mandatory Lean trust anchor. A certified
cross-assistant bridge is a separate project and is not the default near-term implementation.

Reuse Aaron's located frontend rather than writing a new spec-language parser. Its
OCaml interpreter and an imported contract/proof bundle still need a representation and
soundness connection. Package the observable contract, assumptions, source identity and
proof together; exporting JSON is not exporting a proof.

## Next acceptance test and fallback trigger

The [VST pilot specification](VST-PILOT.md) defines the next bounded milestone. A successful
pilot needs byte effects and a semantic consequence, not just successful installation or
`semax_body`. Keep all failures and resources. If VST's adequate external-call model cannot
be established within a defensible scope, compare the same obligation in AutoCorres2;
do not respond by quietly weakening the theorem or restarting a custom C semantics.
