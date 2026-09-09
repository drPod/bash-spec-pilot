# Raising and caught relay correspondence

Root151 accepts the actual `relay_raising` / `relay_caught` entry proofs and exact status plus seven root fields against `BufferRelay.run`, `runDetailed`, and schedule consumption on the standard initial state. Read failure becomes `ReadError(-1)`; catch restores status 1 on the same post-state. Action-definition identities, counter headroom and explicit fuel remain premises.

Fresh source and audit compile successfully; 28 named assumption outputs use standard Lean axioms only. General-state same-post correspondence is also proved. No assumed whole-callee simulation or wrapper equality is needed by the final theorems. The older conditional `hwrap` lemma is not the final bridge.

Receipt: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-raising-seven-review-151/ROOT-REVIEW.json`. Complete dependency artifact replay and final research reconciliation remain pending.
