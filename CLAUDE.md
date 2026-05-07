<!--
  Project CLAUDE.md for formal-verification repo.

  Style: caveman per ~/.claude/CLAUDE.md (drop articles, fragments OK,
  exact technical terms preserved). Block-level HTML comments stripped
  from agent context injection but readable by humans via Read tool.

  Maintainer notes (human-only, agent never sees these):
    - Repo URL: local only; no remote yet.
    - Astrogator paper: arxiv 2507.13290 (mirrored at repo root as 2507.13290v2.pdf).
    - SLMFix paper: arxiv 2511.19422 (mirrored at repo root as 2511.19422v1.pdf).
    - Caruca paper: arxiv 2510.14279 (mirrored at literature/caruca_2025_spec_mining.pdf).
    - state_based reference impl: https://github.com/counc009/state_based
    - Aaron's prelim proposal: Prelim_Proposal-2.pdf at repo root.
    - SDK pin source-of-truth: docs/openai/_pin.txt (currently openai==2.35.1).
    - taxonomy.md and for_aaron.md may be authored by parallel subagents;
      reference even if missing at write-time.
    - decisions.md TOC sections (read directly for full text):
        1. Canonical man-page source per utility (Debian trixie groff).
        2. Prompt engineering choices (Schulhoff techniques applied/rejected).
        3. Driver-API verdict (Responses, no temperature/seed).
        4. Other things noticed.
        5. OpenAI SDK mirror (2026-05-07).
-->

# Project

Research repo. Exploratory experiment for Prof. Vikram Adve group at UIUC. Extends Astrogator (formal verification of LLM-generated code, originally Ansible) to Bash. Owner: Aaron Councilman (PhD). Doer: Darsh (undergrad). Central question: how use unreliable LLMs to produce reliable specs of Bash utilities from man pages? Approach: generate Rust impl + Bash test suite from frozen Linux man page, differential-test against real GNU utility, catalog failure modes. Rust = proxy for not-yet-existent Bash spec language. Failure taxonomy = actual research output, not numbers.

# Pipeline shape

- `scripts/freeze_manpage.sh <util>` -> Debian trixie groff fetch -> `mandoc -Tutf8 | col -bx` -> `utils/<util>/manpage.txt` + `manpage.<section>` (raw groff) + `_source.json` (provenance: URL, pkg version, sha256). Supports `cp | mv | find | sudo`.
- `scripts/driver.py --util <u> --prompt {impl,tests} --round N [--session <sid>]` -> renders prompt template against frozen manpage -> OpenAI Responses API with strict JSON schema -> writes `runs/<u>/<sid>/round_NN/{impl/, tests/, _logs/}`. Round 1 mints fresh session. Round >=2 reuses latest session unless `--session` given. Round >=2 appends "Previous attempt feedback" block (top-N failing tests + Rust build errors + optional `_observations.md`).
- `scripts/run_tests.py --util <u> --session <sid> --round N --target {real,real-gnu,rust} [--in-docker]` -> runs `tests/*.sh` with `$UTIL` env var -> writes `results_<target>.jsonl`. `real-gnu` always batches inside trixie container (canonical oracle).
- `scripts/eval_round.sh <u> <sid> <round>` -> end-to-end eval orchestrator: real-gnu pass + rust pass + flag coverage + line coverage + summary line.
- `scripts/coverage_flags.py` -> flag-coverage metric (manpage-documented flags vs flags exercised by tests).
- `scripts/coverage_rust.sh` -> branch/line coverage on Rust impl via `cargo tarpaulin`.
- `scripts/sync_openai_docs.sh` -> regenerate `docs/openai/` mirror from installed SDK.

# Routing — when read what

- OpenAI SDK question (parameter exists? error class? reasoning effort?) -> `docs/openai/<file>.md`. NEVER WebFetch platform.openai.com. NEVER paraphrase from memory. Mirror is ground truth at pin in `docs/openai/_pin.txt`.
- Decision history / why-we-chose-X -> `decisions.md`. Has TOC at top. Sections: man-page source, prompt engineering, driver-API verdict, SDK mirror.
- Prior work / prior art / what's been tried -> `literature/_synthesis.md`. Read order: Caruca -> Endres -> Tambon -> Westenfelder.
- Failure-mode catalog (Tambon-derived schema) -> `taxonomy.md`.
- Aaron-meeting deliverable / current planned next steps -> `for_aaron.md`.
- Setup / onboarding / stack rationale -> `SETUP.md` (note: parts superseded by `decisions.md` Section 3 — temperature/seed claims wrong).
- Repo overview / why-project-exists / data-collection priorities -> `README.md`.

# Conventions

- Model: GPT-5.5 reasoning model (`gpt-5.5-2026-04-23` snapshot). NO `temperature`. NO `seed`. NO `top_p`. NO `system_fingerprint` access (Responses API doesn't return it).
- Reproducibility = dated snapshot + content-hashed prompt + content-hashed manpage + content-hashed feedback section + logged `response_id`. Driver writes all four sha256s into `_logs/log.jsonl` per call.
- Folder layout: `runs/<util>/<session>/round_NN/`. Session = ISO 8601 UTC timestamp `YYYY-MM-DDTHH-MM-SSZ`. Round = iteration index within session, zero-padded 2 digits.
- Tests invoke utility via `$UTIL` env var. NEVER literal command name. Always quoted `"$UTIL"`.
- Tests carry per-test `expected_to_fail: bool` field for documented error cases. Test body still exits 0 iff utility errored exactly as documented. Capture exit via `set +e; "$UTIL" ...; status=$?; set -e`.
- Test filenames: `NNN_short_description.sh`, 3-digit zero-padded sequence.
- macOS BSD `cp` != GNU `cp`. `--target real-gnu` (Docker trixie) is the only behavioral oracle. `--target real` was removed 2026-05-07 (see `decisions.md` § 4.4) — host BSD cp on macOS is not the experiment's truth source.
- Manpage source = Debian trixie pre-rendered groff. Pinned package versions in `freeze_manpage.sh` per util.
- Logging = plain JSONL + git-versioned prompts + per-run dirs. NO MLflow / W&B / Langfuse / LangSmith.

# Don't

- Don't WebFetch OpenAI docs. Mirror in `docs/openai/`. Refresh via `scripts/sync_openai_docs.sh`.
- Don't add `temperature=0` or `seed=42` to driver. Reasoning model rejects both. SDK 2.35.1 `Responses.create` signature doesn't accept `seed` — TypeError before HTTP call.
- Don't iterate in round 1. Round 1 = baseline (no feedback section). Round 2+ = iteration with structured feedback from round N-1.
- Don't run docker as `root` for sudo tests. `sudo` needs non-root user to be meaningful.
- Don't paraphrase Caruca / Tambon / Astrogator / SLMFix from memory. Read PDFs in `literature/` (or repo root for Astrogator/SLMFix/Prelim).
- Don't run `man <util>` on macOS dev box and freeze BSD output. Wrong project target. Use `freeze_manpage.sh`.
- Don't add `jsonschema` package. Server-side strict JSON schema covers structural correctness; driver does shape-level required-key check.
- Don't add `anthropic` / `langchain` / `litellm`. Single-provider single-model experiment.
- Don't trust `SETUP.md` Sections 5-6 verbatim — `temperature=0`, `seed=42`, `system_fingerprint` claims superseded by `decisions.md` Sections 3 + 5.

# Cost / budget

Order-of-magnitude only. cp round-1 ~$0.36 for ~27K total tokens. Multi-util multi-round full sweep ~$5-15. Pricing: $5/1M input, $30/1M output, $0.50/1M cached input. `gpt-5.5-pro` exists at $30/$180 per 1M — skip unless base GPT-5.5 fails badly on `find` or `sudo`.

# Status / next

See `for_aaron.md` for current planned next steps + Aaron-meeting deliverable. `runs/cp/legacy_pre_session/round_01/` exists from pre-session driver run; new sessions use ISO timestamp ids.
