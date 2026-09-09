# Differential tests (not a C proof)

```
python3 research/libc-specs/phase5/case-studies/tests/replay.py
```

The script hashes `src/tu/*.frag.c` against `src/tu/FRAGMENTS.json`, copies fragments plus `harness.c` / `xwrite_main.c` into a fresh container workdir `/home/coq/phase5/case-replay8-<UTC+random-runid>` (mkdir only; never `rm -rf`), concatenates `xwrite_comment_open.h` + `xwrite_stdout.frag.c` into runtime-only `xwrite_body.c`, then compiles/runs via `research/libc-specs/phase5/run_vst.py` (shared `~/.cache/bash-spec-pilot/phase3-compiler.lock`). Receipt names include the runid. `run_vst()` reads the JSON receipt (`exit_status`, `timing_exit_status`, `log_sha256`). The script replays twice in one process.

Pinned fragment SHA256 (match `src/tu/FRAGMENTS.json`):

| fragment | sha256 |
|---|---|
| head_bytes.frag.c | `ae9f42de06cf55ca1bfcc8720986b32f8c8d14b8063af8374dece0b886bbc4b7` |
| xwrite_stdout.frag.c | `bb26b78f6b0df6e41c22497b27709f30225627f42326fa80fd85625ae8a5262c` |
| wc_lines.frag.c | `7d22d9fdfd6f97e3f149088c597840afc90f7912eba038fdf5941b94978c26fd` |

## Replay-8 (two collision-free runids)

Container `phase5-vst`. Runids: `20260908T061038Z-3d6a35a6` and `20260908T061040Z-c1a83a0d`. Same outcomes both times:

- `gcc -O0 -std=c11 -Wall -o harness harness.c` → exit **0**
- `./harness` → exit **0**; `SUMMARY passed=100 failed=0`; seed `20260907`, 40 random trials (80 of 100 checks)
- `gcc ... -o xwrite_harness xwrite_main.c` → exit **0**
- `./xwrite_harness ok` → exit **0**, stdout exactly `hello\n`
- `./xwrite_harness zero` → exit **0**, empty stdout
- `./xwrite_harness full` → exit **1** and `timing_exit_status` **1**; log `XWRITE_ERROR status=1 errnum=28 calls=1` (ENOSPC)

Fail-closed: missing receipt and mismatched-command receipt rejected without extra C compilation.

Historical `case-replay7-*` and `case-differential7-*` receipts remain.

## Directed cases

**head_bytes** (mock `safe_read`, mock `xwrite_stdout`): zero request, exact 5, EOF before request, 8192 one block, 8193 two reads, short reads, read error, error after partial write.

**wc_lines** (mock `safe_read`, naive `rawmemchr` loop): empty, dense small, no NL, trailing NL sentinel, 16384 all-NL, sparse then second block, dense→sparse, sparse→dense, short reads, SAFE_READ_ERROR, NULL out pointers.

Oracle: prefix length min(req, len); newline count by byte scan. uintmax overflow not exercised.

## Assumptions and missing coverage

- `head_bytes` does **not** execute `xwrite_stdout.frag.c`; capture mock assumes total write unless `g_xwrite_fail`.
- `error` records and exits only if `status != 0`.
- `quoteaf` / `quotef` identity.
- `rawmemchr` is a naive scan.
- `fpurge` mapped to glibc `__fpurge`.
- `xwrite_stdout.frag.c` starts mid-comment; concatenation with `xwrite_comment_open.h` is required. `#include` cannot close a comment across files.
- Buffered `fwrite` to `/dev/full` did not fail (`case-differential7-run-xwrite-full` exit 4). The honest error path needed unbuffered stdout in the driver.
- `xwrite_harness.c` is a leftover include-based driver; replay does not compile it.
- No Coq/VST proof is claimed here.

Negative checks use `assert_receipt`. Historical script hash in RESULTS.json; current hash in `validator_followup`.
