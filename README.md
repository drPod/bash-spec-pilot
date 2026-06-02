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

This experiment asks the next question: **can an LLM go from a man page directly to an executable
implementation that matches the real GNU utility's behavior, and what does it get wrong when it
can't?** Rust stands in for the not-yet-existent Bash specification language, and a Bash test suite
generated alongside the impl is differentially tested against the real GNU binary in a pinned Debian
trixie container. The output of interest is not a pass rate but a catalogue of failure modes in
[`docs/research/taxonomy.md`](docs/research/taxonomy.md).

Okay so, basically, if you ask it to write an implementation of a utility then write tests, it
writes the impl and then writes the tests with the same mistakes. If the model misreads the manpage
in some way ("this flag does X" when it actually does Y), it misreads it the same way in both calls.

So, to fix that, we generated tests in a separate conversation (no shared context with the impl
call) and gave it two flavors of adversarial prompt:

```text
- Cold: "Read the manpage. Ignore any implementations. Write tests that surface bugs
  in any implementation that misreads the manpage." Plus a thematic slice (errors,
  flags, environment, examples) to focus the model on one part of the documented
  surface per call.
- Post-hoc: "Here's the manpage AND here's a frozen Rust implementation. Find
  documented behaviors the impl doesn't handle correctly." Built but not run yet.
```

**Okay so the cool thing we found:** on `mv`, the manpage says `--strip-trailing-slashes` just
strips trailing slashes off the SOURCE before moving. The Rust impl read that literally, strips the
slash, does the move. But if you run `mv /tmp/file/ /tmp/dst` on real GNU `mv` (where `/tmp/file` is
just a regular file, not a directory) it actually rejects it with
`cannot stat '/tmp/file/': Not a directory`. So the trailing slash is doing a hidden "this better be
a directory" check that the manpage doesn't mention anywhere.

Basically, the Rust impl matches the manpage. Real `mv` doesn't. The LLM didn't mess up, the manpage
just lies. And that's kind of the whole point of the project: if you build a Bash spec language out
of manpages, it'll describe behavior the real binary doesn't actually do.

## Repository layout

```text
formal-verification/
├── README.md                          ← this file
├── docs/
│   ├── openai/                        ← mirrored openai-python SDK reference (pinned 2.35.1)
│   │   ├── README.md                  ← router: when-to-consult-what
│   │   ├── responses_create.md        ← verified parameter list
│   │   ├── reasoning.md               ← effort + token accounting
│   │   ├── structured_outputs.md
│   │   ├── errors.md
│   │   ├── _pin.txt
│   │   └── _responses_create_signature.txt
│   └── research/
│       ├── taxonomy.md                ← running failure catalogue
│       ├── decisions.md               ← decision log (TOC at top)
│       ├── adversarial_prior_art.md   ← wave-4 prior-art pass (homogenization trap, ACH, Code-A1)
│       └── setup.md                   ← stack choices + onboarding
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
│               ├── results_real-gnu.jsonl   ← tests vs. real utility (Docker GNU oracle)
│               ├── results_impl.jsonl       ← tests vs. LLM Rust impl
│               └── _observations.md   ← qualitative analyst notes
├── prompts/
│   ├── baseline/
│   │   ├── impl.md                    ← Rust-generation prompt template
│   │   └── tests.md                   ← test-generation prompt template
│   └── adversarial/                   ← wave-4 adversarial test variants
│       ├── README.md                  ← templates + slice vocabulary + schema
│       ├── cold_section.md            ← manpage-only cold prompt ({{slice_name}})
│       └── posthoc.md                 ← manpage + frozen Rust impl, whitebox bug-finding
├── tests/
│   └── properties/<util>/             ← wave-4 metamorphic floor (hand-written, non-LLM)
├── scripts/
│   ├── pipeline/
│   │   ├── driver.py                  ← render prompt → call OpenAI → save artifacts (handles iteration + wave-4 adversarial modes)
│   │   └── run_tests.py               ← run a round's tests against the GNU oracle or Rust impl
│   ├── freeze/
│   │   └── freeze_manpage.sh          ← fetch + render man page from manpages.debian.org
│   ├── eval/
│   │   ├── eval_round.sh              ← baseline roll-up: test pass rates + flag cov + line cov, one-line summary
│   │   ├── eval_adversarial.sh        ← wave-4 roll-up: static-filter + real-gnu + rust + 5-bucket classify
│   │   ├── static_filter.sh           ← bash -n + shellcheck pre-filter (SLMFix-style)
│   │   ├── classify_divergence.py     ← 5-bucket classifier + mut@k + DEPC + effective-test rate
│   │   ├── run_metamorphic.sh         ← runner for tests/properties/<util>/*.sh in trixie
│   │   ├── minimize_failure.py        ← ReduceFix-style LLM divergence minimizer
│   │   ├── coverage_flags.py          ← flag-coverage metric (manpage flags vs. exercised flags)
│   │   ├── coverage_rust.sh           ← cargo tarpaulin line/branch coverage in Docker
│   │   └── positivity.py              ← per-round positive vs negative test breakdown
│   └── dev/
│       ├── sync_openai_docs.sh        ← refresh docs/openai/ mirror
│       ├── init_observations.sh       ← scaffold a round's _observations.md
│       └── format_readme.sh           ← rewrap README.md prose at 100 cols (mdformat)
├── docker/
│   ├── Dockerfile                     ← debian:trixie + coreutils + findutils + sudo + Rust
│   ├── build.sh
│   └── run.sh                         ← exec a command in the GNU oracle container
└── literature/                        ← downloaded prior work + synthesis
    ├── README.md                      ← indexed catalogue per paper
    ├── _synthesis.md
    ├── councilman_2025_astrogator.pdf ← Astrogator (system this project extends)
    ├── councilman_2025_prelim_proposal.pdf  ← Aaron's prelim proposal
    ├── slmfix_2026_emnlp.pdf          ← SLMFix (lab-internal sibling work)
    └── *.pdf                          ← Caruca, Endres, Tambon, Westenfelder, Schulhoff, ...
```

## Dashboard

**Hosted:** <https://bash-spec-pilot.streamlit.app/>. **Local:**
`uv run streamlit run dashboard/streamlit_app.py` from the repo root. Both serve the same six-page
dashboard, reading the latest data in `runs/`:

No data flows out of the repo — the dashboard reads `runs/<util>/<session>/round_NN/` and
`utils/<util>/_source.json` directly. To regenerate the underlying numbers, run
`scripts/eval/eval_round.sh <util> <session> <round>` for the round you care about, then refresh the
page.
