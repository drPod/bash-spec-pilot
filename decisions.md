# Decisions log

Append-only record of design choices for the man-page → LLM → Rust impl + Bash test-suite pipeline. Each section cites the primary source consulted at decision time. Reversals are kept inline with a "Decision reversed YYYY-MM-DD because <reason>" note rather than deleted, so the trail of *why we no longer believe X* is auditable.

Originally written by three different subagents over 2026-05-06 / 2026-05-07. Restructured 2026-05-07 — sections regrouped topically, duplicates merged, and contradictions reconciled (most consequential: `seed` / `system_fingerprint` were initially recommended as the determinism story, then dropped after a direct SDK audit; both views are preserved below with the reversal called out).

## Table of contents

- [1. Source choice — canonical man pages](#1-source-choice--canonical-man-pages)
- [2. Prompt engineering choices](#2-prompt-engineering-choices)
- [3. Driver / SDK / Responses-API surface](#3-driver--sdk--responses-api-surface)
- [4. Iteration, Docker oracle, coverage](#4-iteration-docker-oracle-coverage)
- [5. Taxonomy + Aaron-note artifacts](#5-taxonomy--aaron-note-artifacts)
- [6. Other notes from earlier audits](#6-other-notes-from-earlier-audits)
- [7. How to update this file](#7-how-to-update-this-file)
- [8. Empirical reproducibility (2026-05-07)](#8-empirical-reproducibility-2026-05-07)
- [9. Methodology debts surfaced by wave 2](#9-methodology-debts-surfaced-by-wave-2)

---

## 1. Source choice — canonical man pages
<a id="1-source-choice--canonical-man-pages"></a>

The previous version of `scripts/freeze_manpage.sh` ran `man <util>` on the undergrad's macOS dev box and froze the BSD output. That is wrong: this project targets Linux/GNU userland (the project extends Astrogator to Bash; the verifier consumes Linux semantics). BSD `cp(1)` and GNU `cp(1)` document different option sets — using BSD man pages on macOS would silently train the LLM against the wrong source.

**Choice: pre-rendered groff from `manpages.debian.org`, pinned to Debian 13 ("trixie"), the current Debian stable as of 2025-08-09.** Each utility records `_source.json` with the URL, Debian package version, fetch timestamp, and sha256 of both the raw groff and the rendered text.

| util  | package      | section | URL                                                           | pkg version              |
|-------|--------------|---------|---------------------------------------------------------------|--------------------------|
| cp    | coreutils    | 1       | https://manpages.debian.org/trixie/coreutils/cp.1.en.gz       | 9.7-3                    |
| mv    | coreutils    | 1       | https://manpages.debian.org/trixie/coreutils/mv.1.en.gz       | 9.7-3                    |
| find  | findutils    | 1       | https://manpages.debian.org/trixie/findutils/find.1.en.gz     | 4.10.0-3                 |
| sudo  | sudo         | 8       | https://manpages.debian.org/trixie/sudo/sudo.8.en.gz          | 1.9.16p2-3+deb13u1       |

Rendered with `mandoc -Tutf8 | col -bx`. `mandoc` ships in macOS base at `/usr/bin/mandoc`, so no Homebrew install is required on the dev box. On a Linux host without `mandoc`, the script falls back to `groff -man -Tutf8`.

### Why not other sources

- **GNU coreutils savannah cgit** ships only `man/cp.x` (a help2man preamble); the actual `cp.1` is generated at build time. Reproducing this requires building coreutils, which is fragile on macOS.
- **GNU findutils savannah** does ship `find/find.1` directly. Adopting it for `find` while keeping `cp`/`mv` on Debian would split the fetch/render pipeline. We routed all four through Debian for consistency.
- **sudo.ws upstream** ships `*.in` templates that need configure-time substitution. Same consistency argument.
- **Linux man-pages project (kernel.org)** focuses on syscalls/library pages, not userspace utility flags.
- **`brew install coreutils`** would mix Homebrew packaging conventions with upstream content and is not deterministic across machines (varies with Homebrew's bottle/build-from-source state). Also outside the research-reproducibility envelope: a re-run six months later would hit a different Homebrew bottle.

Debian's pre-rendered groff is the best balance of (versioned, stable URL, deterministic, upstream-faithful, plain text). Re-running the freeze script six months from now produces byte-identical output as long as Debian trixie stays at the pinned package versions; if it rotates, that's a visible Debian event we can re-pin against.

---

## 2. Prompt engineering choices
<a id="2-prompt-engineering-choices"></a>

Reference: Schulhoff et al., *The Prompt Report* (arXiv 2406.06608). Indexed locally in delphi as `paper_id 2010f4aa-6681-48bf-8d0a-65f806cc402a`.

### Applied techniques (with evidence in the survey)

- **Role + Task framing** (Sec. 2.2.1.3, "Role Prompting"). Survey reports role prompting "may improve accuracy on benchmarks" and shapes open-ended outputs. Used to anchor on Linux/GNU userland and on differential-testing intent rather than generic "you are an AI assistant".
- **Output-format constraint via JSON schema** (Sec. 2.2.5; Schulhoff cites Tam et al. 2024 to push back on the claim that structuring outputs hurts performance and notes that "structuring outputs may actually improve performance"). Both prompts now demand a JSON object conforming to a published schema; the driver enforces this server-side via `text.format = {type:"json_schema", strict:true}`.
- **Decomposition (Plan-and-Solve)** (Sec. 2.2.2, Wang et al. 2023f). Prompts ask the LLM to read the man page first and identify documented flags before producing the artifact — lets the model's internal reasoning happen as a recognizable phase even when the visible output is just the schema-conformant JSON.
- **Negative constraints** (Sec. 2.2.6 on instruction following). Both prompts list out-of-scope features (SELinux, locale, ACLs, xattrs, sparse files, `--reflink=`, signals, network) up front. Reduces hallucination of irrelevant flags.

### Deliberately rejected (folklore-or-no-evidence)

- **"Think step by step" / "let's take a deep breath" CoT triggers.** Schulhoff (Sec. 2.2.2) reports CoT triggers help on multi-step reasoning tasks at moderate temperature. We're on a structured-extraction task with a model that allocates internal reasoning automatically. Adding the trigger duplicates that and bloats the prompt with no measured benefit.
- **Few-shot exemplars.** We have only four utilities; a worked example for `cp` would bias the other three toward the example's style. Schulhoff (Sec. 2.2.1.1, Exemplar Selection) emphasizes that example selection is itself a sensitive design dimension. Cleaner to omit examples than pick a biased one.
- **Persona-stacking** ("you are a senior Rust engineer who…"). No survey-reported evidence it improves code-gen at zero-shot. Folklore.

### Prompt-template provenance (added 2026-05-07)

Both `prompts/impl.md` and `prompts/tests.md` carry a maintainer-note HTML comment block at the top with technique citations and a content-hash versioning note. The driver hashes the rendered template per round and writes `prompt_template_sha256` to `_logs/log.jsonl`, so a future change to either prompt is detectable from the run record alone.

---

## 3. Driver / SDK / Responses-API surface
<a id="3-driver--sdk--responses-api-surface"></a>

This section consolidates two earlier audit passes that arrived at partly-incompatible conclusions about determinism. Both are kept here so the reasoning trail survives.

### 3.1 First audit pass (2026-05-06) — Chat → Responses migration

The previous driver used `client.chat.completions.create` with `temperature=0`, `max_completion_tokens`, and regex-on-markdown extraction. **All three of those were wrong on GPT-5.5.** Driver rewritten.

Findings at that time:

- **Temperature: NOT supported on GPT-5.5.** The OpenAI API responds with the validation error `Unsupported parameter: 'temperature' is not supported with this model.` GPT-5.5 is a reasoning model; per the OpenAI Developer Community thread on the GPT-5 family, only the floating `gpt-5-chat-latest` snapshot honors temperature.
  Source: [OpenAI Developer Community: "Temperature in GPT-5 models"](https://community.openai.com/t/temperature-in-gpt-5-models/1337133).
- **API: Responses, not Chat Completions.** OpenAI's *Using GPT-5.5* guide states "GPT-5.5 works best in the Responses API". Both endpoints exist on the model, but Responses is the recommended endpoint for the GPT-5 family.
  Source: [Using GPT-5.5](https://developers.openai.com/api/docs/guides/latest-model).
- **Token-budget parameter: `max_output_tokens` (Responses), not `max_completion_tokens` (Chat Completions).**
  Source: [Reasoning models](https://developers.openai.com/api/docs/guides/reasoning).
- **Structured outputs via JSON schema.** Responses API uses `text.format = {type:"json_schema", name, schema, strict}`, not Chat Completions' `response_format`.
  Source: [Structured model outputs](https://developers.openai.com/api/docs/guides/structured-outputs).
- **Seed + system_fingerprint, claimed at the time** to be supported on Responses + GPT-5 family for best-effort determinism. **This claim was wrong — see § 3.3 below for the reversal.**

### 3.2 Driver changes (carried forward, still correct)

1. Switched to `client.responses.create(...)` with `input=` (not `messages=`).
2. Renamed `max_completion_tokens` → `max_output_tokens`.
3. Added `text.format` with strict JSON schemas matching `prompts/impl.md` and `prompts/tests.md`. Server-side enforcement means malformed responses raise loudly instead of silently writing garbage through regex extraction.
4. Defense-in-depth JSON validation in the driver: even with server-side schema, the driver re-validates required keys and fails loudly via `ERROR: …` if anything is missing. No silent fallback.
5. **Content-hash log entries.** Each run logs `prompt_template_sha256` and `manpage_sha256` to `log.jsonl`, so a future drift in either input is detectable from the run record alone.
6. Optional `OPENAI_REASONING_EFFORT` env var (`minimal | low | medium | high`) passed through to `reasoning.effort`. Default left unset (model picks).
7. **Removed `temperature` entirely.** Rejected by the model.

### 3.3 Second audit pass (2026-05-07) — direct SDK source mirror

Triggered by a runtime `TypeError: Responses.create() got an unexpected keyword argument 'seed'` on the freshly-migrated driver. The first audit pass had relied on the *Advanced usage* doc page's claim that `seed` was supported on the GPT-5 family; the SDK signature contradicts that. The installed `openai-python` source was mirrored to `docs/openai/` to make the SDK the source of truth from this point onward.

**Decisions reversed 2026-05-07 (replacing § 3.1's determinism story; supersedes § 3.2 item "Rely on `seed` + `system_fingerprint` + dated snapshot for reproducibility"):**

- **`seed` is not on `responses.create` at all.** *Decision reversed 2026-05-07 because the SDK source contradicts the doc page.* The SDK 2.35.1 signature literally does not list it, which is why the call raised `TypeError` at the SDK layer (before any HTTP call). It was a Chat Completions parameter that never migrated to Responses.
  Reason for trusting the reversal: SDK source `.venv/lib/python3.12/site-packages/openai/resources/responses/responses.py` is more authoritative than a vendor doc page. Doc pages can lag the SDK.
- **`system_fingerprint` is not returned by the Responses API.** *Decision reversed 2026-05-07 because direct inspection of `openai/types/responses/` shows no such field.* The previous driver logged `raw.get("system_fingerprint")` which always evaluated to `None`. The determinism-by-fingerprint claim was wrong.
- **`top_p` is also rejected by gpt-5 reasoning models** (same family of error as `temperature`). The driver doesn't pass it; SETUP.md no longer suggests it as a fallback.

The replacement determinism story is:

> dated model snapshot (`OPENAI_MODEL=gpt-5.5-2026-04-23`)
> · `prompt_template_sha256` (rendered prompt)
> · `manpage_sha256` (input)
> · `feedback_sha256` (iteration-feedback block, see § 4)
> · `response.id` from the Responses payload (server-side recall via `previous_response_id`)

All five are written to `_logs/log.jsonl` per round.

### 3.4 SDK mirror — pin

- SDK version: **2.35.1** (from `uv run python -c "import openai; print(openai.__version__)"`).
- GitHub tag: `v2.35.1`, commit `5e8f09c2c8f65d2e93722270963f4a19a760736f`.
- Source of truth: installed package files at `.venv/lib/python3.12/site-packages/openai/`. Every claim in `docs/openai/*.md` cites the specific `.py` it was read from.
- Refresh script: `scripts/sync_openai_docs.sh` (idempotent; rewrites `_pin.txt` and `_responses_create_signature.txt`).

### 3.5 Top surprises in the actual SDK signature vs. what the driver assumed

1. **`seed` and `system_fingerprint`** — see § 3.3.
2. **`max_output_tokens` is a hard cap that includes reasoning tokens.** The default of 16000 can be eaten almost entirely by reasoning on `effort=high`, leaving no budget for the actual JSON output, with `status="incomplete"` and `incomplete_details.reason="max_output_tokens"`. When tuning effort upward, raise this in tandem. See `docs/openai/reasoning.md`.
3. **`responses.parse(text_format=PydanticModel)` exists** as a first-class alternative to dict-based `text.format` + manual `json.loads`. We use the dict path on purpose to keep schemas inline.

### 3.6 Other driver fixes done in pass 2

- **`seed` log entry** in `log.jsonl`: was recording `"seed": int(os.environ.get("OPENAI_SEED", "42"))` even though the value was never sent to the API. Fixed (entry removed).
- **`system_fingerprint` log entry**: always `None`. Fixed (entry removed).
- **No timeout / retries / error handling**: any `RateLimitError`, `APITimeoutError`, etc. crashed the driver after the prompt was saved but before any error context hit disk. Fixed — client now constructed with `timeout=300, max_retries=3`, and a per-error-type `try/except` block writes `_logs/<prompt>_error.json` with request + body + status before re-raising. See `docs/openai/errors.md`.

The `text.format` shape, `reasoning.effort` shape, `max_output_tokens` name, and `input` (string) usage are all correct as shipped.

### 3.7 Indexing the SDK in delphi — known failure

`delphi index_repository` on `https://github.com/openai/openai-python` fails because the SDK source contains the literal string `<|endoftext|>` (in tokenizer-related code) and OpenAI's embeddings endpoint rejects it as a disallowed special token. Filed upstream as [synthetic-sciences/delphi#15](https://github.com/synthetic-sciences/delphi/issues/15) (item 3); fix proposed in [PR #18](https://github.com/synthetic-sciences/delphi/pull/18) (sanitize the eight tiktoken literals at the OpenAI provider boundary). Until that merges and we redeploy, the local mirror in `docs/openai/` substitutes for cross-repo search on this SDK. The mirror keeps independent value post-fix: version-pinned, offline-capable, no delphi round-trip.

---

## 4. Iteration, Docker oracle, coverage
<a id="4-iteration-docker-oracle-coverage"></a>

(2026-05-07.) Round 1 of `cp` exposed three structural problems: contaminated oracle, no iteration support, no session ids. All were addressed in this pass. Coverage tooling was added end-to-end.

### 4.1 Session-scoped run layout

The original layout was `runs/<util>/round_<NN>/` — flat. A re-run would clobber the previous round, and there was no way to express "two distinct iteration trajectories on the same util."

**New layout:** `runs/<util>/<session_id>/round_<NN>/`, where `session_id` is an ISO 8601 UTC timestamp with colons replaced for filesystem safety (`YYYY-MM-DDTHH-MM-SSZ`). One session = one trajectory. `scripts/driver.py` and `scripts/run_tests.py` both take `--session`. Round 1 with no `--session` mints a fresh timestamp; round ≥ 2 with no `--session` re-uses the latest session for the util.

The pre-rework `runs/cp/round_01/` was moved verbatim to `runs/cp/legacy_pre_session/round_00/` to preserve the historical run without losing it under the new scheme. See `runs/cp/legacy_pre_session/_README.md` for the postmortem on that run.

### 4.2 Iteration feedback (round ≥ 2)

When invoked with `--round N` where N ≥ 2, the driver looks up the previous round's `results_real-gnu.jsonl` (or `results_real.jsonl` as fallback) and Rust build error (if any) and appends a "Previous attempt feedback" section to the prompt. Top-N (currently `MAX_FEEDBACK_FAILURES = 10`) failing tests are formatted with name, exercises, expected vs. actual stderr, and exit code. The build error is truncated to `MAX_BUILD_ERROR_LINES = 50` lines. Constants live in the driver (not CLI flags) so the prompt content is reproducible from the script.

The feedback block is content-hashed *separately* from the base template so `log.jsonl` records both `prompt_template_sha256` (the canonical prompt) and `feedback_sha256` (the round-specific error context). This lets a future analyst tell whether two rounds differed because the *prompt* changed or because the *feedback* changed.

A manual `_observations.md` in the prior round, if present, is appended verbatim to the feedback block. This is the analyst's escape hatch for adding context the automated extraction misses.

### 4.3 Docker GNU oracle (`formal-verification:trixie`)

The legacy round-1 `cp` test results were contaminated because the oracle was BSD `/bin/cp` on macOS, not GNU. 13/30 tests "passed" — the failures were predominantly because BSD `cp(1)` doesn't accept GNU flags like `-t`, `-d`, `-u`, `-b`, `--update=`, `--attributes-only`, `--strip-trailing-slashes`, `--parents`, `--remove-destination`, `--keep-directory-symlink`, `--debug`. These are not LLM hallucinations. The test suite read the GNU man page faithfully; the host oracle was the wrong tool.

**Fix:** `docker/Dockerfile` builds `formal-verification:trixie` from `debian:trixie-20260421-slim` with `coreutils=9.7-3`, `findutils=4.10.0-3`, `sudo=1.9.16p2-3+deb13u1` (matching the freeze-script pins), plus `cargo` + `cargo-tarpaulin`. Built image is **378 MiB**. `docker/build.sh` is idempotent; `docker/run.sh` bind-mounts the repo at `/work` and runs `--rm`.

`scripts/run_tests.py --target real-gnu` routes through `docker/run.sh`, so every per-test result against "real GNU" is deterministic regardless of the dev box's OS. All tests are batched into one `docker run` invocation rather than one container per test, because Docker Desktop on macOS adds ~1–2s of startup per container; at 30 tests that was 30–60s of pure overhead. Batched form completes in ~3s.

#### Tier-A vs Tier-B package pinning (deviation from "pin everything")

The brief said "Pin everything." Strict version pins on `bash`, `mandoc`, `curl`, `python3`, etc. failed: trixie's apt index now ships `bash 5.2.37-2+b8` (not `5.2.37-2`), `mandoc 1.14.6-4` (not `-1+b1`), etc. — point-release security rotations within the same trixie release. Pinning the GNU oracle (`coreutils`, `findutils`, `sudo`) tightly was the goal anyway; it's the userland under test. The non-oracle packages are now pinned only to `debian:trixie-20260421-slim` (the digest), which determines the apt index they install from. Fully tight pinning would require either a snapshotted apt mirror or a periodic rebuild cadence that re-pins the rotated `+bN` suffixes — overkill for this experiment's reproducibility envelope.

### 4.4 `run_tests.py` target matrix

- `--target real-gnu`: GNU userland inside the trixie container. **The canonical oracle.**
- `--target rust`: LLM-generated impl. `--in-docker` builds and runs it inside the container; without it, host-side cargo for fast loops.

When `cargo build` fails the stderr is captured to `runs/<util>/<session>/round_<N>/impl/_logs/build_error.txt` so the next round's iteration prompt can include the verbatim error.

**Decision: removed `--target real` (host BSD on macOS) since the GNU oracle in the trixie container is the only behavioral truth source. Documented 2026-05-07.** The earlier matrix kept `--target real` (host system util on the dev box, BSD `cp` in practice) as a "quick does-this-work-at-all" smoke path. Keeping it had a real cost: every time someone runs the wrong target, the result is a confidently-wrong oracle answer, which is exactly the bug that contaminated the legacy round-1 baseline (see `runs/cp/legacy_pre_session/_README.md`). Linux/GNU is the experiment's stated target; on macOS dev boxes, host BSD cp answers a different question. The legacy run's `results_real.jsonl` is preserved on disk as the BSD-vs-GNU oracle-bug demonstration.

### 4.5 `expected_to_fail` per-test field

Added to `prompts/tests.md` schema and `TESTS_SCHEMA` in `driver.py`. Tests for documented error conditions belong here; the test body still exits 0 iff the utility errored exactly as documented (`set +e; "$UTIL" ...; status=$?; set -e; [[ $status -ne 0 ]]`). `run_tests.py` writes both `expected_to_fail` and `correct` per row in the JSONL so observations can break down failures by category.

Verified end-to-end on two existing legacy tests (`004_no_target_directory_error.sh`, `024_update_none_fail_errors_on_skip.sh`); both score `correct=true` on `real-gnu` because the test bodies already used the capture-and-assert-nonzero pattern.

### 4.6 Coverage measurement

- `scripts/coverage_flags.py` parses `^\s+-[A-Za-z]\b` and `^\s+--[A-Za-z][a-z0-9-]+` from the manpage for the documented set, and the same patterns out of test bodies for the exercised set. Writes `coverage_flags.json` with matched, unmatched, and `extra_used_not_documented` lists for inspection.
- `scripts/coverage_rust.sh` runs `cargo tarpaulin --out Json` inside the trixie container against an auto-generated integration test (`tests/_run_bash_suite.rs`) that loops the bash suite through the instrumented binary. On compile failure, writes `{"compile_failed": true}` and exits 0 (eval_round treats as skipped).
- `scripts/eval_round.sh <util> <session> <round>` runs all four metrics in sequence and emits the one-line summary the brief asked for: `<util> session=<id> round=<N> test_real=<P/T> test_rust=<P/T> flag_cov=<F%> line_cov=<L%>`.

#### Tarpaulin integration harness (deviation note)

Tarpaulin instruments Rust unit / integration tests, not external binaries invoked by external bash scripts. To get coverage of the impl we generate a minimal Rust integration test (`impl/tests/_run_bash_suite.rs`) that iterates the bash suite and exec()s the instrumented binary. This is the least-intrusive shape; the alternative was running tarpaulin once per bash test which would be ~30× slower. Caveat: the integration test is auto-regenerated each coverage run, so the impl directory gains a `tests/` subdir that's not present in the LLM's output.

### 4.7 Observations + per-util summary scaffolding

- `scripts/init_observations.sh` writes the `_observations.md` skeleton per round with metrics pre-filled (parsed from JSONL and JSON files), Tambon-2025 categorization scaffold, and an empty "Open questions for next round" section.
- Per-util `runs/<util>/SUMMARY.md` is the cross-session roll-up. Initial entry populated for `legacy_pre_session`.

### 4.8 Should `runs/cp/legacy_pre_session/round_00/` be replayed in the new structure?

**No, and the legacy data has already paid back its keep.** Two things fell out of running the new infra against the existing tests:

1. The 13/30 BSD pass rate inflated to **28/30 against the GNU oracle** without changing a single test. This validates the oracle hypothesis: ~50% of the original "failures" were the wrong-utility-on-the-host bug, not LLM mistakes. The two genuine failures that survive are not "the LLM hallucinated a flag" — they're misread edge cases at the seam between bash and `cp` (symlink trailing-slash dereferencing in test 018; tty-detection in `-i` for test 022). That is the failure-taxonomy data the experiment exists to collect.
2. The Rust impl's compile error (E0515 lifetime issue at `src/main.rs:159`) is a single, well-defined failure that the iteration-feedback path can surface verbatim to round 2. We don't need to replay round 1 to get there; we need round 2 to start from the round 1 artifacts, which it now does.

The existing `runs/cp/legacy_pre_session/round_00/` should stay as a historical baseline — it's the only artifact we have that demonstrates the BSD-vs-GNU oracle delta, and that delta is itself a methodologically interesting datum. Future runs start a fresh session and iterate from there.

---

## 5. Taxonomy + Aaron-note artifacts
<a id="5-taxonomy--aaron-note-artifacts"></a>

(2026-05-07.) Two artifacts added at the repo root, grounded in actual paper content (read in full, not paraphrased from memory):

- **`taxonomy.md`** — failure schema with two lenses for labeling `_observations.md` entries:
    - Tambon et al. (2025) 10 generic bug patterns (verbatim definitions from §4.1.1 of arXiv 2403.08937).
    - Astrogator-style verifier-result decomposition (false positive / false negative of the differential test, with cause codes) modeled on Sec. 6.3 + 7 of arXiv 2507.13290v2.
- **`for_aaron.md`** — one-page status note for Aaron Councilman covering round-1 numbers, the BSD-vs-GNU oracle confusion that contaminated it, positioning vs. Caruca (Lamprou et al., October 2025; co-author Greenberg), iteration plan, coverage methodology, and five open questions on version pinning, utility ordering, multi-model scope, labeling effort, and observation format.

No `runs/`, `scripts/`, `prompts/`, or `docs/` files were touched in that pass.

---

## 6. Other notes from earlier audits
<a id="6-other-notes-from-earlier-audits"></a>

- **`scripts/run_tests.py`** reads `tests/*.sh` from the round directory and runs them with `$UTIL` set, which is exactly what the schema in `prompts/tests.md` produces. It accepts `--target real-gnu` (Docker, the canonical oracle) and `--target rust` (with optional `--in-docker`). *(Supersedes the earlier audit's "scripts/run_tests.py is unaffected, no changes needed" note — that was true of the schema-rewrite pass but not of the iteration/Docker rebuild. Also supersedes the original `--target real` host-BSD path; see § 4.4.)*
- **`pyproject.toml`** declares only `openai` and `python-dotenv` as runtime deps; the new driver still fits within those. No `jsonschema` package added — the schema check we do is shape-level (required keys), and OpenAI's server-side enforcement covers structural correctness.
- **`README.md` repository layout** originally listed only `manpage.txt`. The 2026-05-07 README rewrite expanded it to cover `manpage.1` (raw groff), `_source.json` (provenance), the `runs/<util>/<session>/round_NN/` layout, `legacy_pre_session/`, `docker/`, and `docs/openai/`. *Supersedes the "did not edit on this pass; flagging" note from the first audit.*
- **`.env.example`** was updated 2026-05-07 to drop `OPENAI_TEMPERATURE` and `OPENAI_SEED`, document the `seed` / `temperature` / `top_p` / `system_fingerprint` situation in comments, and add `OPENAI_REASONING_EFFORT`. *Supersedes the "deliberately left for the team to acknowledge rather than silently flipping a documentation file" note from the first audit — the team has now acknowledged.*
- **Trailing-newline / shebang quirks.** Prompts now require the test body to start with `#!/usr/bin/env bash`. Previous regex extractor would silently drop a missing shebang; new schema validation makes that failure visible.
- **Prompt comment headers.** Both `prompts/impl.md` and `prompts/tests.md` now carry a maintainer-note HTML comment block at the top with technique citations and a content-hash versioning note. Headers are stripped from CLAUDE.md-style injection but preserved on disk for human review. *(See § 2 "Prompt-template provenance" for the canonical version of this note.)*

---

## 7. How to update this file
<a id="7-how-to-update-this-file"></a>

This is an append-then-restructure log, not a silent-overwrite log. Convention:

1. **Append first.** When a new decision is taken, add a new dated subsection at the bottom of the relevant top-level section (or, if it doesn't fit any existing section, add a fresh top-level section + TOC entry). Do not rewrite history in place.
2. **When a previous decision is reversed**, add a *new* subsection that explicitly says `Decision reversed YYYY-MM-DD because <reason>`, and leave the original subsection in place with a `*superseded YYYY-MM-DD by § N.M*` note. The reader needs to be able to reconstruct the trail from the file alone.
3. **Periodically restructure.** When the file gets long enough that two sections clearly overlap, merge them in a single restructuring pass — keep the later/correct version as the body, fold the earlier version's reasoning into a sub-subsection inside the merged section ("First audit pass" / "Second audit pass" pattern in § 3 is the template), and bump the date stamp at the top of the file.
4. **Never truncate.** Reorganize, don't delete. ~400 lines is acceptable for this file; if it grows past that, split the largest top-level section into its own file and link from here.
5. **Cite the primary source.** Every claim about external behavior (SDK signature, model API rejection, doc-page guidance) gets a path or URL inline. Vendor doc pages can drift from the SDK; **SDK source is more authoritative when they disagree** — that lesson is the entire reason § 3 has two passes.

---

## 8. Empirical reproducibility (2026-05-07)
<a id="8-empirical-reproducibility-2026-05-07"></a>

The determinism story documented in § 3.3 — dated model snapshot + content-hashed prompt + content-hashed manpage + `response.id` — is a **mechanism statement**, not a measurement. We had not, until now, actually measured how close two calls with byte-identical inputs land. This section records the first such measurement.

Two distinct sessions, both round 1 of `cp` impl, both invoking `gpt-5.5-2026-04-23` via `client.responses.create(...)`. Iteration-feedback path forcibly disabled by being round 1 in separate sessions; `feedback_sha256` is `null` for both. `prompt_template_sha256` and `manpage_sha256` match byte-for-byte across A and B. Different `response.id` confirms a real round-trip to OpenAI on each call (no client-side caching).

Findings:

- **Output length:** Session A produced a 291-line `src/main.rs`; Session B produced 393 lines. **B is 35% longer than A for the same prompt.**
- **`diff -u A/main.rs B/main.rs`:** 613 lines of unified-diff output, 40,630 bytes of patch text. Surface skeleton shared (single-file binary, custom argv parser, manual tree walker), but the diff is a near-total rewrite at the statement level. `Opts` struct field ordering differs; enum names differ (`BackupMode` vs `BackupControl`); shared-state struct identity and contents differ (`Ctx { link_map, root_dev }` vs `Ctx { opts, seen_links, umask }`); error type and helper-function decomposition differ throughout. **Effectively independent rewrites that happen to read the same man page.**
- **`Cargo.toml` dependency choice:** identical in both runs — `filetime = "0.2"` and `libc = "0.2"`. Neither hit the driver's `clap`-based `CARGO_TOML_FALLBACK`. Dependency *set* is the most reproducible thing in the experiment.
- **Reasoning-token spend differs by 9.3%** (A: 4044 tokens, B: 3667 tokens). Output tokens differ by 5.2% (A: 10440, B: 9896). The model is doing materially different amounts of internal reasoning between calls.
- **Compile correctness flipped.** A passed `cargo check` with rc=0; B failed with `error[E0308]: mismatched types` at `src/main.rs:346:116` — a `.transpose().unwrap_or(...)` pattern returning the wrong shape (`Result<PathBuf, _>` where `Option<PathBuf>` is expected). **Run as a single-call study, this would land "ready to test" on A and "needs feedback round" on B from the same prompt.**

**Verdict: dated-snapshot + content-hash determinism is mechanism, not measurement. N≥3 sampling is required before any single-cell number in this experiment can carry weight.** Two options for the experimental shape going forward:

1. **N-call averaging per round** (e.g. N=3 per util per round). Report median + min/max for test pass rate, flag coverage, and build success. Triples per-round API spend (~$0.30 → ~$0.90 for cp round 1 at observed rates). Still cheap.
2. **Longest-stable-claim filtering.** Run N calls; only treat a finding as "real" when it appears in ≥ ⌈N/2⌉ runs. Defensible for the qualitative failure-taxonomy work since taxonomy items that only appear in one of three runs are not reliably "how the model fails on cp."

Decision deferred to post-meeting. Full report (token costs, prose excerpts, exact line:column of the E0308) lives at `runs/cp/_reproducibility_2026-05-07T11-18-09Z.md`. Each per-utility `_observations.md` should now be read with the N=1 caveat in mind.

---

## 9. Methodology debts surfaced by wave 2
<a id="9-methodology-debts-surfaced-by-wave-2"></a>

Two structural gaps surfaced during wave 2 (round 1 of `mv` / `find` / `sudo`, round 2 of `cp`). Both are recorded here and **explicitly deferred**, not patched, because in each case the gap is itself a finding worth surfacing at the advisor meeting before being plastered over.

### 9.1 `coverage_flags.py` is `find`-blind

`scripts/coverage_flags.py` parses the manpage for `^\s+-[A-Za-z]\b` and `^\s+--[A-Za-z][a-z0-9-]+` — short flags and long flags. It applies the same regex to test bodies for the exercised set. This works for `cp`, `mv`, and `sudo`, whose surfaces are dominated by `-X` / `--xxx` forms. **It does not work for `find`.** Find's actual semantic surface lives in *primaries*: `-name`, `-type`, `-exec`, `-print`, `-files0-from`, `-newer`, `-perm`, `-size`, etc. — tokens that match the `^\s+-[A-Za-z]` pattern syntactically but are not flags in the GNU getopt sense, and most are followed by an argument. The reported `find` flag coverage of **60%** is therefore misleading-low: the 30 generated tests do exercise a wide subset of primaries, but the metric doesn't see them. The `extra_used_not_documented` set further pollutes the read by picking up incidental tokens like `-c`, `-e`, `-p`, `-s`, `-v` from `cp -p`/`mkdir -p` calls in test setup.

**Decision: document the gap, do not fix the script before the advisor meeting.** Two reasons. First, fixing requires per-utility config (which tokens are flags vs. primaries vs. operators), which is real work that belongs in a separate change. Second, the `find` row is more honestly read as "here is the kind of metric debt that emerges when one script tries to cover four utilities with different surface conventions" — that's a methodology observation worth carrying into the conversation rather than papering over. The `for_aaron.md` results table flags `find` coverage with an asterisk; the `_observations.md` calls it out explicitly.

### 9.2 `sudo` Docker container runs as root

`docker/Dockerfile` does not add a non-root test user. All 29 `sudo` tests therefore run as uid=0. Default `/etc/sudoers` grants `root ALL=(ALL:ALL) ALL`, so a substantial fraction of the test suite passes trivially: "refuses without password" tests under `-n` pass because root needs no auth; "refuses to run as user X" tests pass because root is allowed to switch to any user. The 28/29 real-gnu pass rate is therefore an **upper bound on the suite's true informativeness in a more realistic non-root harness.**

**Decision: document, do not patch the Dockerfile before the advisor meeting.** The structural manpage-incompleteness for policy-driven utilities (`sudo(8)` documents argument syntax; `sudoers(5)` documents the policy gating that determines whether each invocation succeeds) is itself a finding. Adding a non-root user with a known-password sudoers.d entry would change the visible pass rate but would not change the underlying observation that **half of `sudo`'s "documented" behavior is gated by a man page the LLM never saw**. That's the candidate failure class — see `taxonomy.md` § 4 ("split-manpage utilities"). Surfacing it cleanly at the meeting matters more than improving the cell number now.

The trade-offs of a non-root harness (sudoers.d/ provisioning, password-cache resets between tests, deciding whether to feed `sudoers(5)` into the LLM prompt) are real engineering work that belongs in a separate change after the meeting frames the question.
