# AGENTS.md

Routing block for downstream agents (Claude Code, Cursor, Aider, plain LLM sessions, anything that reads a project file at startup). Tighter than `CLAUDE.md`; focused on "where to look for X."

## What this repo is

Research experiment investigating whether large language models can extract behaviorally-faithful information from Linux `man` pages. The experiment generates Rust implementations and Bash test suites from frozen man pages, then differential-tests them against the real GNU utility. Part of Prof. Vikram Adve's group at UIUC, extending the Astrogator formal-verification system from Ansible to Bash.

## Where to find docs

- **OpenAI Python SDK behavior** (parameter signatures, error classes, reasoning config, structured outputs) — `docs/openai/`. The mirror is pinned to the installed SDK version (`docs/openai/_pin.txt`). Read this before calling `client.responses.create(...)`. Do not WebFetch platform.openai.com — it lags the SDK.
- **Project conventions and routing** — `CLAUDE.md` at the repo root. Caveman style, agent-facing.
- **Decision log** (why we chose Debian trixie man pages, why we removed `temperature` and `seed`, why we switched from Chat Completions to Responses) — `docs/research/decisions.md`. Has a section TOC.
- **Failure taxonomy** (Tambon-derived schema for cataloguing LLM bugs in generated Bash and Rust) — `docs/research/taxonomy.md`.
- **Literature / prior work synthesis** — `literature/_synthesis.md`. Recommended read order: Caruca, Endres, Tambon, Westenfelder.
- **Setup and onboarding** — `docs/research/setup.md`.
- **Weekly Slack-DM template to Aaron** — `docs/research/slack_dm.md`.

## Where to find code

- **Driver** (renders prompt template + manpage, calls OpenAI Responses API with strict JSON schema, writes round directory) — `scripts/pipeline/driver.py`.
- **Test runner** (executes a round's `tests/*.sh` against the GNU utility inside Docker (`--target real-gnu`, the canonical oracle) or the LLM-generated Rust impl (`--target rust`), and writes `results_<target>.jsonl`) — `scripts/pipeline/run_tests.py`. The `--target real` (host BSD utility) path was removed 2026-05-07; see `docs/research/decisions.md` § 4.4.
- **Manpage freezer** (fetches Debian trixie groff, renders with `mandoc -Tutf8 | col -bx`, writes `utils/<util>/manpage.txt` plus a provenance JSON) — `scripts/freeze/freeze_manpage.sh`.
- **Evaluation orchestrator** (runs real-gnu + rust passes, flag coverage, Rust line coverage, prints a one-line summary) — `scripts/eval/eval_round.sh`.
- **Flag coverage metric** — `scripts/eval/coverage_flags.py`.
- **Rust line / branch coverage via tarpaulin** — `scripts/eval/coverage_rust.sh`.
- **Positive vs negative test breakdown per round** — `scripts/eval/positivity.py`.
- **OpenAI SDK doc-mirror sync** — `scripts/dev/sync_openai_docs.sh`.
- **`_observations.md` skeleton bootstrap** — `scripts/dev/init_observations.sh`.
- **README 100-col rewrap** — `scripts/dev/format_readme.sh`.
- **Prompt templates** — `prompts/baseline/impl.md` (man page → Rust) and `prompts/baseline/tests.md` (man page → Bash test suite). Both carry HTML maintainer-note headers documenting which prompt-engineering techniques (per Schulhoff 2024) are applied and which are deliberately rejected. `prompts/adversarial/` is reserved for the wave-4 adversarial test variant (placeholder only).
- **Docker** (Debian trixie image hosting the canonical GNU oracle and the cargo build environment for `--target rust --in-docker`) — `docker/Dockerfile`, `docker/build.sh`, `docker/run.sh`.

## Where data lives

- **Frozen manpages** — `utils/<util>/manpage.txt` (rendered text the LLM consumes), `utils/<util>/manpage.<section>` (raw groff source), `utils/<util>/_source.json` (URL, Debian package version, SHA-256 of both the groff and the rendered text, fetch timestamp).
- **Run artifacts** — `runs/<util>/<session>/round_NN/`. Session is an ISO 8601 UTC timestamp like `2026-05-07T18-30-00Z`; round is a two-digit zero-padded iteration index within the session. Inside each round directory: `impl/` (Rust crate), `tests/` (Bash scripts plus `_manifest.json`), `_logs/` (raw prompt, raw response, error dumps, `log.jsonl`), `results_<target>.jsonl` (per-test outcomes).

## External resources

- **Astrogator paper** (Councilman et al. 2025, the system this project extends) — `literature/councilman_2025_astrogator.pdf`.
- **SLMFix paper** (Fu, Gupta et al., EMNLP 2026 submission anonymized; RL fine-tuning to fix syntax/type errors in LLM-generated code for low-resource DSLs) — `literature/slmfix_2026_emnlp.pdf`.
- **Aaron's preliminary proposal** (Chapters 4 and 5 are the directly relevant ones — the planned Bash extension and the bootstrapping problem this experiment helps address) — `literature/councilman_2025_prelim_proposal.pdf`.
- **Caruca paper** (Lamprou et al. 2025, the closest prior work — spec extraction from man pages) — `literature/caruca_2025_spec_mining.pdf`.
- **`state_based` reference implementation** (Astrogator's Module Description Language for Ansible modules; the Bash spec language Aaron will design will be analogous) — `https://github.com/counc009/state_based`.

## What NOT to assume

- **No Vercel, no Next.js, no React, no JavaScript.** This is a Python research repository. Anything that auto-suggests web-framework skills based on filename patterns is wrong here.
- **No Anthropic SDK, no LangChain, no LiteLLM.** Single-provider single-model experiment using `openai==2.35.1` against the OpenAI Responses API. Do not add a provider abstraction layer.
- **No `temperature`, no `seed`, no `top_p`, no `system_fingerprint` on the LLM call.** GPT-5.5 is a reasoning model; the API rejects `temperature` and `top_p`, and `seed` and `system_fingerprint` belong to the Chat Completions surface, not the Responses surface this project uses. See `docs/research/decisions.md` Section 3 and Section 5 for the full audit.
- **No fancy logging or experiment-tracking framework.** Logging is plain JSONL files plus git-versioned prompt templates plus per-run directories. MLflow, Weights & Biases, Hydra, LangSmith, Langfuse, Helicone, Phoenix, Promptfoo, and Inspect AI were all explicitly considered and rejected; see `docs/research/setup.md` Section 5 for the rationale.
- **No test framework.** Tests are plain Bash scripts invoked through `scripts/pipeline/run_tests.py` via `subprocess.run(["bash", ...])`. No pytest harness, no Bats, no shUnit.
- **No production-grade reimplementations.** The Rust impls are research artifacts; their job is to give us a measurable handle on whether the LLM understood the man page. Do not refactor them for code quality.
