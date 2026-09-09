# case-studies4 worker STATUS

Owner: Claude `nonutf8-cases-4` worker (job dir
`~/agent-jobs/astra-research/phase5/claude-resume/nonutf8-cases-4/`).
Repo area: `research/libc-specs/phase5/case-studies/` (NEW). Container area:
`/home/coq/phase5/case-studies4/`. Start (process launch) 22:25:13 UTC
2026-09-07; first-assignment budget 90 min (target ~23:55 UTC).

## Frozen scope (from Pi review `pi-reviews/nonutf8-case-selection-4/CASE-BRIEF.md`)

- coreutils `9530a144…` (v9.4) `src/head.c` `head_bytes` (full function) and
  `src/wc.c` `wc_lines` (short-line `!long_lines` branch only; `rawmemchr`/AVX2
  out of scope, per the brief's "Honest slice"). Reuses gnulib `safe_read`
  (checked body in `utility-reuse/coq/SafeReadBody.v`, read-only, not
  re-proved).

## Correction to the frozen brief (recorded before any proof attempt)

`CASE-BRIEF.md` records `head_bytes` as `head.c` lines 774-796 (hash
`ebdb38f1...`). Direct inspection of the pinned `head.c` and a clightgen
attempt (`case4-clightgen-1`, exit 2, "syntax error ... before '{'") show that
range excludes the function's closing brace (line 797) - the brief has an
off-by-one and the range does not parse. Corrected to 774-797 (one line
longer, hash `ae9f42de...`, `extract_fragments.py`); `wc_lines`'s 266-330
range was checked and is correct (compiles, ends at the real closing brace).

## Progress log (UTC, actual clock)

- 22:29 Read CLAUDE.md, phase5/REQUIREMENTS.md, CASE-BRIEF.md/REPORT.md, this
  job's FROM-ORCHESTRATOR.md, utility-reuse/{RESULTS,REUSE}.md and
  coq/{IOWorld,IOSpecs}.v (reused read-only). Frozen `frozen/SHA256SUMS`
  verified OK (`sha256sum -c`, 18/18).
- 22:29-22:30 Repo area created; pinned `head.c`/`wc.c`/gnulib headers copied
  from the Pi freeze; `extract_fragments.py` (own copy, asserts against the
  already-frozen fragment hashes) byte-extracted `head_bytes`, `xwrite_stdout`
  (provenance only, not verified), `wc_lines`.
- 22:31 Adapter TUs `head_bytes_fragment.c` / `wc_lines_fragment.c` authored
  (declaration-only externals: `safe_read` via pinned `safe-read.h`; `error`
  fixed-arity; `quoteaf`/`quotef` pure; `xwrite_stdout` and `rawmemchr`
  declared but not modeled/verified - documented ADAPTER DEVIATIONs in each
  file). `head_bytes_entry`/`wc_lines_entry` one-call export wrappers (static
  function retention, same technique as `simple_cat_entry`).
- 22:32 Found and fixed the head_bytes off-by-one above (`case4-clightgen-1`
  exit 2 -> corrected fragment -> `case4-clightgen-2` exit 0).
- 22:33 `case4-clightgen-3` (wc_lines_fragment.c): exit 0. Both TUs have
  `f_head_bytes`/`f_head_bytes_entry` and `f_wc_lines`/`f_wc_lines_entry` in
  the generated `.v`; `generated/SHA256SUMS` recorded.
- 22:34-22:48 `CaseWorld.v` authored and CHECKED (`case4-coqc-14`, exit 0):
  `XWrite` (reuses `IOW.FullWrite` unchanged), `HeadLoop`/`HeadOutcome`
  (two-tier growing-prefix relation, same shape as `utility-reuse`'s
  `CatLoop`/`CatOutcome`, reuses `IOW.SafeRead` unchanged) plus
  `HeadLoop_bounds`/`HeadLoop_valid`/`HeadLoop_conservation` consequence
  lemmas; `count_nl`/`dense`/`WcLoop`/`WcLinesShort` for the wc_lines
  short-line slice. (First design used a right-recursive `HeadBytes`
  relation with its own `HeadBytes_true_delivers` lemma, fully checked at
  `case4-coqc-13`; replaced by the left-recursive `HeadLoop`/`HeadOutcome`
  pair because a VST loop invariant needs a growing-prefix relation.)
- 22:48 `CaseSpecs.v` authored and CHECKED (`case4-specs-2`/refresh, exit 0):
  `quoteaf_spec` (new, pure), `xwrite_stdout_spec` (new; trust boundary,
  built on `XWrite`, NOT a body proof - explicit modeling assumption that
  buffered fwrite retries like `full_write`), `head_bytes_spec`,
  `wc_lines_spec` (new); reuses `IOSpecs.safe_read_spec` and
  `IOSpecs.error_spec`/`quotearg_spec` unchanged.
- 22:52-23:10+ `HeadBytesBody.v` (semax_body for `f_head_bytes`) in progress.
  Real, non-trivial VST obstacles found and solved: (1) `head.c`'s `while
  (bytes_to_write)` compiles to `Swhile`, needing `forward_loop Inv break:
  Post` (loop is followed by `return true;`), with the internal `if
  (bytes_read==0) break;` funneling into the SAME break postcondition as the
  natural `bytes_to_write==0` exit. (2) The local `char buffer[BUFSIZ]`
  compiles to `tarray tschar 8192`, but `safe_read_spec`/`xwrite_stdout_spec`
  need `tarray tuchar 8192`; solved with a PROVED (not assumed) bridge lemma
  `buffer_tschar_tuchar` via VST's own
  `memory_block_data_at__tarray_t{s,u}char_eq` (`field_compat.v`). (3) The
  `if (bytes_to_write < bytes_to_read) bytes_to_read = bytes_to_write;` clamp
  needed an auxiliary loop-invariant bound (`Z.min 8192 (N-consumed) <= br <=
  8192`) to prove the false-branch leaves `bytes_to_read` already equal to
  the clamp - derived and coded (see `RESULTS.md` for the reasoning). Still
  iterating on tactic-level fixes (`case4-hbbody-1` through at least `-15`;
  no exit-0 receipt yet). **No body proof for either function is checked.**
  Do not treat `HeadOutcome`/`WcLinesShort` as verified against the C bodies
  until a `semax_body` receipt reports exit 0.
- Next: close `HeadBytesBody.v`, then `WcLinesBody.v` (shorter - no local
  buffer type mismatch and no bounded-remaining-count bookkeeping, but the
  `dense`/`long_lines` domain hypothesis needs threading through the loop
  invariant the same way `consumed`'s bound does here).

## Session case-proofs-6 / case-proofs-8 (Claude Fable 5.1, 2026-09-08)

Job dirs `~/agent-jobs/astra-research/phase5/claude-resume/case-proofs-6/`
(05:39-05:58 UTC, quota cut after rewriting CaseWorld.v/CaseSpecs.v) and
`.../case-proofs-8/` (06:33-07:50 UTC). Container area
`/home/coq/phase5/case-studies6/` (case-studies4 left untouched).

- CaseWorld.v/CaseSpecs.v rewritten (stdio boundary `stdout_put`/`XWrite`;
  whole-function `WcLoop`/`WcLines`; `rawmemchr_spec`; `wc_lines_null_spec`;
  head N over all uintmax_t; functional summaries) - checked
  `case6-e-CaseWorld`, `case6-e-CaseSpecs`; addresses all Grok
  `case-contract-audit-6` findings.
- HeadBytesBody.v: 240 s `forward_call` hang bisected to VST's
  `after_forward_call`/`simplify_remove_localdef_temp` on the fused
  `Scall;Sset` pattern; fixed with `repeat simple apply seq_assoc1` (+
  buffer split/flatten, `rd_eq` hiding). **`body_head_bytes` CHECKED**
  `case6-s-HeadBytesBody` (exit 0), fresh replay `case6-replay1-*` (6
  receipts, all exit 0), audit `case6-replay1-CaseAudit` (standard axioms
  only). Full detail: RESULTS.md; per-minute log in the job-dir STATUS.md.
- WcLinesBody.v: not started in Coq (plan in NEXT.md).
- tests/: Pi differential tests (100/100, replayed twice), read only here.
- 07:45-07:52 `coq/WcLinesBody.v` started: buffer lemmas (incl. `buf_view`)
  checked (`case6-wc3-WcLinesBody` exit 0; audit `case6-audit2-CaseAudit`);
  body lemma is an `Abort`ed skeleton, NOT a proof.

## Session case-proofs-9 (Claude Fable 5.1, 2026-09-08 07:51-09:05 UTC)

- `coq/WcLinesBody.v`: **`body_wc_lines` CHECKED** (`case9-wc55-WcLinesBody`
  exit 0; 54 failed tactic cycles `case9-wc1..54` kept). Whole function,
  both counting arms, error/EOF paths, modular out-cells. Fresh replay
  `case9-replay1-*` (7 receipts, all exit 0, container `case-studies9`);
  audit `case9-replay1-CaseAudit` extended with body_wc_lines.
- Not done: `wc_lines_null_spec` as a second semax_body; VSUs.
