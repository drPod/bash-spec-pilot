# Full-export tokenizer identities (root117)

Kernel-check text→token and parse identities for the three original export bodies.

Root117 independently accepts all six full-export kernel identities. Sixteen modules freshly compiled at root116/117 against accepted `genericTokenize` `5193c045` and literal module `8616210b`. Exact source/log/olean hashes and six named standard-Lean axiom outputs verified. `writeBlockText`, `relayText` and `readBlockText` tokenize with `tokenizeTotal` to the accepted token lists, and `parseText` yields the exact accepted bodies. Proof uses checked literal-to-character-list identities and bounded character-chunk composition; no `native_decide`, no whole-string concatenation, no generator correctness assumption.

This closes the previously open three-export kernel-text boundary **at this receipt**.

Does not establish OCaml-source semantics or C/Coq-to-Lean equivalence.

**Historical vs current.** “The actual comparison harness must still be switched… saved 1593 corpus rerun” was open at root117. Later harness133 accepted universal copy equality and the corrected CLI on the saved 1,593 comparisons and 12 negatives.

Runtime receipt: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-all-tokenizer-review-117/ROOT-REVIEW.json`.
