# Raising and caught relay correspondence (root151)

Relate exported `relay_raising` / `relay_caught` to `BufferRelay` on status and seven root fields.

Root151 accepts the actual entry proofs and exact status plus seven root fields against `BufferRelay.run`, `runDetailed`, and schedule consumption on the standard initial state. Read failure becomes `ReadError(-1)`; catch restores status 1 on the same post-state. Action-definition identities, counter headroom and explicit fuel remain premises. Fresh source and audit compile successfully; 28 named assumption outputs use standard Lean axioms only. General-state same-post correspondence is also proved (root147). No assumed whole-callee simulation or wrapper equality is needed by the final theorems. The older conditional `hwrap` lemma is not the final bridge.

Not an arbitrary-Related raising theorem (scope-audit-152).

**Historical vs current.** “Complete dependency artifact replay and final research reconciliation remain pending” was true at this receipt. Later full30/source197/packaging: [../../FINAL-DELIVERY.md](../../FINAL-DELIVERY.md).

Receipt: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-raising-seven-review-151/ROOT-REVIEW.json`.
