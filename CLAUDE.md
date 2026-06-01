<!--
  Project CLAUDE.md for formal-verification repo.

  Style: caveman per ~/.claude/CLAUDE.md (drop articles, fragments OK,
  exact technical terms preserved). Block-level HTML comments stripped
  from agent context injection but readable by humans via Read tool.

  Maintainer notes (human-only, agent never sees these):
    - Repo URL: https://github.com/drPod/bash-spec-pilot (public, first push 2026-05-07).
    - Astrogator paper: arxiv 2507.13290 (mirrored at literature/councilman_2025_astrogator.pdf).
    - SLMFix paper: EMNLP 2026 submission, anonymized (literature/slmfix_2026_emnlp.pdf;
      arXiv 2511.19422v1 superseded and removed 2026-05-30).
    - Caruca paper: arxiv 2510.14279 (mirrored at literature/caruca_2025_spec_mining.pdf).
    - state_based reference impl: https://github.com/counc009/state_based
    - Aaron's prelim proposal: literature/councilman_2025_prelim_proposal.pdf.
    - SDK pin source-of-truth: docs/openai/_pin.txt (currently openai==2.35.1).
    - docs/research/taxonomy.md may be authored by parallel subagent;
      reference even if missing at write-time.
    - docs/research/decisions.md TOC sections (read directly for full text):
        1. Canonical man-page source per utility (Debian trixie groff).
        2. Prompt engineering choices (Schulhoff techniques applied/rejected).
        3. Driver-API verdict (Responses, no temperature/seed).
        4. Other things noticed.
        5. OpenAI SDK mirror (2026-05-07).
-->

# Project

Research repo. Exploratory experiment for Prof. Vikram Adve group at UIUC. Extends Astrogator (formal verification of LLM-generated code, originally Ansible) to Bash. Owner: Aaron Councilman (PhD). Doer: Darsh (undergrad). Central question: how use unreliable LLMs to produce reliable specs of Bash utilities from man pages? Approach: generate Rust impl + Bash test suite from frozen Linux man page, differential-test against real GNU utility, catalog failure modes. Rust = proxy for not-yet-existent Bash spec language. Failure taxonomy = actual research output, not numbers.

# Pipeline shape

- `scripts/freeze/freeze_manpage.sh <util>` -> Debian trixie groff fetch -> `mandoc -Tutf8 | col -bx` -> `utils/<util>/manpage.txt` + `manpage.<section>` (raw groff) + `_source.json` (provenance: URL, pkg version, sha256). Supports `cp | mv | find | sudo`.
- `scripts/pipeline/driver.py --util <u> --prompt {impl,tests,adversarial-cold,adversarial-posthoc} --round N [--session <sid>]` -> renders prompt template against frozen manpage -> OpenAI Responses API with strict JSON schema -> writes `runs/<u>/<sid>/round_NN/{impl/, tests/, _logs/}`. Round 1 mints fresh session. Round >=2 reuses latest session unless `--session` given. Round >=2 appends "Previous attempt feedback" block (top-N failing tests + Rust build errors + optional `_observations.md`). Adversarial modes accept `--slice {errors,flags,environment,examples}` (cold) or `--baseline-session/--baseline-round/--baseline-prompt` (posthoc); feedback section suppressed in adversarial round 1.
- `scripts/pipeline/run_tests.py --util <u> --session <sid> --round N --target {real-gnu,rust} [--in-docker]` -> runs `tests/*.sh` with `$UTIL` env var -> writes `results_<target>.jsonl`. `real-gnu` always batches inside trixie container (canonical oracle).
- `scripts/eval/eval_round.sh <u> <sid> <round>` -> baseline eval orchestrator: real-gnu pass + rust pass + flag coverage + line coverage + summary line.
- `scripts/eval/eval_adversarial.sh <u> <sid> <round>` -> wave-4 eval orchestrator: static pre-filter + real-gnu + rust + 4-bucket classify + mut@k/DEPC summary.
- `scripts/eval/static_filter.sh <u> <sid> <round>` -> `bash -n` + `shellcheck -S error` pre-filter, writes `static_filter.json` (kept/dropped). Dropped tests excluded from mut@k denominator (SLMFix-style).
- `scripts/eval/classify_divergence.py <u> <sid> <round>` -> 4-bucket classifier (baseline/divergence/shared_bug/hallucinated_spec), emits `classification.json` + `divergences.jsonl` with mut@k, DEPC, effective-test rate.
- `scripts/eval/run_metamorphic.sh <u> [--as-user]` -> runs hand-written `tests/properties/<u>/*.sh` against trixie real-gnu (sudo uses `--as-user` for non-root tester).
- `scripts/eval/minimize_failure.py <u> <sid> <round> <test_name>` -> ReduceFix-style LLM shrinker; reads a `divergences.jsonl` row, emits minimized invocation under `minimized/`.
- `scripts/eval/coverage_flags.py` -> flag-coverage metric (manpage-documented flags vs flags exercised by tests).
- `scripts/eval/coverage_rust.sh` -> branch/line coverage on Rust impl via `cargo tarpaulin`.
- `scripts/eval/positivity.py` -> positive vs negative test breakdown per round.
- `scripts/dev/sync_openai_docs.sh` -> regenerate `docs/openai/` mirror from installed SDK.
- `scripts/dev/init_observations.sh <util> <session> <round>` -> emit `_observations.md` skeleton with pre-filled numbers.
- `scripts/dev/format_readme.sh` -> hard-wrap `README.md` prose at 100 cols.

# Routing — when read what

- OpenAI SDK question (parameter exists? error class? reasoning effort?) -> `docs/openai/<file>.md`. NEVER WebFetch platform.openai.com. NEVER paraphrase from memory. Mirror is ground truth at pin in `docs/openai/_pin.txt`.
- Decision history / why-we-chose-X -> `docs/research/decisions.md`. Has TOC at top. Sections: man-page source, prompt engineering, driver-API verdict, SDK mirror, wave-4 cold-adversarial pilot (§ 10).
- Prior work / prior art / what's been tried -> `literature/_synthesis.md`. Read order: Caruca -> Endres -> Tambon -> Westenfelder. Wave-4-specific prior art -> `docs/research/adversarial_prior_art.md` (homogenization trap, self-collusion, ACH/CoverUp/Code-A1).
- Failure-mode catalog (Tambon-derived schema) -> `docs/research/taxonomy.md`.
- Setup / onboarding / stack rationale -> `docs/research/setup.md`.
- Repo overview / why-project-exists / data-collection priorities -> `README.md`.
- Wave-4 adversarial prompt templates -> `prompts/adversarial/{cold_section,posthoc}.md` + `prompts/adversarial/README.md` (slice vocabulary + schema).
- Wave-4 metamorphic floor (hand-written non-LLM invariants per util) -> `tests/properties/<util>/*.sh`.

# Conventions

- Model: GPT-5.5 reasoning model (`gpt-5.5-2026-04-23` snapshot). NO `temperature`. NO `seed`. NO `top_p`. NO `system_fingerprint` access (Responses API doesn't return it).
- Reproducibility = dated snapshot + content-hashed prompt + content-hashed manpage + content-hashed feedback section + logged `response_id`. Driver writes all four sha256s into `_logs/log.jsonl` per call.
- Folder layout: `runs/<util>/<session>/round_NN/`. Session = ISO 8601 UTC timestamp `YYYY-MM-DDTHH-MM-SSZ`. Round = iteration index within session, zero-padded 2 digits.
- Tests invoke utility via `$UTIL` env var. NEVER literal command name. Always quoted `"$UTIL"`.
- Tests carry per-test `expected_to_fail: bool` field for documented error cases. Test body still exits 0 iff utility errored exactly as documented. Capture exit via `set +e; "$UTIL" ...; status=$?; set -e`.
- Test filenames: `NNN_short_description.sh`, 3-digit zero-padded sequence.
- macOS BSD `cp` != GNU `cp`. `--target real-gnu` (Docker trixie) is the only behavioral oracle. `--target real` was removed 2026-05-07 (see `docs/research/decisions.md` § 4.4) — host BSD cp on macOS is not the experiment's truth source.
- Manpage source = Debian trixie pre-rendered groff. Pinned package versions in `scripts/freeze/freeze_manpage.sh` per util.
- Logging = plain JSONL + git-versioned prompts + per-run dirs. NO MLflow / W&B / Langfuse / LangSmith.

# Don't

- Don't WebFetch OpenAI docs. Mirror in `docs/openai/`. Refresh via `scripts/dev/sync_openai_docs.sh`.
- Don't add `temperature=0` or `seed=42` to driver. Reasoning model rejects both. SDK 2.35.1 `Responses.create` signature doesn't accept `seed` — TypeError before HTTP call.
- Don't iterate in round 1. Round 1 = baseline (no feedback section). Round 2+ = iteration with structured feedback from round N-1.
- Don't run docker as `root` for sudo tests. `sudo` needs non-root user to be meaningful.
- Don't paraphrase Caruca / Tambon / Astrogator / SLMFix from memory. Read PDFs in `literature/` (or repo root for Astrogator/SLMFix/Prelim).
- Don't run `man <util>` on macOS dev box and freeze BSD output. Wrong project target. Use `scripts/freeze/freeze_manpage.sh`.
- Don't add `jsonschema` package. Server-side strict JSON schema covers structural correctness; driver does shape-level required-key check.
- Don't add `anthropic` / `langchain` / `litellm`. Single-provider single-model experiment.

# Cost / budget

Order-of-magnitude only. cp round-1 ~$0.36 for ~27K total tokens. Multi-util multi-round full sweep ~$5-15. Pricing: $5/1M input, $30/1M output, $0.50/1M cached input. `gpt-5.5-pro` exists at $30/$180 per 1M — skip unless base GPT-5.5 fails badly on `find` or `sudo`.

# Status / next

`runs/cp/legacy_pre_session/round_00/` exists as the pre-experiment baseline (round 0 — BSD-on-macOS oracle, contaminated); new sessions use ISO timestamp ids.
