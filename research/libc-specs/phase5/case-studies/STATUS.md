# Case-studies status (`head_bytes` / `wc_lines`)

**Current.** `body_head_bytes` and `body_wc_lines` are checked Coq/VST `semax_body` theorems for pinned coreutils fragments. Wrapper-ident lift is in [`TRANSFER-ASSESSMENT.md`](TRANSFER-ASSESSMENT.md). Open items: [`NEXT.md`](NEXT.md). These are additional Coq case studies, not the Lean script-fragment connection in [`../evaluation/DRAFT-PAPER.md`](../evaluation/DRAFT-PAPER.md).

**Scope.** coreutils `9530a144…` (v9.4) `head_bytes` (full function, `head.c` 774–797 after the brief’s off-by-one) and `wc_lines` (`wc.c` 266–330). Reuses gnulib `safe_read` (checked body in `../utility-reuse/coq/SafeReadBody.v`, not re-proved). Frozen brief originally listed `head_bytes` as 774–796 (hash `ebdb38f1…`); that range does not parse (`case4-clightgen-1`, exit 2). Corrected fragment hash `ae9f42de…`.

**Evidence.** Receipts and hashes: [`RESULTS.md`](RESULTS.md). Provenance: [`PROVENANCE.md`](PROVENANCE.md). Differential tests: [`tests/TESTS.md`](tests/TESTS.md).

## Historical local stages (superseded; not current paper claims)

| Stage | What was true then | What replaced it |
|---|---|---|
| case-studies4 (2026-09-07) | `CaseWorld`/`CaseSpecs` checked; `XWrite` on `FullWrite`; `WcLinesShort`; `HeadBytesBody` hung in `forward_call`; **no** body proof | stdio `stdout_put`; whole-function `WcLines`; `seq_assoc1` hang fix |
| case-proofs-6 / -8 (2026-09-08) | `body_head_bytes` checked (`case6-s-HeadBytesBody`); `WcLinesBody` buffer lemmas only | `body_wc_lines` |
| case-proofs-9 | `body_wc_lines` checked (`case9-wc55-WcLinesBody`); replay `case9-replay1-*` | current `RESULTS.md` |

`wc_lines_null_spec` as a second `semax_body` and VSUs remain open.
