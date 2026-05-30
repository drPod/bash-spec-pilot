# Bash Utility Specifications via LLMs — Exploratory Experiment

This repo is an exploratory experiment extending Aaron Councilman's prior work to Bash. Astrogator
([arXiv 2507.13290](https://arxiv.org/abs/2507.13290)) formally verifies LLM-generated Ansible code
against a user-confirmed formal query; SLMFix ([arXiv 2511.19422](https://arxiv.org/abs/2511.19422))
fine-tunes a small model to repair statically-detectable errors in LLM-generated DSL code.
Astrogator's Section 7.2 names Bash as a future target, but a Bash verifier needs per-utility formal
semantics that no public source currently provides.

The goal of this project is to figure out whether the source material (Linux man pages) is rich
enough for an LLM to work from, and if it isn't, to characterize how it fails so Aaron's later
design can work around the failures.

Prior work suggests man pages are enough to mine *syntax* specifications (Caruca, Lamprou et al.
2025, 99.7% argument-level correctness) but recovers *behavioral* semantics from execution traces,
not from prose alone. 

This experiment asks the next question: **can an LLM go from a man page directly
to an executable implementation that matches the real GNU utility's behavior, and what does it get
wrong when it can't?** Rust stands in for the not-yet-existent Bash specification language, and a Bash
test suite generated alongside the impl is differentially tested against the real GNU binary in a
pinned Debian trixie container. The output of interest is not a pass rate but a catalogue of failure
modes in [`taxonomy.md`](taxonomy.md).

## Repository layout

```
formal-verification/
├── README.md                          ← this file
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
│   └── *.pdf                          ← Caruca, Endres, Tambon, Westenfelder, Schulhoff, SLMFix, ...
├── 2507.13290v2.pdf                   ← Astrogator paper
├── 2511.19422v1.pdf                   ← SLMFix paper
└── Prelim_Proposal-2.pdf              ← Aaron's prelim proposal
```

## Dashboard

**Hosted:** <https://bash-spec-pilot.streamlit.app/>. **Local:**
`uv run streamlit run dashboard/streamlit_app.py` from the repo root. Both serve the same six-page
dashboard, reading the latest data in `runs/`:

No data flows out of the repo — the dashboard reads `runs/<util>/<session>/round_NN/` and
`utils/<util>/_source.json` directly. To regenerate the underlying numbers, run
`scripts/eval_round.sh <util> <session> <round>` for the round you care about, then refresh the
page.
