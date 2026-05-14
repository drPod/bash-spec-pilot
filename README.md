# Bash Utility Specifications via LLMs — Exploratory Experiment

> **Read in this order:**
> 1. **Live dashboard** — `streamlit run dashboard/streamlit_app.py` from the repo root. Always reflects the latest `runs/`.
> 2. **[`for_aaron.md`](for_aaron.md)** — weekly status report, written for Aaron. Headline findings, open questions, planned next steps.
> 3. **[`taxonomy.md`](taxonomy.md)** — failure schema (Tambon-2025 lens + Astrogator-style verifier-result decomposition + the new failure classes we've discovered).
> 4. **[`decisions.md`](decisions.md)** — provenance + design choices (TOC at top; reproducibility caveat in § 8, methodology debts in § 9).
> 5. This README — project framing for anyone landing on the repo cold.

This repository contains an exploratory research experiment investigating whether large language models (LLMs) can extract behaviorally-faithful information from Unix `man` pages. The work is part of a broader effort, led by Prof. Vikram Adve's group at UIUC, to formally verify LLM-generated Bash programs.

## Why this project exists

Software for safety-critical systems — medical devices, aerospace, financial infrastructure, network stacks — needs **formal guarantees** of correctness, not just "we tested it and it seemed fine." LLMs are increasingly writing code that ends up in production, but LLMs hallucinate, miss edge cases, and produce subtly wrong programs. If LLM-generated code is going to be trusted in critical systems, we need to *prove* that the code matches what the user intended.

Proving correctness means comparing the program against a **formal specification** — a precise, machine-checkable description of correct behavior. The lab's prior system, [Astrogator](https://arxiv.org/abs/2507.13290), demonstrates this for Ansible: a user writes a natural-language description, an LLM generates Ansible code, and a verifier checks the code against a formal specification of the user's intent. The verifier accepts 83% of correct programs and rejects 92% of incorrect ones.

The lab now wants to extend the same approach to **Bash**. But Bash is built out of utilities — `cp`, `mv`, `find`, `grep`, `sed`, `awk`, `sudo`, and hundreds more — and to verify Bash programs the verifier needs a formal specification of every utility it might encounter. Writing those specifications by hand does not scale: each one takes person-weeks, and there are hundreds.

The proposed solution is to use LLMs to generate the specifications themselves, using the existing Linux `man` pages as input. Cheap, fast, and the source material is already there.

## Why we care so much about how LLMs fail

There is a catch. If LLMs generate the specifications, the specifications themselves might be wrong. And if a specification is wrong, the entire pipeline is poisoned: you "verify" code against a broken yardstick and end up with false confidence in incorrect software. Aaron Councilman calls this out explicitly as a bootstrapping problem in Chapter 5 of his preliminary proposal.

This makes the central research question of this whole subproject:

> **How do we use unreliable LLMs to produce reliable specifications?**

You cannot answer that question without first understanding *how* LLMs fail when reading man pages. If they fail in narrow, predictable ways — say, always inventing the same kind of nonexistent flag, or always missing the same category of edge case — we can design targeted safeguards and validators around those failure modes. If they fail in chaotic, unpredictable ways across every utility, the approach is in serious trouble and the lab needs a different plan.

So the failure analysis is not a side hustle. **Cataloguing how and where LLMs fail is the science.** Numbers like "test pass rate" and "flag coverage" exist to scaffold that story; the qualitative observations of what the LLM got wrong, and why, are what the rest of the project will be designed around.

## Where this experiment sits

Three things have to exist before the lab can ship spec-generation for Bash:

1. **A specification language for Bash utilities.** Aaron will design this — it doesn't exist yet. It will be analogous to the Module Description Language used for Ansible modules (see [`counc009/state_based`](https://github.com/counc009/state_based/tree/main/modules) for examples), but with command-line flag syntax instead of key-value module arguments.
2. **A verifier that checks programs against those specs.** Aaron will build this on top of the State Calculus already used in Astrogator.
3. **Empirical evidence that LLMs can extract utility behavior from man pages at all.**

This repository addresses step 3. It is *upstream* of steps 1 and 2 — we cannot meaningfully build the specification language until we have evidence the source material (man pages) is rich enough for an LLM to work from.

## Related work — Caruca (Lamprou et al., 2025)

The most directly related prior work is **Caruca** ([arXiv 2510.14279](https://arxiv.org/abs/2510.14279), October 2025), led by Michael Greenberg (also a co-author of *Smoosh*, the executable formal semantics for the POSIX shell). Caruca uses an LLM to extract formal specifications from man pages for 60 coreutils/POSIX commands and reports 59/60 correctness on their own evaluation. Worth knowing about, and worth reading before doing anything in this repository. See `for_aaron.md` for the open question of whether to use Caruca's prompt as a multi-model baseline.

Caruca answers a **different question** than this experiment, however. Caruca asks "can an LLM produce a formal specification from a man page?" and judges correctness by spec-level inspection. This experiment asks "can an LLM produce *executable, behaviorally-faithful code* from a man page, and can we *validate* that code by differential testing against the real utility?" Caruca did not generate executable implementations, did not generate test suites, and did not iterate on test feedback. Their validation method does not address the bootstrapping problem that motivates Aaron's Chapter 5: even if 59/60 of their specs *look* correct, there is no execution-level evidence that they actually behave as advertised.

So this experiment complements Caruca rather than duplicating it. Caruca should be cited and treated as the spec-extraction baseline; this experiment focuses on the *spec-validation-by-execution* question.

## The experimental design

Because we do not yet have a Bash specification language to test against, we use **Rust implementations as a proxy**. Rust is executable and testable, so it gives us a measurable handle on whether the LLM understood the man page. The hypothesis is: *if an LLM can write a working Rust implementation of `cp` from the `cp` man page, that's evidence it could write a correct specification of `cp` from the same source — and the test suite generated from the same man page is a candidate validation harness for the eventual spec.*

For each of `cp`, `mv`, `find`, and `sudo`:

1. Use an LLM to generate a Rust implementation of the utility, given only its `man` page.
2. Use an LLM to generate a Bash test suite for the utility, given only its `man` page.
3. Iterate until the generated tests pass on the **real** system utility (GNU coreutils inside Docker — see Evaluation methodology below).
4. Run the tests against the LLM-generated Rust implementation.

## Evaluation methodology

Following the structural pattern of Astrogator's Sections 6.1–6.3 (benchmark suite → LLM code generation → accuracy table), this experiment defines its evaluation as:

### Benchmark suite

Four GNU coreutils / POSIX-style utilities chosen for diversity of behavior:

| util  | source pkg (Debian trixie) | why it's interesting |
|-------|----------------------------|----------------------|
| `cp`  | coreutils 9.7-3            | trailing-slash + recursion + symlink semantics; well-covered man page |
| `mv`  | coreutils 9.7-3            | rename-vs-move + cross-device fallback; small flag set |
| `find`| findutils 4.10.0-3         | huge flag surface; predicate-language semantics; long man page |
| `sudo`| sudo 1.9.16p2-3+deb13u1    | privilege/security semantics; mostly-policy not mostly-syntax; stress test for "can the LLM spec security behavior from prose alone?" |

Frozen man pages live in `utils/<util>/manpage.txt` (rendered) and `manpage.1` (raw groff), with provenance in `utils/<util>/_source.json`. See `decisions.md` for why Debian trixie is the canonical source rather than macOS BSD or upstream cgit.

### LLM code generation

- **Model.** A single dated snapshot, `gpt-5.5-2026-04-23` (pinned in `.env`). Single-model on purpose: the experiment is a longitudinal failure-taxonomy study on four utilities, not a model-vs-model leaderboard. See `for_aaron.md` for the open question of whether to add a second model as a sanity check.
- **Prompts.** `prompts/impl.md` (Rust implementation) and `prompts/tests.md` (Bash test suite). Both are zero-shot, structured-output (JSON-schema), and content-hashed in `_logs/log.jsonl` per round to detect drift.
- **Iteration.** Round 1 is a cold call against just the man page. Rounds 2+ append a "Previous attempt feedback" block built by `scripts/driver.py` from the prior round's failing tests and Rust build error.

### Verifier accuracy — three axes per Aaron's framing

1. **Test correctness.** Fraction of LLM-generated tests that pass against the real utility (GNU coreutils in Docker). Tells us whether tests-from-man-page is a viable validation strategy.
2. **Implementation correctness.** Fraction of tests passing on the LLM-generated Rust implementation. Compared against (1) to isolate impl-side mistakes from test-side mistakes.
3. **Coverage.** Two views — flag coverage (fraction of man-page-documented flags exercised by at least one test) and branch/line coverage on the Rust impl via `cargo tarpaulin`.

The **oracle** for (1) is GNU coreutils running on `debian:trixie-20260421-slim` inside Docker (see `docker/Dockerfile`). This matters: round 1 of `cp` was originally run against macOS BSD `/bin/cp`, which silently disagrees with GNU `cp` on flag set and produced contaminated results — see `runs/cp/legacy_pre_session/_README.md` for the postmortem.

### What data we collect, and what's actually important

Listed in order of research value:

1. **Failure taxonomy (qualitative).** Concrete examples of what the LLM got wrong. Hallucinated flags, wrong precedence between flags, missing edge cases (e.g. `cp file dir/` vs. `cp file dir`), wrong exit codes, misunderstood semantics of trailing slashes. This is the actual product of the experiment. See `taxonomy.md` for the running catalog (Tambon-2025 generic-bug lens + Astrogator-style verifier-result decomposition).
2. **Test correctness rate** (axis 1 above).
3. **Implementation correctness rate** (axis 2 above).
4. **Flag + branch coverage** (axis 3 above).
5. **Iteration cost.** Number of LLM regeneration rounds needed before tests converge, and total `$` spent.

Item 1 is more important than every other item combined. Numbers frame the story; the failure taxonomy *is* the story.

## Repository layout

```
formal-verification/
├── README.md                          ← this file (project framing)
├── for_aaron.md                       ← weekly status report (READ FIRST)
├── taxonomy.md                        ← running failure catalogue
├── decisions.md                       ← decision log (TOC at top)
├── SETUP.md                           ← stack choices + onboarding
├── dashboard/                         ← Streamlit dashboard reading runs/
│   ├── streamlit_app.py
│   ├── data.py
│   └── app_pages/
├── utils/
│   └── <util>/                        ← frozen man-page input per util
│       ├── manpage.txt                ← rendered (mandoc -Tutf8 | col -bx)
│       ├── manpage.1                  ← raw groff
│       └── _source.json               ← provenance: URL, pkg version, sha256
├── runs/
│   └── <util>/
│       ├── SUMMARY.md                 ← per-util cross-session summary
│       ├── legacy_pre_session/        ← pre-rework baseline (read-only)
│       │   ├── _README.md
│       │   └── round_01/              ← oracle was BSD cp on macOS; contaminated
│       │       ├── impl/
│       │       ├── tests/
│       │       ├── results_real.jsonl
│       │       └── _logs/
│       └── <session_id>/              ← ISO 8601 UTC: YYYY-MM-DDTHH-MM-SSZ
│           └── round_NN/
│               ├── impl/              ← Rust crate (Cargo.toml + src/main.rs)
│               ├── tests/             ← LLM-generated Bash tests + _manifest.json
│               ├── _logs/             ← prompt, raw response, log.jsonl
│               ├── results_real.jsonl       ← tests vs. real utility (host)
│               ├── results_real-gnu.jsonl   ← tests vs. real utility (Docker GNU)
│               ├── results_impl.jsonl       ← tests vs. LLM Rust impl
│               └── _observations.md   ← qualitative analyst notes
├── prompts/
│   ├── impl.md                        ← Rust-generation prompt template
│   └── tests.md                       ← test-generation prompt template
├── scripts/
│   ├── driver.py                      ← render prompt → call OpenAI → save artifacts (handles iteration)
│   ├── run_tests.py                   ← run a round's tests against real or Rust impl
│   ├── freeze_manpage.sh              ← fetch + render man page from manpages.debian.org
│   ├── sync_openai_docs.sh            ← refresh docs/openai/ mirror
│   ├── coverage_flags.py              ← flag-coverage metric (manpage flags vs. exercised flags)
│   ├── coverage_rust.sh               ← cargo tarpaulin line/branch coverage in Docker
│   ├── eval_round.sh                  ← roll-up: test pass rates + flag cov + line cov, one-line summary
│   └── init_observations.sh           ← scaffold a round's _observations.md
├── docker/
│   ├── Dockerfile                     ← debian:trixie + coreutils + findutils + sudo + Rust
│   ├── build.sh
│   └── run.sh                         ← exec a command in the GNU oracle container
├── docs/
│   └── openai/                        ← mirrored openai-python SDK reference (pinned 2.35.1)
│       ├── README.md                  ← router: when-to-consult-what
│       ├── responses_create.md        ← verified parameter list
│       ├── reasoning.md               ← effort + token accounting
│       ├── structured_outputs.md
│       ├── errors.md
│       ├── _pin.txt
│       └── _responses_create_signature.txt
├── literature/                        ← downloaded prior work + synthesis
│   ├── README.md
│   ├── _synthesis.md
│   └── *.pdf                          ← Caruca, Endres, Tambon, Westenfelder, Schulhoff, ...
├── 2507.13290v2.pdf                   ← Astrogator paper
├── 2511.19422v1.pdf                   ← SLMFix paper
└── Prelim_Proposal-2.pdf              ← Aaron's prelim proposal
```

## Background reading

Read in this order:

1. **`2507.13290v2.pdf` — Astrogator (Councilman et al., 2025).** The system this project builds on. Sections 1–5 give the formal-query-language and verifier design. Section 6 reports evaluation (and is the structural template for our own eval — see "Evaluation methodology" above). Section 7.2 sketches Bash and Arduino as future targets.
2. **`Prelim_Proposal-2.pdf` — Aaron Councilman's preliminary proposal.** Chapters 4 and 5 are the directly relevant ones — they describe the planned Bash extension and the bootstrapping problem this experiment helps address.
3. **`literature/caruca_2025_*.pdf` — Caruca (Lamprou et al., 2025).** Closest prior work; spec extraction from man pages. Read this carefully and understand exactly what it does and does not do before writing any code.
4. **`2511.19422v1.pdf` — SLMFix (Fu, Gupta et al., 2025).** RL fine-tuning to fix syntax/type errors in LLM-generated code for low-resource DSLs. Less directly relevant to your immediate task but useful context for how the lab thinks about LLM-output reliability.

The `literature/` directory contains downloaded prior work most directly relevant to the man-page-to-implementation question, with a synthesis (`literature/_synthesis.md`) describing what's been tried, what's known about LLM failure modes from prior empirical studies, and where this experiment fits. Recommended order within `literature/`: Caruca → Endres → Tambon → Westenfelder. The remaining seven are background, not blocking.

Papers in `literature/` and the Astrogator/SLMFix/Prelim PDFs at the repo root were ingested into [Delphi](https://github.com/synthetic-sciences/delphi) — a local RAG / indexing MCP server — to enable semantic search over the corpus during analysis. `delphi research` (deep mode) was used during the Caruca-positioning write-up to ground claims in indexed paper chunks rather than paraphrasing from memory.

## What this work is *not*

- **Not** production-grade reimplementations of GNU coreutils. The Rust impls are research artifacts.
- **Not** a benchmark. The deliverable is qualitative findings plus a small data table per utility, not a leaderboard.
- **Not** a final answer. It's an early-stage signal that informs whether the lab should commit engineering effort to designing a Bash specification language and verifier.

## Dashboard

`streamlit run dashboard/streamlit_app.py` from the repo root opens a local dashboard that reads the latest data in `runs/`:

- **Overview** — KPIs across all utilities, latest round per util, headline findings.
- **Trajectory (per utility)** — round-over-round pass rates against the GNU oracle and the Rust impl, plus flag/line coverage.
- **Test diversity** — positive (utility should succeed) vs. negative (utility should error) test breakdown per round, plus the 2x2 pass/fail × pos/neg matrix that Aaron asked for.
- **Failure browser** — every test in a round with its GNU outcome and Rust outcome side by side; the "GNU fail, Rust pass" quadrant is the LLM-vs-LLM drift case.
- **Reproducibility (A/B)** — the N=1 caveat made visible.
- **Cost & tokens** — running API spend.

No data flows out of the repo — the dashboard reads `runs/<util>/<session>/round_NN/` and `utils/<util>/_source.json` directly. To regenerate the underlying numbers, run `scripts/eval_round.sh <util> <session> <round>` for the round you care about, then refresh the page.

## Status

For the live status see the dashboard's *Overview* page and [`for_aaron.md`](for_aaron.md). Briefly: all four utilities (`cp`, `mv`, `find`, `sudo`) have round 1 baselines against the GNU oracle; `cp` has round 2; reproducibility is N=1 across the board pending a planned resampling pass.
