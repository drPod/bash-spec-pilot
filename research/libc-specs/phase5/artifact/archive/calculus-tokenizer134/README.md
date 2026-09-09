# calculus-tokenizer134

Immutable accepted tokenizer117 + CLI133 closure.

- Generic `CalculusTokenize.lean` remains 5193c045… (root103/117).
- Older `CompareMain.lean` remains 6b917746… and is not the CLI driver.
- Corrected `CalculusTokenizeChunks.lean` is the root133 compatibility reexport (ef2baca1…), not the OOM draft.
- Drivers are `CompareTotalMain` / `ExportTotalMain` + `CalculusTokenizeTotal`.
- CopyEq/CopyAudit close the CLI-vs-accepted tokenizer equality gap.
- Does **not** package Bash text parsers or raising proofs.
- Lake file is identity-only; replay uses sequential direct Lean 4.31.0.
- Pair replay uses the explicit 33-name root130 manifest (wildcard glob is rejected).
