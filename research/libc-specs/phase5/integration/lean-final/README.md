# Lean shell composition reference

Compose relay calls with file redirection and shell sequencing in an independently stated Lean model.

`StatefulFinal` threads unread input and residual read/write schedules through sequential calls. Root accepted `ScheduleConsumption`, `StatefulFinal`, and `StatefulFinalAudit` (`root-schedule-repair-55/ROOT-FINAL-RECEIPT.json`). Targeted replay69: eight sequential Lean compilations and 18 audit declarations (`root-stateful-replay-69/ROOT-RECEIPT-AUDIT.json`).

No checked connection to the Coq/VST C execution proof. Coq-final is a separate accepted subchain, not a replacement for the original Lean-final requirement (later bounded by root87/92 and source197; see [../PROOF-CHAIN.md](../PROOF-CHAIN.md) and [../../FINAL-DELIVERY.md](../../FINAL-DELIVERY.md)). These theorems do not establish host-OS behavior or import the Coq fd-table and C-body theorems. Replay69 is a targeted addition, not a full25-entry artifact replay.

## Checked behavior

`LeanFinal.lean` proves composition under explicit primitive hypotheses and supplies a concrete instance parameterized by input and read/write schedules. It distinguishes truncate from append, preserves state on an empty-path open failure, and includes successful and failing relay examples. Its concrete instance reuses the same protocol parameters for each call; use `StatefulFinal` for sequential consumption.

`ScheduleConsumption.lean` defines an instrumented executor and proves that its result projects to `BufferRelay.execute`. Remaining schedules equal the original lists with the actual call counts dropped. Exhausted schedules stay empty while the model supplies default actions. `BufferRelay.lean` is unchanged by this instrumentation.

Stateful composition theorems:

- Redirect followed by direct passes residual input and both residual schedules to the second call, restores terminal output routing, and preserves the first file update.
- A successful redirect followed by a conditional marker puts only the marker on the terminal and leaves the consumed protocol state in the result.
- An empty-path redirect fails with status 1, preserves state, and skips a conditional marker.
- Two direct calls consume `abc` once; resetting the protocol would deliver it twice.
- With reads `[-1, 3]`, a second call can recover after the first read error; resetting the schedule repeats that error. The successful `abc` example counts two reads, including the EOF read.

All 18 declarations named in `StatefulFinalAudit.lean` report only `propext`, `Classical.choice`, and `Quot.sound`. Earlier files in `results/` describe the older `LeanFinal` build and are not receipts for this later stateful result.

## Build

Lean 4.31.0, one compiler thread, warnings as errors, shared research compiler lock:

```sh
cd research/libc-specs/phase5/integration/lean-final
flock -w 5 ~/.cache/bash-spec-pilot/phase3-compiler.lock \
  timeout 180 env LEAN_NUM_THREADS=1 MIMALLOC_ARENA_RESERVE=65536 \
  prlimit --as=3221225472 -- lake build StatefulFinal StatefulFinalAudit
```

A memory limit or timeout is a failed build, never acceptance.
