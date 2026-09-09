# Checked phase3 results — 2026-09-07

The 32-byte relay now has an execution-level **Lean-to-Lean refinement** with reachable
pointer safety, actual buffer loads, partial-write/error state, and command composition
for a declared finite grammar. A fresh serial replay on OVH passed. This establishes a
bounded research result, not a verified C frontend, Bash verifier, or conference-ready paper.

## Checked mathematical result

`PointerRelay.complete_execution_refines` quantifies every terminal small-step execution
from an initial input/schedule state. It agrees with the phase2 summary in delivered,
unread, pending, exit status and both call counts; terminal traces also agree. Separate
constructive existence and determinism results avoid a vacuous relation. Reachability
preserves initialized-prefix and buffer bounds; writes load from physical memory at the
retry offset, while ghost payloads occur in invariants. Full request bounds include errors
and zero transfers. These are finite mathematical executions under the documented schedule
semantics, not a coinductive theorem about arbitrary operating-system executions.

`ShellObservation.command_refines` lifts state/status primitive simulation through `;`,
`&&` and `||` in a hand AST. `RelayComposition.fragment_refines` instantiates it with the
pointer relay and the byte summary. Total fragment evaluation has a reachability witness.
A checked counterexample shows why stdout alone cannot determine conditional behavior.
Another checked example makes discarded pending bytes explicit: a failing first relay on
`abcdef` followed by a fresh relay can deliver `abef`, with private `cd` lost on process exit.

The audit explicitly checks **112 declarations**:92 pointer,9 generic command/observation,
11 relay composition. This counts definitions and relations as well as theorems, not112
independent correctness proofs. All dependencies lie within `propext`, `Classical.choice`,
`Quot.sound`; no `sorryAx` or custom axioms were admitted. Lean4.31.0 checks all modules.

## Independent executable evidence

| Check | Result |
|---|---:|
| Python harness regression tests |32/32, no skips |
| Shared corpus |962 cases:953 accepted,9 rejected |
| C variants matching independent pointer events and final observations |962/962 each: macro O0, macro O2, linker-wrap O2 |
| Lean matching common event/final projection |962/962 |
| Reference call events |2,707 across953 accepted cases |
| Hand-derived traces |12 |
| Isolation control |962/962 expected outcomes |
| Syntactic mutant edits distinguished somewhere in corpus |8/8, including two equivalent retry-skipping edits |
| Actual Bash contexts |30/30 |
| Recorded per-case wall timeouts |0 |

The corpus contains845 cases from a specified small finite product,93 directed cases,
3 no-flags cases,12 hand cases and9 rejects. It does not exhaust input byte strings or
schedules. Three C variants make2,886 original process executions, not2,886 unique inputs.
The same corpus digest is checked across the C/Python and Lean comparisons.

C instrumentation records real compiled call pointers, full requested lengths, returns,
transferred bytes and defined-buffer snapshots. The independent Python machine stores and
loads a byte array; separately written trace rules check safety, framing, retry and
conservation. Lean comparison retains kind/block/offset/request/action/result/bytes and
final delivered/unread/pending/status/counts. It excludes C/Python initialization and
snapshot metadata. See [the schema](validation/TRACE_SCHEMA.md) for the exact projection.

Mutation evidence is observation sensitivity, not a statistical accuracy or novelty claim.
The standard record contains1,022 mutant/case pairs with identical stdout, process status
and stderr counters but a recorded event mismatch;974 have no probe problem and48 include
clamping. This does not show that those mutants evade wire observations on every other
case. Some edits merely violate this exact request protocol while preserving a weaker
copy specification. Invalid mutant windows are clamped and flagged by the adapter, which
is not the execution semantics of undefined C.

Actual Bash tests use the controlled C driver, five scenarios and six contexts: bare,
`&&` marker, `||` marker, `;` marker, pipe to cat, and pipefail with cat. This is finite host
behavior evidence. Pipes are not included in the proved command grammar. The trace JSON
executable exits0 on successful serialization and is not used as a relay in status tests.
The driver eagerly ingests input; it does not validate the abstract shared-unread-stream
semantics of launching two relay processes consecutively.

## Resource and failure record

Fresh replay after review fixes: **47.40 seconds**, one compiler at a time.

| Group | Wall seconds | Peak RSS KiB |
|---|---:|---:|
| Lean build, native trace executable, axiom audits |19.41|801,900|
| Independent C validation, including compilation |21.80|48,012|
| Lean trace comparison |5.73|33,536|
| Actual Bash contexts, including C compilation |0.33|29,824|

These GNU-time group measurements include drivers, process launch and descendants;
RSS is a high-water measure, not summed concurrent memory or isolated utility memory.
Lean build commands have3GiB address-space/120s limits, one thread and16MiB Lean stacks.
C build commands have1GiB/60s limits; C cases256MiB/3s, bounded regular-file captures and a
strict call cap. The replay needs no Mac offload, network, or new dependencies.

Failures are retained, not counted as successes: an earlier monolithic Lean export hit
signal11 near its3GiB virtual-address cap despite elaborating; splitting the proof into
Core and Relay resolved it under the same limit. Main's first composition integration
failed on proof syntax and was fixed. Source review found a probe exit use-after-return
before C tests ran; exit now reads a shadow captured while the buffer was live. Review
also found an unsupported capacity1 oracle path; the API now rejects every capacity other
than32, covered by a regression. Earlier quick/standard diagnostic replays are separate
from this final result. No current-phase OOM was observed.

## Integrity and research scope

[results.json](results.json) records exact source, corpus, executable and raw-record hashes,
checks and declaration dependencies. The frozen `relay.c` digest remains
`c5abc06f53474d90ff7927aa485a03316e267fe758593a411f70a6d22f1afe68`.
Concurrent comment edits to imported Lean files and phase3 proofs were preserved; the final
replay compiled those current sources. Earlier source snapshots/reports remain in private
archives; no claim is made that every previous-phase source remains byte-identical.

Independent Astra semantic and empirical reviews found no blocker within the stated
capacity32 scope. Claude Fable5.1 authored the independent validation harness; main reviewed,
fixed integration issues and ran all final checks. Reviews are not extra benchmark runs.

Raw C parsing/lowering, machine integer semantics, ABI, pointer provenance/lifetime beyond
the single modeled allocation, full POSIX errors/signals/concurrency, actual Bash parsing
and execution, and English-to-query fidelity are still unverified bridges. The newly
[located State Calculus source](STATE-CALCULUS-INTEGRATION.md) provides concrete integration
points but has not been built here. [Paper criteria](PAPER-CRITERIA.md) specify the larger
source-fidelity, reuse, automation and multi-utility evidence needed for a submission.
