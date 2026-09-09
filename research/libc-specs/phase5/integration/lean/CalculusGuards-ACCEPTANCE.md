# write_block guards (root82)

Derive the five range/assert facts of the exported `write_block` guard prefix.

Accepted after independent root review 82, 2026-09-08. Fresh direct Lean 4.31.0 compiles of `CalculusGuards` and `CalculusGuardsAxioms` exited 0 (0.655s and 0.256s), under the shared compiler lock and 3GiB address-space limit. All 11 exact audit names use only standard Lean axioms. The actual `write_block` guard prefix establishes `0 ≤ off ≤ n ≤ len ≤ cap` and `n ≤ rangeMax` when passed. The whole-body corollary derives these five formerly assumed facts, while retaining byte/length state invariants, counter headroom, attribute-update existence and the nonnegative schedule case.

Failure and `AssertionFailure` remain explicit outcomes; this is not a general no-failure theorem.

**Historical vs current.** “Relay integration and read_block guard work continue separately” was true at root82; later root89.

Runtime receipts: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-guards-review-82/ROOT-REVIEW.json`.
