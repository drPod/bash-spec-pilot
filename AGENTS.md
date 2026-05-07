# AGENTS.md

Routing block for downstream agents (Claude Code, Cursor, Aider, plain LLM sessions, anything that reads a project file at startup). Tighter than `CLAUDE.md`; focused on "where to look for X."

## What this repo is

Research experiment investigating whether large language models can extract behaviorally-faithful information from Linux `man` pages. The experiment generates Rust implementations and Bash test suites from frozen man pages, then differential-tests them against the real GNU utility. Part of Prof. Vikram Adve's group at UIUC, extending the Astrogator formal-verification system from Ansible to Bash.

## Where to find docs

- **OpenAI Python SDK behavior** (parameter signatures, error classes, reasoning config, structured outputs) — `docs/openai/`. The mirror is pinned to the installed SDK version (`docs/openai/_pin.txt`). Read this before calling `client.responses.create(...)`. Do not WebFetch platform.openai.com — it lags the SDK.
- **Project conventions and routing** — `CLAUDE.md` at the repo root. Caveman style, agent-facing.
- **Decision log** (why we chose Debian trixie man pages, why we removed `temperature` and `seed`, why we switched from Chat Completions to Responses) — `decisions.md`. Has a section TOC.
- **Failure taxonomy** (Tambon-derived schema for cataloguing LLM bugs in generated Bash and Rust) — `taxonomy.md`.
- **Literature / prior work synthesis** — `literature/_synthesis.md`. Recommended read order: Caruca, Endres, Tambon, Westenfelder.
- **Setup and onboarding** — `SETUP.md`. Note that parts of Sections 5 and 6 are superseded by `decisions.md` Sections 3 and 5 — the `temperature=0` + `seed=42` reproducibility story documented there does not apply to GPT-5.5 reasoning models.
- **Aaron-meeting deliverable / current planned next steps** — `for_aaron.md`.

## Where to find code

- **Driver** (renders prompt template + manpage, calls OpenAI Responses API with strict JSON schema, writes round directory) — `scripts/driver.py`.
- **Test runner** (executes a round's `tests/*.sh` against the real BSD utility, the GNU utility inside Docker, or the LLM-generated Rust impl, and writes `results_<target>.jsonl`) — `scripts/run_tests.py`.
- **Manpage freezer** (fetches Debian trixie groff, renders with `mandoc -Tutf8 | col -bx`, writes `utils/<util>/manpage.txt` plus a provenance JSON) — `scripts/freeze_manpage.sh`.
- **Evaluation orchestrator** (runs real-gnu + rust passes, flag coverage, Rust line coverage, prints a one-line summary) — `scripts/eval_round.sh`.
- **Flag coverage metric** — `scripts/coverage_flags.py`.
- **Rust line / branch coverage via tarpaulin** — `scripts/coverage_rust.sh`.
- **OpenAI SDK doc-mirror sync** — `scripts/sync_openai_docs.sh`.
- **Prompt templates** — `prompts/impl.md` (man page → Rust) and `prompts/tests.md` (man page → Bash test suite). Both carry HTML maintainer-note headers documenting which prompt-engineering techniques (per Schulhoff 2024) are applied and which are deliberately rejected.
- **Docker** (Debian trixie image hosting the canonical GNU oracle and the cargo build environment for `--target rust --in-docker`) — `docker/Dockerfile`, `docker/build.sh`, `docker/run.sh`.

## Where data lives

- **Frozen manpages** — `utils/<util>/manpage.txt` (rendered text the LLM consumes), `utils/<util>/manpage.<section>` (raw groff source), `utils/<util>/_source.json` (URL, Debian package version, SHA-256 of both the groff and the rendered text, fetch timestamp).
- **Run artifacts** — `runs/<util>/<session>/round_NN/`. Session is an ISO 8601 UTC timestamp like `2026-05-07T18-30-00Z`; round is a two-digit zero-padded iteration index within the session. Inside each round directory: `impl/` (Rust crate), `tests/` (Bash scripts plus `_manifest.json`), `_logs/` (raw prompt, raw response, error dumps, `log.jsonl`), `results_<target>.jsonl` (per-test outcomes).

## External resources

- **Astrogator paper** (Councilman et al. 2025, the system this project extends) — `2507.13290v2.pdf` at the repo root.
- **SLMFix paper** (Fu, Gupta et al. 2025, RL fine-tuning to fix syntax/type errors in LLM-generated code for low-resource DSLs) — `2511.19422v1.pdf` at the repo root.
- **Aaron's preliminary proposal** (Chapters 4 and 5 are the directly relevant ones — the planned Bash extension and the bootstrapping problem this experiment helps address) — `Prelim_Proposal-2.pdf` at the repo root.
- **Caruca paper** (Lamprou et al. 2025, the closest prior work — spec extraction from man pages) — `literature/caruca_2025_spec_mining.pdf`.
- **`state_based` reference implementation** (Astrogator's Module Description Language for Ansible modules; the Bash spec language Aaron will design will be analogous) — `https://github.com/counc009/state_based`.

## What NOT to assume

- **No Vercel, no Next.js, no React, no JavaScript.** This is a Python research repository. Anything that auto-suggests web-framework skills based on filename patterns is wrong here.
- **No Anthropic SDK, no LangChain, no LiteLLM.** Single-provider single-model experiment using `openai==2.35.1` against the OpenAI Responses API. Do not add a provider abstraction layer.
- **No `temperature`, no `seed`, no `top_p`, no `system_fingerprint` on the LLM call.** GPT-5.5 is a reasoning model; the API rejects `temperature` and `top_p`, and `seed` and `system_fingerprint` belong to the Chat Completions surface, not the Responses surface this project uses. See `decisions.md` Section 3 and Section 5 for the full audit.
- **No fancy logging or experiment-tracking framework.** Logging is plain JSONL files plus git-versioned prompt templates plus per-run directories. MLflow, Weights & Biases, Hydra, LangSmith, Langfuse, Helicone, Phoenix, Promptfoo, and Inspect AI were all explicitly considered and rejected; see `SETUP.md` Section 5 for the rationale.
- **No test framework.** Tests are plain Bash scripts invoked through `scripts/run_tests.py` via `subprocess.run(["bash", ...])`. No pytest harness, no Bats, no shUnit.
- **No production-grade reimplementations.** The Rust impls are research artifacts; their job is to give us a measurable handle on whether the LLM understood the man page. Do not refactor them for code quality.
