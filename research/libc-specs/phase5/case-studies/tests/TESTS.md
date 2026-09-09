# Differential tests (not a C proof)

Replay from a repo checkout (stdlib only):

```
python3 research/libc-specs/phase5/case-studies/tests/replay.py
```

The script hashes `src/tu/*.frag.c` against `src/tu/FRAGMENTS.json`, copies those
unchanged fragments plus `harness.c` / `xwrite_main.c` into a **fresh** container
workdir `/home/coq/phase5/case-replay8-<UTC+random-runid>` (mkdir only; never
`rm -rf`), concatenates `xwrite_comment_open.h` + `xwrite_stdout.frag.c` into
**runtime-only** `xwrite_body.c` (not a checked-in rewrite of the function), then
compiles/runs via `research/libc-specs/phase5/run_vst.py` (shared
`~/.cache/bash-spec-pilot/phase3-compiler.lock`). Receipt names include the runid
so a second invocation does not trip the existing-receipt guard. `run_vst()`
reads the new JSON receipt (command, workdir, `exit_status` and
`timing_exit_status`, `log_sha256` vs actual log); wrapper returncode is not
treated as the program outcome. The script replays twice in one process to
prove collision-free repeatability.

Pinned fragment SHA256 (unchanged, match `src/tu/FRAGMENTS.json`):

| fragment | sha256 |
|---|---|
| head_bytes.frag.c | `ae9f42de06cf55ca1bfcc8720986b32f8c8d14b8063af8374dece0b886bbc4b7` |
| xwrite_stdout.frag.c | `bb26b78f6b0df6e41c22497b27709f30225627f42326fa80fd85625ae8a5262c` |
| wc_lines.frag.c | `7d22d9fdfd6f97e3f149088c597840afc90f7912eba038fdf5941b94978c26fd` |

## What ran (replay-8, two collision-free runids)

All gcc and binaries went through `research/libc-specs/phase5/run_vst.py` (compiler lock, container `phase5-vst`).

Runids: `20260908T061038Z-3d6a35a6` and `20260908T061040Z-c1a83a0d`.

Per run (same outcomes both times):

- `gcc -O0 -std=c11 -Wall -o harness harness.c` → exit **0**
- `./harness` → exit **0**; log contains `SUMMARY passed=100 failed=0`; seed `20260907`, 40 random trials (80 of the 100 checks)
- `gcc ... -o xwrite_harness xwrite_main.c` → exit **0**
- `./xwrite_harness ok` → exit **0**, stdout exactly `hello\n`
- `./xwrite_harness zero` → exit **0**, empty stdout
- `./xwrite_harness full` → exit **1** and `timing_exit_status` **1**; log `XWRITE_ERROR status=1 errnum=28 calls=1` (ENOSPC / `errno.ENOSPC`). Nonzero is the required error path, not a wrapper exception.

Fail-closed negative: private temp missing receipt and mismatched-command receipt rejected without extra C compilation.

Historical `case-replay7-*` and `case-differential7-*` receipts remain; workdirs were not deleted.

## Directed cases

**head_bytes** (mock `safe_read`, mock `xwrite_stdout` that copies bytes): zero request (no read), exact 5, EOF before request, 8192 one block, 8193 two reads, short reads, read error, error after partial write.

**wc_lines** (mock `safe_read`, real `rawmemchr` loop): empty, dense small, no NL, trailing NL sentinel, 16384 all-NL, sparse block then second block, dense→sparse, sparse→dense (long_lines / rawmemchr arm), short reads, SAFE_READ_ERROR, NULL out pointers.

Independent oracle: prefix length min(req, len); newline count by byte scan. uintmax overflow not exercised.

## Assumptions (mocks) and missing coverage

- `head_bytes` does **not** execute `xwrite_stdout.frag.c`; capture mock assumes total write unless `g_xwrite_fail`.
- `error` records and exits only if `status != 0`.
- `quoteaf` / `quotef` identity.
- `rawmemchr` is a naive scan (required for the long_lines arm).
- `fpurge` mapped to glibc `__fpurge`.
- `xwrite_stdout.frag.c` is not a complete translation unit: it starts mid-comment. Concatenation with `xwrite_comment_open.h` is required at replay time. `#include` cannot close a comment across files.
- Buffered `fwrite` to `/dev/full` did **not** fail in an earlier attempt (`case-differential7-run-xwrite-full` exit 4). Honest error path needed unbuffered stdout in the driver, not a change to the fragment.
- `xwrite_harness.c` is a leftover include-based driver (no unbuffered `/dev/full`); replay does not compile it.
- No Coq/VST proof of these C functions is claimed or replayed here.

These tests are differential execution, not verification.

Orchestrator review corrected the negative checks to call the real `assert_receipt` validator. Both missing-receipt and wrong-command checks rejected as intended. The two C replays above precede this validation-only change; their historical script hash is retained in RESULTS.json, with the current hash in `validator_followup`.
