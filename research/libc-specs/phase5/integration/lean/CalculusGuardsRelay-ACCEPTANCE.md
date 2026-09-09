# Guard integration (root89)

Thread write_block/read_block guards and `try/catch` through actual exported relay-family bodies.

Root89 accepted five new modules after independent direct Lean compiles (all exit 0, each below 0.6s, shared lock / 3GiB cap). Nineteen exact audit outputs: 15 new theorems and 4 dependencies; standard Lean axioms only; two invariant conversions axiom-free.

`CalculusGuardsRelay` threads the five guard facts through `InnerInvW` into the actual inner step/loop, with failure and `AssertionFailure` alternatives. `CalculusGuardsRead` derives nonnegative capacity on the passing branch; the failing range check occurs after bookkeeping state updates, not before. `CalculusTryCatch` characterizes the actual `relay_caught` body for each supplied callee result.

Capacity upper bound, byte-valued input and counter headroom remain imported. `relay_raising` itself has no whole-body functional proof **in this receipt** (later root151). No general nonfailure claim.

Receipt: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-guard-integration-review-89/ROOT-REVIEW.json`.
