# Residual-schedule extension (root67)

Preserve residual read/write schedules in the general outer-loop and `runEntry` theorems.

Root accepted `CalculusRelaySchedules.lean` after checkpoint2 compiled in 7.05s with pinned Lean 4.31.0, single thread and 3GiB address-space cap. All four printed theorem assumptions are standard Lean axioms. The original source-only header is retained to preserve the exact compiled source bytes. The general outer-loop theorem preserves five existing root fields plus actual residual read/write schedules. The `runEntry` theorem uses the existing fresh initial state and explicit integer headroom.

**Limitations (this receipt).** Arbitrary shared-state `runEntry` and general calculus script/query composition remain open **here**. Not an OCaml-source or Coq-to-Lean proof.

**Historical vs current.** Later Shared70 (arbitrary related seven-field state), root87/92 (command/query). Evidence hashes: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-calculus-schedules-67/ROOT-REVIEW.json` verifies source/log hashes and 11 dependency source/olean identities.
