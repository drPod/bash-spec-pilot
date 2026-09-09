# Verification results (case-studies: coreutils `head_bytes` / `wc_lines`)

Two real, pinned GNU coreutils functions beyond `simple_cat`/UTF-8:
`head_bytes` (`head -c N`, `head.c:774-797`) and `wc_lines` (`wc -l`,
`wc.c:266-330`). Claude authored fragment extraction, adapters, relations,
funspecs and proofs (sessions `nonutf8-cases-4` 2026-09-07, `case-proofs-6`
and `case-proofs-8` 2026-09-08); Grok/Pi did the static contract audit
(`pi-reviews/case-contract-audit-6`) and the differential tests (`tests/`,
Pi `case-differential-7`, `case-replay-7`, `case-replay-fix-8`). No human
proof authoring is implied. Every receipt named below is one `coqc` /
`clightgen` / `gcc` invocation run directly by `run_vst.py` (global compiler
lock, no pipe, no loop masking the exit status); receipts:
`~/agent-jobs/astra-research/phase5/runs/<name>.{json,log}`.

## Bottom line

| Case | Body theorem (`semax_body`) | Status |
|---|---|---|
| `head_bytes` (whole function) | `body_head_bytes` in `coq/HeadBytesBody.v` | **CHECKED** (`case6-s-HeadBytesBody` exit 0; fresh replay `case6-replay1-HeadBytesBody` exit 0, 8.57 s; assumption audit `case6-replay1-CaseAudit`: only the 7 standard VST/CompCert axioms) |
| `wc_lines` (whole function, both counting branches) | `body_wc_lines` in `coq/WcLinesBody.v` | **CHECKED** (`case9-wc55-WcLinesBody` exit 0, 25.2 s; fresh replay `case9-replay1-WcLinesBody` exit 0, 24.8 s; audit `case9-replay1-CaseAudit`: only the standard VST/CompCert axioms). Covers the byte-loop arm, the sentinel + `rawmemchr` arm (under `rawmemchr_spec`, an assumed glibc contract), the read-error return, the EOF exit, and `Int64.repr` (modular uintmax_t) out-cells. The defensive null-pointer branch is covered only as a checked funspec (`wc_lines_null_spec`), not yet as a second `semax_body`. |

Differential tests (Pi, `tests/`): 100/100 checks against the compiled
pinned C fragments with mocked `safe_read`, mocked `xwrite` output and mocked
`rawmemchr`; replayed twice from source (`case-replay8-*`). They are finite
execution evidence about the fragments under mocks, not a safety or
correctness proof, and they do not exercise the real `rawmemchr` or
uintmax_t wrap-around. See `tests/TESTS.md`, `tests/RESULTS.json`.

## What is CHECKED (direct receipts, all exit 0)

Fresh from-scratch replay 2026-09-08 08:59:37-09:00:28 UTC (container area
`/home/coq/phase5/case-studies9`, all `.vo`/`.glob` deleted first, one
receipt per file, dependency order; the earlier head-only replay
`case6-replay1-*` of 07:39-07:40 UTC in `case-studies6` is superseded but kept):

| Receipt | File | Elapsed |
|---|---|---|
| `case9-replay1-head_bytes_fragment` | `generated/head_bytes_fragment.v` (clightgen output, unchanged since `case4-clightgen-2`) | 0.74 s |
| `case9-replay1-wc_lines_fragment` | `generated/wc_lines_fragment.v` (unchanged since `case4-clightgen-3`) | 0.80 s |
| `case9-replay1-CaseWorld` | `coq/CaseWorld.v` | 0.75 s |
| `case9-replay1-CaseSpecs` | `coq/CaseSpecs.v` | 0.97 s |
| `case9-replay1-HeadBytesBody` | `coq/HeadBytesBody.v` | 8.56 s |
| `case9-replay1-WcLinesBody` | `coq/WcLinesBody.v` | 24.82 s |
| `case9-replay1-CaseAudit` | `coq/CaseAudit.v` (Print Assumptions for both bodies) | 13.43 s |

Container sources were checked hash-identical to `coq/*.v` after the replay
(see `case-results.json`). `grep -n "Admitted\|Axiom\|admit" coq/*.v` is
empty apart from the word in CaseAudit.v's comment.

### The checked statements

```
body_head_bytes : semax_body Vprog Gprog f_head_bytes (head_bytes_spec _errno _head_bytes)
body_wc_lines   : semax_body Vprog Gprog f_wc_lines   (wc_lines_spec _errno _wc_lines)
```
`body_wc_lines` (`coq/WcLinesBody.v`): `f_wc_lines` is the CompCert 3.15
Clight of the byte-identical fragment `src/tu/wc_lines.frag.c` (sha256
`7d22d9fd…`, `wc.c` 266-330, whole function); `Gprog` = `safe_read_spec`
(reused unchanged), `quotearg_spec` / `error_spec` (reused), `rawmemchr_spec`
(assumed glibc contract) and `wc_lines_spec` (both out-pointers valid; PRE
`valid_world s`, fd in range; POST returns `b` with
`WcLines 16384 s b t lines bytes`, and on `true` the out-cells hold
`Int64.repr lines` / `Int64.repr bytes`, i.e. the source's modular uintmax_t
totals; on `false` they are untouched). The proof walks both counting arms:
the `!long_lines` byte loop (`forward_while` over `field_address` pointers,
per-byte `lines += *p++ == '\n'` matched to `count_nl`) and the
`long_lines` arm (sentinel store `*end = '\n'`, `rawmemchr` loop with the
sentinel as the existence witness, first-occurrence post used to skip
newline-free stretches). The density test only selects the arm; the
relation does not depend on it.


with `f_head_bytes` the CompCert 3.15 Clight of the byte-identical fragment
`src/tu/head_bytes.frag.c` (sha256 `ae9f42de…`, `head.c` 774-797, see
`PROVENANCE.md`), `Gprog` = `safe_read_spec` (reused unchanged from
`utility-reuse/coq/IOSpecs.v`, whose body proof `SafeReadBody.v` is also
unchanged), `error_spec` (reused, status 0), `quoteaf_spec`,
`xwrite_stdout_spec` (new trust-boundary contracts, below), and
`head_bytes_spec`:

- PRE: `valid_world s`, `0 <= N <= Int64.max_unsigned` (every uintmax_t
  value `head -c N` can pass; the previous `N <= SYS_BUFSIZE_MAX` restriction
  flagged by the audit is gone), `0 <= in_fd s <= Int.max_signed`, the
  filename pointer-or-null; SEP `has_ext s`, the errno cell.
- POST: returns `b` with `HeadOutcome 8192 N s e b t e'`, world `t`, errno `e'`.

### Source-preserving functional summary (checked, `CaseWorld.v`)

- `head_true_prefix`: on `true`, stdout received `extra` with
  `delivered t = delivered s ++ extra`, `extra ++ unread t = unread s`,
  `Zlength extra <= N`, and `Zlength extra = N \/ unread t = []`
  (exactly the first N bytes, or the whole input if shorter; EOF is success);
  diagnostics unchanged.
- `head_false_reports`: on `false` (read error after a prefix), fewer than N
  bytes were delivered, the rest is unread, and exactly one diagnostic with a
  genuine errno (`<> EINTR`, in `[1, Int.max_signed]`) was recorded.
- `wc_true_counts` / `wc_false_reports`: the analogous statements for
  `WcLines` (whole input consumed; `lines = count_nl (unread s)`,
  `bytes = Zlength (unread s)`; error case describes the consumed prefix).
  These are consequences of the relation only; `wc_lines`' body proof is
  not done, so they are NOT yet facts about the compiled C.

## Trust boundary (assumed contracts, not body-verified)

- `xwrite_stdout_spec` / `CaseWorld.XWrite` (stdio): when the call returns,
  the bytes were accepted by the stdout stream (`stdout_put`: `delivered`
  extended; no syscall schedule consumed, no call counter, no diagnostic;
  errno unconstrained on success; `n_bytes = 0` touches nothing). A failing
  `fwrite` makes the source `error (EXIT_FAILURE, ...)` and never return, so
  no returning execution is excluded by the contract. **Correction of the
  case-studies4 model**, which had built `XWrite` on `IOW.FullWrite`
  (modeling buffered `fwrite` as full_write's write(2) loop consuming the
  `writes` quota schedule) - a misrepresentation independently flagged by
  the Grok audit. Consequence for reading `delivered` in `HeadOutcome`: it
  means "accepted by the stream", not "reached fd 1"; the flush at exit
  (`close_stdout`) is outside `head_bytes`. Pi's `xwrite_main` tests show the
  real `xwrite_stdout` on `/dev/full` returns without failure when buffered
  and exits with ENOSPC when unbuffered, consistent with this reading.
- `error_spec`, `quoteaf_spec`: diagnostic recorded as errno value; quoting
  is pure (same convention as utility-reuse).
- `rawmemchr_spec` (for `wc_lines`, unused by the head proof): first
  occurrence of the byte at or after `&buf[i]` inside the caller's whole
  local buffer, caller guarantees existence (sentinel). Idealization: glibc's
  vectorized implementation may read past the found byte within the same
  object; the footprint here is that whole object. Leaf assumption, recorded;
  no body proof of `rawmemchr` is claimed.

## What is NOT done

- `wc_lines_null_spec` (the source's defensive `if (!lines_out || !bytes_out)
  return false;`) is a checked funspec but has no second `semax_body`
  theorem yet; `body_wc_lines` assumes both out-pointers are valid.
  `WcLines` covers BOTH counting branches unconditionally (the branch choice
  `long_after`, i.e. the source's `lines - plines <= bytes_read / 15` test,
  selects code that adds the same `count_nl bs`), so the whole-function
  contract is in place; what is missing is the VST proof (NEXT.md).
- No VSU linking for these functions (`utility-reuse`'s VSUs untouched).
- uintmax_t wrap: the funspec gives the out-cells `Int64.repr` of the exact
  totals, which is the source's modular semantics; no unboundedness
  precondition. Nothing tests or proves wrap-around behaviour beyond that.

## How the 240 s `forward_call` hang was diagnosed and fixed (reuse lesson)

The case-studies4 attempt (`case4-hbbody-15`) and this session's first
rewrites (`case6-g`, `case6-h`, `case6-i`: buffer split at the request
count, opaque count, flattened SEP) all hit the wall limit inside the
`forward_call` to `safe_read`. Bisection with diagnostic files (job dir
`case-proofs-8/HeadBytesDiag*.v`, receipts `case6-diag1..9-*`,
`case6-identbench*`; not evidence, kept for the record):

1. VST's `prove_call_setup1`, `prove_call_setup_aux`,
   `forward_call_id1_y_wow` each finish in ~0.1 s; the whole hang is in
   `after_forward_call` -> `simplify_remove_localdef_temp` (30 s+),
   when the call is matched as the fused `Scall (Some _t'1); Sset
   _bytes_read (Etempvar _t'1)` pattern. Opaquing every LOCAL value does not
   help; identifier equality under `simpl` is milliseconds (so it is not a
   name-length effect).
2. Fix: `repeat simple apply seq_assoc1` before every `forward_call`, so the
   call is matched as `Scall (Some _t'1); (Sset ...; ...)` and the `Sset` is
   done by a plain `forward` - the same idiom `utility-reuse/coq/CatBody.v`
   already used. With it the call returns in under a second.
3. Two secondary traps, both fixed: a nested `A * B` in one SEP slot (from
   `rewrite buffer_split` or `unfold buffer_prefix_n`) leaves the Frame evar
   uninstantiated (`flatten_sepcon_in_SEP` after each), and VST's automatic
   `subst` eliminates a `remember`ed count (`rd = Z.min ...`), hidden behind
   the `rd_eq` wrapper until needed.
4. The local `char buffer[BUFSIZ]` (`tarray tschar 8192`) vs the reused
   `tarray tuchar n` footprints: `buffer_tschar_tuchar`, `buffer_split`,
   `buffer_join` (all proved from VST's `memory_block_data_at__tarray_*_eq`
   and `split2_data_at__Tarray_tuchar`; `unfold tarray` is needed before the
   split rewrite).

## Identities (sha256, final)

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

Source/frontend identities and the `head_bytes` 774-797 line-range
correction of the frozen brief: `PROVENANCE.md` (unchanged, still valid).

## Design history (superseded, not evidence)

- case-studies4 (2026-09-07, worker `nonutf8-cases-4`): first `HeadBytes`
  right-recursive relation (checked `case4-coqc-13`, replaced by
  `HeadLoop`/`HeadOutcome`); `XWrite` on `FullWrite` (replaced, see above);
  `WcLinesShort` with a per-block `dense` hypothesis keyed to the current
  block (replaced by whole-function `WcLoop`/`WcLines`; the audit's
  dense-then-all-x counterexample showed the current-block keying was wrong,
  and the branch choice is unobservable anyway); `HeadBytesBody.v` reached
  the `forward_call` and hung (`case4-hbbody-1..15`). Receipts `case4-*`
  are kept.
- case-proofs-6 (2026-09-08 05:39-05:58, quota cut): rewrote
  `CaseWorld.v`/`CaseSpecs.v` (not compiled before the cut).
- case-proofs-8 (06:33-07:50): compiled the chain (`case6-a..e`), the head
  body iterations (`case6-e..s`), diagnostics, audit and replay; started
  `WcLinesBody.v` (buffer lemmas, `case6-wc1..3`).
- case-proofs-9 (07:51-09:05): `body_wc_lines` developed in 55 direct
  receipts `case9-wc1..wc55` (54 tactic-error cycles, each 2-25 s; the
  traps met and fixed are listed in `NEXT.md`), fresh replay `case9-replay1-*`.
