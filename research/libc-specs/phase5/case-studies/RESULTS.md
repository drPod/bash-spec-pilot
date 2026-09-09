# Verification results: coreutils `head_bytes` / `wc_lines`

`semax_body` for two pinned GNU functions beyond `simple_cat`/UTF-8: `head_bytes` (`head -c N`, `head.c:774-797`) and `wc_lines` (`wc -l`, `wc.c:266-330`). Coq/VST case studies, not the Lean script fragment ([`../evaluation/DRAFT-PAPER.md`](../evaluation/DRAFT-PAPER.md)).

Both body theorems checked; differential tests 100/100 under mocks.

Receipts: `~/agent-jobs/astra-research/phase5/runs/<name>.{json,log}` (one `coqc` / `clightgen` / `gcc` per `run_vst.py` invocation).

| Case | Body theorem | Status |
|---|---|---|
| `head_bytes` | `body_head_bytes` in `coq/HeadBytesBody.v` | **CHECKED** (`case6-s-HeadBytesBody` exit 0; replay `case6-replay1-HeadBytesBody` 8.57 s; audit `case6-replay1-CaseAudit`: 7 standard VST/CompCert axioms) |
| `wc_lines` | `body_wc_lines` in `coq/WcLinesBody.v` | **CHECKED** (`case9-wc55-WcLinesBody` exit 0, 25.2 s; replay `case9-replay1-WcLinesBody` 24.8 s; same axiom set). Covers byte-loop, sentinel + `rawmemchr` (under assumed `rawmemchr_spec`), read-error, EOF, modular `Int64.repr` out-cells. Null-pointer branch is a checked funspec (`wc_lines_null_spec`) only, not a second `semax_body`. |

Differential tests (`tests/`): 100/100 against compiled fragments with mocked `safe_read`, `xwrite`, `rawmemchr`; replayed twice (`case-replay8-*`). Finite execution under mocks, not a safety proof; no real `rawmemchr` or uintmax_t wrap. [`tests/TESTS.md`](tests/TESTS.md), `tests/RESULTS.json`.

## Replay receipts (from-scratch, 2026-09-08 08:59:37–09:00:28 UTC)

Container `/home/coq/phase5/case-studies9`. Earlier head-only `case6-replay1-*` superseded.

| Receipt | File | Elapsed |
|---|---|---|
| `case9-replay1-head_bytes_fragment` | `generated/head_bytes_fragment.v` (since `case4-clightgen-2`) | 0.74 s |
| `case9-replay1-wc_lines_fragment` | `generated/wc_lines_fragment.v` (since `case4-clightgen-3`) | 0.80 s |
| `case9-replay1-CaseWorld` | `coq/CaseWorld.v` | 0.75 s |
| `case9-replay1-CaseSpecs` | `coq/CaseSpecs.v` | 0.97 s |
| `case9-replay1-HeadBytesBody` | `coq/HeadBytesBody.v` | 8.56 s |
| `case9-replay1-WcLinesBody` | `coq/WcLinesBody.v` | 24.82 s |
| `case9-replay1-CaseAudit` | `coq/CaseAudit.v` | 13.43 s |

Container sources hash-identical to `coq/*.v` (`case-results.json`). `grep -n "Admitted\|Axiom\|admit" coq/*.v` empty except a comment in CaseAudit.v.

### Checked statements

```
body_head_bytes : semax_body Vprog Gprog f_head_bytes (head_bytes_spec _errno _head_bytes)
body_wc_lines   : semax_body Vprog Gprog f_wc_lines   (wc_lines_spec _errno _wc_lines)
```

`f_wc_lines` is CompCert 3.15 Clight of `src/tu/wc_lines.frag.c` (sha256 `7d22d9fd…`, `wc.c` 266–330). `Gprog` = `safe_read_spec` (reused), `quotearg_spec` / `error_spec` (reused), `rawmemchr_spec` (assumed glibc), `wc_lines_spec`. PRE: `valid_world s`, fd in range; POST: `WcLines 16384 s b t lines bytes`; on `true`, out-cells hold `Int64.repr lines` / `Int64.repr bytes`; on `false` untouched. Both counting arms: `!long_lines` byte loop (`count_nl`) and `long_lines` sentinel/`rawmemchr`. Density only selects the arm.

`f_head_bytes` from `src/tu/head_bytes.frag.c` (sha256 `ae9f42de…`, `head.c` 774–797, [`PROVENANCE.md`](PROVENANCE.md)). `Gprog` = `safe_read_spec` (from `../utility-reuse/coq/IOSpecs.v`), `error_spec`, `quoteaf_spec`, `xwrite_stdout_spec`, `head_bytes_spec`:

- PRE: `valid_world s`, `0 <= N <= Int64.max_unsigned`, `0 <= in_fd s <= Int.max_signed`, filename pointer-or-null; SEP `has_ext s`, errno cell.
- POST: `HeadOutcome 8192 N s e b t e'`.

### Functional summaries (`CaseWorld.v`)

- `head_true_prefix`: on `true`, `delivered t = delivered s ++ extra`, `extra ++ unread t = unread s`, `Zlength extra <= N`, and `Zlength extra = N \/ unread t = []`.
- `head_false_reports`: on `false`, fewer than N bytes delivered; one diagnostic with genuine errno (`<> EINTR`, in `[1, Int.max_signed]`).
- `wc_true_counts` / `wc_false_reports`: `lines = count_nl (unread s)`, `bytes = Zlength (unread s)` on success. These follow the relation; they are facts about C only via the body theorems above.

## Trust boundary (assumed, not body-verified)

- `xwrite_stdout_spec` / `CaseWorld.XWrite`: on return, bytes accepted by the stdout stream (`stdout_put`); no syscall schedule consumed. Failing `fwrite` makes the source `error (EXIT_FAILURE, ...)` and never return. An earlier model built `XWrite` on `IOW.FullWrite` (buffered `fwrite` as `full_write`’s write(2) loop); that was a misrepresentation. `delivered` means “accepted by the stream”, not “reached fd 1”; `close_stdout` is outside `head_bytes`. Pi `xwrite_main` tests: buffered `/dev/full` can return without failure; unbuffered exits with ENOSPC.
- `error_spec`, `quoteaf_spec`: diagnostic as errno; quoting pure.
- `rawmemchr_spec`: first occurrence at or after `&buf[i]` in the local buffer; caller guarantees existence (sentinel). glibc may read past the found byte in the same object; footprint here is the whole object. No body proof of `rawmemchr`.

## Not done

- `wc_lines_null_spec` has no second `semax_body`; `body_wc_lines` assumes valid out-pointers ([`NEXT.md`](NEXT.md)).
- No VSU linking.
- Funspec uses `Int64.repr` of exact totals (source modular semantics); wrap-around not separately tested.

## `forward_call` hang (reuse lesson)

Fused `Scall (Some _t'1); Sset` hung in `after_forward_call` → `simplify_remove_localdef_temp`. Fix: `repeat simple apply seq_assoc1` before every `forward_call` (as in `CatBody.v`). Nested `A * B` in one SEP slot: `flatten_sepcon_in_SEP`. Local `tarray tschar 8192` vs reused `tarray tuchar n`: `buffer_tschar_tuchar`, `buffer_split`, `buffer_join`. Diagnostic receipts `case6-diag1..9-*` are not evidence.

## Identities (sha256)

| File | sha256 |
|---|---|
| `coq/CaseWorld.v` | `3b5bdd2cc30a2293544277b07b70e19eee36c502c6cfd9642cfc7b3d4b869356` |
| `coq/CaseSpecs.v` | `248c00dbb0afd5cfe9b4c6248747e297b98def169e7e585442ca2706e37ce579` |
| `coq/HeadBytesBody.v` | `34a0d0062f8fe963eabb8fff435932b7b4ee4e09c9a8090ad99ecf690f65a6b6` |
| `coq/WcLinesBody.v` | `998e78e7acdb328270677a468ce760a22a4534896acca9b3255d4ab68577421f` |
| `coq/CaseAudit.v` | `923448130417addd5622d33b8d9e515bcb8b82c961036096f1978f0e2b7b7e92` |
| `generated/head_bytes_fragment.v` | `a23c80107e2a16ada79b0bce064e4e2967b32ac015d05e913845a32117b18bc6` |
| `generated/wc_lines_fragment.v` | `4d4efcc671701151175246bb659f422d8ede6b3762ab87586cf0a2abca58dcee` |
| `src/tu/head_bytes.frag.c` | `ae9f42de06cf55ca1bfcc8720986b32f8c8d14b8063af8374dece0b886bbc4b7` |
| `src/tu/wc_lines.frag.c` | `7d22d9fdfd6f97e3f149088c597840afc90f7912eba038fdf5941b94978c26fd` |
| `src/tu/xwrite_stdout.frag.c` (provenance only) | `bb26b78f6b0df6e41c22497b27709f30225627f42326fa80fd85625ae8a5262c` |

Line-range correction: [`PROVENANCE.md`](PROVENANCE.md). Superseded designs (right-recursive `HeadBytes`, `XWrite` on `FullWrite`, `WcLinesShort`): `case4-*` receipts kept, not evidence. Wrapper-ident: [`TRANSFER-ASSESSMENT.md`](TRANSFER-ASSESSMENT.md).
