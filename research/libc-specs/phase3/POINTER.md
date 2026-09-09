# Pointer execution refinement

Give the frozen phase2 relay a separate, executable pointer machine and prove agreement for every terminal execution of its small-step relation.

`PointerCore.lean` and `PointerRelay.lean` establish Lean-to-Lean execution refinement, reachable request safety, and nonvacuous termination. `BufferRelay.lean`, `MemoryTransfer.lean`, and frozen phase1/phase2 artifacts are unchanged. The development does not translate C.

Local-stage 2026-09-07 pointer refinement, not the later generated-Clight/script connection in [`../phase5/evaluation/DRAFT-PAPER.md`](../phase5/evaluation/DRAFT-PAPER.md).

## State and operations

A `State` contains a physical `Fin 32 → UInt8` allocation, initialized length `n`,
retry offset `off`, unread input, delivered output, independent read/write quota
schedules, both call counters, and read/drain/stopped control. The `initialized`
list records the payload of the last successful read as ghost history. The
execution never reads bytes from that list: `writeNext` loads the physical
allocation at `off`. A successful read stores its payload at offset 0 and sets
`n` to its returned count and `off` to 0. Bytes beyond this new initialized prefix
remain in the allocation but are excluded from permitted writes. EOF and errors
preserve memory; EOF does not erase the most recent initialized prefix.

`slice` is a total operation on the finite allocation. `slice_load` proves that,
under the full range bound, it equals the phase1 pointer load. This totalization
avoids attaching proof fields to executable states; the reachability theorems
establish those bounds for actual executions. Arbitrary malformed states are
outside the initial-state refinement theorem.

`Step` has six constructors: read error, EOF, successful read, drain completion,
write error/zero, and successful write. Only drain completion is silent. `Steps`
is their reflexive transitive closure with the exact concatenated byte events.
Each event records direction, block/offset pointer, full requested count,
scheduled action, and actual transferred bytes. `Event.result` derives the
returned integer: -1 for a negative action, otherwise the payload length. Thus
EOF and zero-write both return 0 but have distinct transition behavior.

Every read requests 32 bytes at block 0/offset 0. Every write requests `n-off` bytes
at block 0/offset `off`, including error and zero-write paths. A successful write
loads only its actual `min quota (n-off)` bytes, appends those bytes to output,
and advances the offset by that count. `EventEffect` separately specifies and
proves the exact memory, input, output, offset, and call-count effects of each
emitted event. `readNext_primitive` and `writeNext_primitive` connect the transfer
operations with phase1's `read` and `emit` definitions.

`drain` recurses on `n-off`; `execute` recurses on unread input length. The latter
replaces the recursive state's input field with the known read suffix to expose
the termination measure to Lean. `drain_input` and `execute_reachable` prove that
this replacement is an identity, not an additional machine transition. The
operational definitions invoke frozen `action`, `readAmount`, and `fill`, but do
not invoke frozen `drain`, `execute`, `runDetailed`, or `run`. Those evaluators
occur only in the refinement statements and proofs.

## Checked obligations

* `reachable_invariant` proves `off ≤ n ≤ 32`, read control implies `off=n`,
  the ghost payload has length `n` and equals the physical initialized prefix,
  and `output ++ (pending ++ input) = originalInput` at every reachable state.
  The read-control condition prevents overwriting undelivered pending data.
* `reachable_pointer_view` proves that pending bytes are exactly both the
  physical load at `(off,n-off)` and the undelivered suffix of the last read.
* `reachable_request_safe` covers the entire requested range, independently of
  the actual result. For writes that entire range is inside the initialized
  prefix. `reachable_write_bytes` identifies the actual written payload.
* `reachable_event_effect` proves the exact effects described above.
  `run_trace_safe` finds the actual reachable source and transition for every
  event in the generated trace and gives its safety and conservation facts.
* `drain_refines` relates the complete pointer-drain final state to the frozen
  list-drain summary, including the advanced offset, output, residual schedule,
  failure control, and counters. `drain_pending` relates residual physical bytes.
* `execute_refines` proves general read-loop observation agreement, allowing
  arbitrary initial memory, delivered output, and call counters, provided the
  input state is well formed and has no pending bytes (`off=n`).
* `run_detailed_eq` proves equality of all six `Detailed` fields: output, unread
  input, pending bytes, exit status, read calls, and write calls.
  `run_outcome_eq` gives the five-field public phase2 `Outcome` equality.
* `run_reachable` proves that the independently computed trace is an actual
  `Steps` execution. `step_deterministic` and `terminal_unique` prove uniqueness
  of terminal state and event trace. `complete_execution_refines` therefore
  covers **every** terminal `Steps` execution from the initial state, rather
  than just one evaluator result.
* `terminal_execution_exists` supplies a terminal execution for every finite
  byte input and every pair of finite integer schedules. The execution relation
  is consequently nonvacuous; termination is proved rather than assumed.

The main relational theorem is:

```lean
Steps (initial input reads writes) events final →
Stopped final →
observe final = BufferRelay.runDetailed input reads writes ∧
events = (run input reads writes).trace
```

This is a Lean-to-Lean execution refinement. The event trace is additional
structure; phase2 has no byte-event trace whose equality is being claimed.
The checked examples distinguish first-read error, first-write error, error
before EOF, short write followed by zero, reused binary buffers, and the exact
retry pointers/full requests/payloads in the short-then-zero trace. Outcome
examples rewrite through the general refinement theorem. The retry-event
example reduces the pointer evaluator itself with kernel-checked simplification.

## Semantic scope

The theorem quantifies all finite lists, including schedules outside the common
CLI grammar. As in phase2, every negative read action causes error before an
EOF check, every negative/zero write stops immediately, and nonnegative read
quotas are normalized to at least 1. Valid common CLI inputs are a subset of this
totalized domain. Exhausted schedules use the request as their quota. All errors
are fail-stop; there is no EINTR retry, readiness, blocking, or partial effect on
error. Input and output are independent finite byte streams.

The allocation is one always-live abstract block; offsets and counters are
unbounded naturals. There is no C pointer provenance, integer overflow, object
lifetime, alignment, permissions, concurrency, aliasing between multiple
allocations, descriptor table, actual POSIX syscall semantics, or runtime/OS
preservation theorem. Initialization is tracked by the current prefix and its
read history; no general uninitialized-value semantics is claimed. The C parser,
source-to-model mapping, compilation, and driver/host I/O remain unverified.

## Proof replay and audit

The modules import only frozen `BufferRelay` and its frozen `MemoryTransfer`/Std
closure. Development used Lean 4.31.0. Every Lean compiler command used one thread,
`-j1 -s16384 -DwarningAsError=true`, `LEAN_NUM_THREADS=1`,
`LEAN_STACK_SIZE_KB=16384`, a 120-second timeout/CPU bound, and a 3 GiB address-space
limit. Compiler invocations were serialized.

`PointerAxioms.lean` explicitly names every source declaration for axiom auditing,
including the operational definitions, relations, refinement theorems, and
examples. The final exact dependency output is recorded in `results.json`. Only `propext`, `Classical.choice`, and `Quot.sound` are
permitted; no admitted proof, native-decision proof, or custom axiom is used.

| Build | Wall s / peak RSS KiB | Exit |
|---|---|---:|
| `PointerCore` export | 3.79 / 794624 | 0 |
| `PointerRelay` export | 4.55 / 803044 | 0 |
| 92-declaration axiom audit | 0.34 / 726760 | 0 |

Two source modules were required to stay within the address-space bound:
`PointerCore` (state, steps, evaluators, drain proofs), then `PointerRelay`
(whole-execution refinement, reachability, effects, and examples).
The public namespace and `import PointerRelay` API remain unchanged. A monolithic
version elaborated successfully without `-o` but repeatedly crashed during
export. Bounded `/proc` sampling measured 3,141,784 KiB virtual size against the
3,145,728 KiB cap (~4 MiB headroom). Splitting solved the export
failure under the original limit. This is a tooling/resource failure, not a successful
monolithic proof export. Measurements reuse cached frozen imports; the integrated
replay has independent build measurements. Failed elaborations are retained rather
than counted as successful builds.
