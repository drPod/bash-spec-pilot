# For Aaron — status check on the Bash man-page experiment

Darsh Poddar · 2026-05-07

One-page status report on the man-page → Rust experiment that's upstream of your Bash specification language and verifier work. Companion artifacts: `taxonomy.md` (failure schema), `decisions.md` (provenance + design choices), `README.md` (project framing).

## 1. Where the experiment is

**N=1 per cell currently. Reproducibility test (same prompt, two calls, `gpt-5.5-2026-04-23`) showed 291 vs 393 line outputs and a compile-success flip — single-call output is not stable. Every number below is provisional pending N≥3 resampling. Variance unmeasured.** Full A/B report at `runs/cp/_reproducibility_2026-05-07T11-18-09Z.md`; summarized in `decisions.md` § 8.

Wave 2 ran fresh round-1 sessions for all four utilities against the GNU oracle in the trixie container, plus a round-2 iteration on `cp`.

| util | session | round | tests gen | test_real-gnu | test_rust | flag_cov | line_cov | notes |
|------|---------|-------|-----------|---------------|-----------|----------|----------|-------|
| `cp` | 2026-05-07T11-10-34Z | 1 | 28 | 26/28 (93%) | 26/28 (93%) | 66.67% | 60.0% | Fresh session against GNU oracle. Rust impl compiled cleanly (no E0515 recurrence). Two failures: `024_interactive_i_decline.sh` (`-i` non-TTY semantics) and `026_strip_trailing_slashes.sh` (bash dereferences `link.txt/` before cp sees it). |
| `cp` | 2026-05-07T11-10-34Z | 2 | 28 | 26/28 (93%) | **28/28 (100%)** | 66.67% | 87.45% | LLM engaged with feedback (filename suffixes, `IsTerminal` import) but rewrites still wrong. Rust 28/28 ≠ GNU correctness — see § 3. |
| `mv` | 2026-05-07T11-11-40Z | 1 | 26 | 24/26 (92%) | 25/26 (96%) | 88.89% | 65.04% | Stream-convention bug on `-v` (Rust writes to stderr, GNU to stdout); same `-i` non-TTY shape as `cp`. |
| `find` | 2026-05-07T11-17-44Z | 1 | 30 | 30/30 (100%) | 29/30 (97%) | 60.0%* | 75.84% | *Methodology debt: `coverage_flags.py` only counts `-X`/`--xxx`, misses `find` primaries (`-name`, `-type`, `-exec`, …). Real surface coverage substantially higher; reported number is misleading-low. Self-cut scope — impl explicitly skips locale/SELinux/xattrs/sparse; tests stayed inside the implemented subset. |
| `sudo` | 2026-05-07T11-25-03Z | 1 | 29 | 28/29 (97%) | 28/29 (97%) | 65.52% | 69.63% | Container runs as root → many tests pass trivially. The 28/29 number is itself a finding about a class of utilities the man-page-only approach cannot fully cover — see § 4. |

Provenance for each row lives at `runs/<util>/<session>/round_<N>/`. Per-round qualitative analyst notes in `_observations.md` siblings; cross-session per-util roll-ups in `runs/<util>/SUMMARY.md`.

## 2. Caruca was published October 2025 — flag if not on your radar

Lamprou et al., *Caruca: Effective and Efficient Specification Mining for Opaque Software Components*, arXiv 2510.14279, October 2025. Co-authors include **Michael Greenberg** (Smoosh) and Nikos Vasilakis (PaSh, Shseer).

What Caruca actually does, beyond "59/60":

- Generates **syntax specifications** (DSL of flags, options, positional args, arities, types) by LLM from man / `--help` pages.
- Derives **behavioral specs** (parallelizability, I/O, pre/post-conditions) from `strace` + OverlayFS execution traces — capped at 4-flag configurations, not from the LLM directly.
- Validates the syntax specs against a hand-built ground-truth syntax spec for 120 commands (two grad students, ~80 person-hours, reconciled). Reports **99.7% argument-level correctness**.
- Validates the behavioral specs against the existing hand-written specs shipping with PaSh / POSH / Shellcheck / Shseer (52 + 17 + 6 + 18 commands). Reports the **59/60** number against that union.
- Does **not** generate executable implementations, generate test suites, or iterate on test feedback.

How our work is distinct: Caruca's validation evidence is "Caruca-mined spec matches the human-written spec" or "PaSh/POSH/Shellcheck/Shseer produces equivalent downstream output with Caruca specs vs. hand-written specs." That's spec-equivalence, not behavioral grounding against a real binary's runtime semantics.

We add (a) an executable Rust implementation, (b) differential testing against the real GNU utility, and (c) iteration on test feedback. Caruca's syntax-spec output is, separately, a clean candidate seed for the Module Description Language design when you reach that step.

## 3. LLM-vs-LLM drift: the central methodology finding

The cleanest empirical result so far is **`cp` round 2**: the LLM-generated Rust impl scored 28/28 against the LLM-generated test suite, while staying at 26/28 against GNU. Both halves of the pipeline coevolved across the iteration step into a closed, self-consistent loop that had quietly drifted away from the real utility. The Rust impl preprocesses argv to strip trailing slashes (matching the LLM's misreading of `--strip-trailing-slashes`); the test asserts that exact behavior; nothing inside the LLM↔LLM perimeter detects the disagreement with GNU. **This is the false-positive failure mode Astrogator's eval was specifically designed to catch — incorrect-program / verifier-accepts — surfaced here as LLM-test-suite / LLM-impl mutual ratification.** Caruca's spec-equivalence validation is structurally vulnerable to the same drift, because "Caruca's spec matches the hand-written spec" never escapes the LLM-or-human-prose plane and into runtime execution against the binary. The `cp` round-2 result is, in the experiment to date, the strongest single piece of evidence that differential testing against the real binary is doing real work that LLM-vs-LLM checking cannot. ~28/28 is what bug-compatibility looks like before differential testing exposes it.

## 4. Sudo as a "split-manpage utility" failure class

The 28/29 sudo number is real signal, not a container artifact. The trixie container does run as root, which means several "deny-without-password" and "deny-RunAs" tests pass trivially — that's the surface-level observation. The deeper finding is that **`sudo` is a utility whose policy-relevant truth is split across two man pages** (`sudo(8)` and `sudoers(5)`), and the LLM only saw the first. The single test-side miss, `012_chdir_directory.sh`, is the canonical specimen: `sudo -D /work /bin/pwd` is rejected by GNU sudo because the default sudoers grants no per-command CWD directive — knowable only from `sudoers(5)`, invisible from `sudo(8)`. Other documented flags with the same shape (`-u` constrained by `RunAs=`, `-g` by `RunAs=:GROUP`, `-A` by `Defaults`, `-T` by `Defaults timestamp_timeout`) tested as passing here only because root is policy-omnipotent in default sudoers. **In a non-root harness, more of these would surface as policy-rejected — and they would surface as test-side bugs every time, because the man page the LLM was given does not contain the rejection rules.** This is a candidate failure class: utilities whose documented behavior is gated by cross-referenced configuration files. The same shape likely applies to `crontab(1)` ↔ `crontab(5)`, `ssh(1)` ↔ `ssh_config(5)`, `systemd` units ↔ unit-file man pages. Not infrastructure to fix; a finding to record.

## 5. Plan from here

Decisions already locked in by the team:

1. **Single model for now: `gpt-5.5-2026-04-23`.** Multi-model replication (Astrogator-style six-model setup, SLMFix's eight) is deferred until the GPT-5.5 results are converged. Cost estimate for the multi-model pass is ~$1–2k in API credits.
2. **GNU coreutils version pin: Debian trixie.** Same versions as `scripts/freeze_manpage.sh` pulls man pages from. We are intentionally not replicating Astrogator's three-OS VM matrix at this stage — single oracle keeps the variance small while we develop the technique.
3. **Utility roll-out: all four in parallel.** `cp`, `mv`, `find`, `sudo` all have round-1 baselines in wave 2. Iteration on `mv`/`find`/`sudo` runs after the meeting; only `cp` has a round 2 so far.
4. **Iteration loop:** round N+1 prompt = round N base prompt + structured feedback block (top-10 failed tests with stderrs + cargo `build_error.txt` if present + `_observations.md` analyst notes). Driver tracks `prompt_template_sha256`, `manpage_sha256`, and `feedback_sha256` independently.
5. **Reproducibility caveat (new, 2026-05-07).** All single-cell numbers above need N≥3 resampling before they can carry weight. Detail in `decisions.md` § 8 and the report at `runs/cp/_reproducibility_2026-05-07T11-18-09Z.md`.

## 6. Coverage methodology

Two orthogonal metrics, both wired into `scripts/`:

- **Flag coverage** (`scripts/coverage_flags.py`): fraction of flags documented in the canonical man page that are exercised by ≥1 test in the round. Catches "tests cluster on the easy 20% of the surface." **Caveat: regex matches `-X` / `--xxx` only.** This is `find`-blind — it misses `find` primaries (`-name`, `-type`, `-exec`, `-print`, `-files0-from`, …) which define the utility's actual surface. The 60% reported for `find` is misleading-low. Documented as deferred methodology debt; not patched before the meeting (see `decisions.md` § 9).
- **Branch / line coverage** (`scripts/coverage_rust.sh`): `cargo tarpaulin` against the Rust crate when it compiles. Decoupled from test pass/fail.

Astrogator's Sec. 6.3 reports per-program acceptance/rejection in a 21-row × 4-column table. I plan to mirror that shape per utility, with rows = test categories and cells = the four test-vs-oracle outcomes from `taxonomy.md` § 2.

## 7. One open question (labeling rigor)

Tambon's taxonomy was coded by three reviewers in 108 person-hours on 333 samples, with inter-rater agreement reported. I'm one labeler doing this part-time. Two options:

- **Single-labeler + caveat.** Ship observations as I write them; explicitly note in any writeup that inter-rater agreement is not reported.
- **Second labeler.** Recruit Aryan, David, or another undergrad for a retroactive cross-check on a representative sample of observations; compute Cohen's κ. More defensible, more time.

Default is option 1 unless you want the stronger claim. Flag at any point — it changes the workflow, not the experiment.

## 8. What we are explicitly **not** doing

- **Not** re-deriving formal specifications. Caruca already mined syntax specs for 120 utilities and behavioral specs for 60. Caruca's syntax output is a candidate seed for the MDL design when you get there.
- **Not** designing or touching the Module Description Language for Bash. That's your work, downstream of this experiment.
- **Not** building the State Calculus extension for Bash. Same.
- **Not** producing production-grade reimplementations. The Rust impls are research artifacts — they exist to give an executable handle on whether the LLM understood the man page; they are not useful as `cp` replacements and we won't pretend otherwise.
- **Not** patching the Dockerfile to add a non-root sudo user before the meeting. The structural manpage-incompleteness for policy-driven utilities is itself the finding (see § 4); a non-root user would paper over it.
- **Not** fixing `coverage_flags.py` for `find` primaries before the meeting. Documented gap; reported `find` flag-cov number explicitly carries the methodology asterisk.

## Repo entry points

- `README.md` — project framing + actual repo layout
- `taxonomy.md` — failure schema (Tambon + Astrogator-style + the three new failure classes from wave 2)
- `decisions.md` — provenance + design choices (TOC at top; § 8 reproducibility, § 9 methodology debts)
- `CLAUDE.md` / `AGENTS.md` — onboarding for future agents working on this repo
- `runs/<util>/SUMMARY.md` — cross-session metric trajectory per util
- `runs/cp/_reproducibility_2026-05-07T11-18-09Z.md` — A/B reproducibility report

I will send a follow-up after wave-2 iteration runs (rounds 2 on `mv`/`find`/`sudo`) and the first N≥3 resampling pass.
