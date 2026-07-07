# Reproducibility test — GPT-5.5 reasoning model, two identical-prompt calls

**Date:** 2026-05-07
**Model:** `gpt-5.5-2026-04-23`
**Prompt:** `prompts/impl.md` round 1, `cp` utility
**Determinism knobs available:** none. The OpenAI Responses API rejects
`temperature`, `seed`, and `top_p` on the GPT-5.5 reasoning family
(see `decisions.md` § 3). The determinism story is restricted to:
dated model snapshot + content-hashed prompt template + content-hashed
manpage.

This file measures, for the first time in this project, **how close two
calls with identical inputs actually are**.

## Methodology

Two distinct sessions, both round 1 of `cp` impl. Round-1-of-its-own
session never invokes the iteration-feedback path, so both sessions hit
the model with byte-identical prompts (verified via the SHA-256 hashes
in their `log.jsonl` entries).

| | Session A | Session B |
|---|---|---|
| `session_id` | `2026-05-07T11-11-50Z` | `2026-05-07T11-14-47Z` |
| `prompt_template_sha256` | `cf767a85…b466` | `cf767a85…b466` |
| `manpage_sha256` | `6c3d3c19…7cb7` | `6c3d3c19…7cb7` |
| `feedback_sha256` | `null` | `null` |
| `input_tokens` | 2619 | 2619 |
| `cached_input_tokens` | 2304 | 0 |
| Identical prompt? | YES (hashes match) | YES (hashes match) |

## Inputs identical, outputs not

### `response.id` (sanity check)

| | id |
|---|---|
| A | `resp_0ef7e1a25671f3dd0069fc737b5da48193949cf296f5a44131` |
| B | `resp_056cc3e537a3fac80069fc742c104481939b89104f94f530cb` |

Different ids → real round-trip to OpenAI both times, no client-side
caching shortcut. Sanity check passes.

### Token usage

| | output_tokens | reasoning_tokens | duration_s |
|---|---|---|---|
| A | 10440 | 4044 | 167.9 |
| B | 9896 | 3667 | 159.3 |

Reasoning-token spend differs by **377 tokens (9.3%)**; total output by
**544 tokens (5.2%)**. The model is doing materially different amounts
of internal reasoning between calls.

### Line counts of `src/main.rs`

| | wc -l |
|---|---|
| A | 291 |
| B | 393 |

**Session B is 35% longer than Session A** for the same prompt.

### Byte-level diff

`diff -u A/main.rs B/main.rs` produces:

- **613 lines of unified-diff output**
- **40,630 bytes of patch text**

Roughly speaking, the two impls share the surface skeleton — both are
single-file Rust crates that parse argv, walk the source tree, and copy
files — but the diff is a near-total rewrite at the statement level.
Field orderings in the `Opts` struct differ. Enum names differ
(`BackupMode` in A, `BackupControl` in B). The shared-state struct
differs in identity *and* contents (`Ctx { link_map, root_dev }` in A
vs `Ctx { opts, seen_links, umask }` in B). Error type differs (`type
R<T> = Result<T, String>` in A; B uses different conventions
throughout). Helper-function decomposition is different.

These are not stylistic edits — these are independent designs that
happen to read the same man page.

### `Cargo.toml` diff — the dependency choice

`diff -u A/Cargo.toml B/Cargo.toml`:

```diff
 [package]
-name = "util"
+name = "cp_impl"
 version = "0.1.0"
 edition = "2021"

 [[bin]]
 name = "util"
 path = "src/main.rs"

 [dependencies]
 filetime = "0.2"
 libc = "0.2"
```

**Both runs picked the same two crates with the same version
constraints: `filetime = "0.2"` and `libc = "0.2"`.** Notably, neither
chose `clap` (which is the driver's `CARGO_TOML_FALLBACK` default —
both runs returned a non-empty `cargo_toml`, so the fallback never
fired). The only difference is the package name (`util` vs `cp_impl`).
Dependency *choice* is the most reproducible thing in this experiment.

### `deps_rationale` field

Both rationales communicate the same content (filetime for portable
timestamps, libc for chown/lchown/umask, intentional skipping of
SELinux/ACL/xattr/sparse/reflink/special-device handling), but the
prose is independently composed. No shared substring beyond the words
"filetime", "libc", "SELinux", "ACL", "xattr", "sparse", "reflink".

The model agrees on **what to include** and **what to exclude** at
the dependency-rationale level. It does not agree on the prose used
to justify those choices.

## Compile-correctness divergence (the real signal)

| | `cargo check` | rc |
|---|---|---|
| A | passed | 0 |
| B | failed | 101 |

Session B's impl emits `error[E0308]: mismatched types` at
`src/main.rs:346:116`:

```rust
if let (Ok(sc), Ok(dc)) = (
    fs::canonicalize(src),
    dst.parent().map(fs::canonicalize)
                .transpose()
                .unwrap_or(Ok(PathBuf::new()))
) {
```

— a type-mismatch where `Option<PathBuf>` is expected but
`Result<PathBuf, _>` is supplied (the `.transpose().unwrap_or(...)`
call returns the wrong shape). Two errors total, plus an unused-import
warning on `Read`.

**This is the single most consequential finding of the experiment:**
the same prompt produced one impl that compiles cleanly and another
that does not. From the analyst's perspective, these would be scored
in different categories — A would proceed to test execution, B would
get attributed a "Rust build error" entry in the iteration-feedback
loop and need a round 2.

If the experiment were run as a single-call study, **the test pass
rate, flag coverage, and failure taxonomy for `cp` round 1 would be
fundamentally different depending on which call landed.** This is not
a "small noise around a stable mean" situation.

## Token cost (actual)

Pricing assumed at GPT-5.5 reasoning-tier rates as of 2026-05-07
(input $1.25/1M, cached input $0.125/1M, output $10/1M; reasoning
counts as output):

- **A:** (2619 - 2304) × $1.25/M + 2304 × $0.125/M + 10440 × $10/M
       = $0.000394 + $0.000288 + $0.10440 = **~$0.105**
- **B:** 2619 × $1.25/M + 0 × cached + 9896 × $10/M
       = $0.003274 + $0.09896 = **~$0.102**
- **Total spend on the experiment: ~$0.21** (well under the $1.00 cap).

## Verdict

**Single-call GPT-5.5 reasoning output is NOT reproducible enough to
support single-shot research conclusions on this task.**

Two calls with byte-identical prompts produced:

- Different `response.id` (expected and required for a real call).
- Reasoning-token spend differing by 9.3%.
- Output length differing by 35% (291 vs 393 lines).
- A 613-line, 40 KB unified diff between the two `main.rs` files —
  effectively two independent rewrites sharing only architectural
  skeleton and dependency choice.
- **One impl that compiles, one that does not.** This alone would
  flip a round-1 result from "ready to test" to "needs feedback
  round" in the experiment's iteration loop.

The only stable elements were:
- The dependency *set* (`filetime = "0.2"` + `libc = "0.2"`).
- The high-level rationale for what to skip (SELinux, ACL, xattr,
  sparse, reflink, special devices).
- The general architecture (single-file binary, custom argv parser,
  manual tree walker).

These are coarse, top-level choices. Anything finer — struct
layout, error-handling convention, helper decomposition, and
crucially **whether the artifact compiles at all** — is non-stable
across calls.

### Recommendation for the experiment

The experiment as designed (single round-1 call per util, then
iteration) cannot rely on single-shot output as ground truth. Two
options, in increasing order of cost:

1. **N-call averaging per round** (e.g. N = 3 per util per round).
   Report median + min/max for test pass rate, flag coverage, and
   build success. Triples the API spend per round (~$0.30 → ~$0.90
   for cp round 1 at observed rates). Still cheap enough.
2. **Longest-stable-claim filtering.** Run N calls; only treat
   findings as "real" when they appear in ≥ ⌈N/2⌉ runs. This is
   defensible for the qualitative failure-taxonomy work (which is
   the actual product per `README.md`), since taxonomy items that
   only appear in one of three runs are not reliably "how the model
   fails on cp."

Either way, the determinism story in `decisions.md` § 3 — "dated
snapshot + content-hashed prompt + content-hashed manpage" — is true
as a *mechanism statement* but does not deliver run-to-run
artifact-level stability. The single empirical data point this
experiment captures is that **artifact-level reproducibility on
GPT-5.5 reasoning-mode output for a 10k-output-token, 4k-reasoning-
token Rust generation task is poor enough that the failure taxonomy
needs N-call sampling, not single-shot calls.**

## Provenance

- Driver: `scripts/driver.py` (unmodified).
- Manpage input: `utils/cp/manpage.txt`, sha256 `6c3d3c19…7cb7`.
- Prompt template: `prompts/impl.md`, sha256 `cf767a85…b466`.
- Both runs used the default `OPENAI_REASONING_EFFORT` (i.e. unset →
  model default).
- Iteration-feedback path forcibly disabled by being round 1 in
  separate sessions (not via any code change). The feedback-section
  hash is `null` for both, confirming no feedback was injected.
