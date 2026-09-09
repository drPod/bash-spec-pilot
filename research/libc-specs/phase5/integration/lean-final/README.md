# Lean shell composition reference

The accepted Lean development composes relay calls with file redirection and shell
sequencing. The original end-to-end Lean-final requirement remains open: these modules
use an independently stated Lean model and have no checked connection to the Coq/VST
C execution proof. Coq-final is a separate accepted subchain, not a replacement for that
requirement. See [PROOF-CHAIN.md](../PROOF-CHAIN.md).

## Checked behavior

`LeanFinal.lean` proves composition under explicit primitive hypotheses and supplies a
concrete instance parameterized by input and read/write schedules. It distinguishes
truncate from append, preserves state on an empty-path open failure, and includes
successful and failing relay examples. Its concrete instance reuses the same protocol
parameters for each call; use `StatefulFinal` for sequential consumption.

`StatefulFinal.lean` threads unread input and residual read/write schedules through
`direct` and nonempty `redirect` calls. `ScheduleConsumption.lean` defines an instrumented
executor and proves that its result projects to the existing `BufferRelay.execute`.
It proves that remaining schedules equal the original lists with the actual call counts
dropped. Exhausted schedules stay empty while the model supplies default actions.
`BufferRelay.lean` itself is unchanged by this instrumentation.

The stateful composition theorems establish that:

- Redirect followed by direct passes the residual input and both residual schedules to
  the second call, restores terminal output routing, and preserves the first file update.
- A successful redirect followed by a conditional marker puts only the marker on the
  terminal and leaves the consumed protocol state in the result.
- An empty-path redirect fails with status 1, preserves state, and skips a conditional marker.
- Two direct calls consume `abc` once; resetting the protocol would deliver it twice.
- With reads `[-1, 3]`, a second call can recover after the first read error; resetting
  the schedule repeats that error. The successful `abc` example counts two reads,
  including the EOF read.

These are claims about the scheduled Lean reference. They do not establish host-OS
behavior or import the Coq fd-table and C-body theorems.

## Acceptance evidence

Root accepted `ScheduleConsumption`, `StatefulFinal`, and `StatefulFinalAudit` after
`lake build StatefulFinal StatefulFinalAudit` completed successfully (10 jobs). A
subsequent cached build saved the log and exact three-source hashes in
`/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-schedule-repair-55/ROOT-FINAL-RECEIPT.json`.
The saved log is `root-final-build.log` in that directory. Root rechecked those hashes
against the repository and log on 2026-09-08.

All 18 declarations named in `StatefulFinalAudit.lean` report only the standard Lean
axioms `propext`, `Classical.choice`, and `Quot.sound`; none adds project axioms.
The earlier files in `results/` describe the older `LeanFinal` build and are not receipts
for this later stateful result. The immutable `artifact/archive/stateful55` closure passed targeted replay69: eight
sequential direct Lean compilations and18 audit declarations. Its root receipt is
`/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-stateful-replay-69/ROOT-RECEIPT-AUDIT.json`.
This is a targeted addition, not a full25-entry artifact replay.

## Build

The project pins Lean 4.31.0, uses one compiler thread, and treats warnings as errors.
Run builds only during its assigned compiler turn. This bounded command shares the
research compiler lock and uses a per-process mimalloc arena setting:

```sh
cd research/libc-specs/phase5/integration/lean-final
flock -w 5 ~/.cache/bash-spec-pilot/phase3-compiler.lock \
  timeout 180 env LEAN_NUM_THREADS=1 MIMALLOC_ARENA_RESERVE=65536 \
  prlimit --as=3221225472 -- lake build StatefulFinal StatefulFinalAudit
```

A memory limit or timeout is a failed build, never acceptance. No tmux or system-wide
configuration changes are needed for this command.
