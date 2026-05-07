# For Aaron — status check on the Bash man-page experiment

Darsh Poddar · 2026-05-07

One-page status report on the man-page → Rust experiment that's upstream of your Bash specification language and verifier work. Companion artifacts: `taxonomy.md` (failure schema), `decisions.md` (provenance + design choices), `README.md` (project framing).

## 1. Where the experiment is

`cp` baseline ran. Pipeline is infrastructured for iteration + multi-utility rollout.

| metric | value |
|---|---|
| utility | `cp` |
| oracle | GNU `cp` 9.7-3 (Debian trixie, in Docker) |
| tests generated | 30 |
| tests correct vs GNU oracle | **28 / 30 (93%)** |
| tests correct vs Rust impl | n/a — impl failed to compile (single E0515 lifetime error) |
| flag coverage | 77.78% |
| branch / line coverage | n/a (compile failed) |
| LLM | `gpt-5.5-2026-04-23`, single model, reasoning effort `medium` |
| API spend | $0.67 (impl + tests, two calls, ~27K tokens) |

Provenance lives at `runs/cp/legacy_pre_session/round_01/`. The numbers above are from re-running that round's tests against the **GNU oracle in the Docker container** after fixing a BSD-vs-GNU oracle bug. The original macOS BSD oracle showed 13/30 — most of those failures were `cp` flags that GNU documents and BSD doesn't implement, not LLM mistakes. See `decisions.md` §1 for why the canonical man-page source is now Debian trixie's pre-rendered groff.

The two surviving real-oracle failures are interesting:

- `018_strip_trailing_slashes.sh` — Bash itself dereferences `symlink/` before `cp -P --strip-trailing-slashes` ever sees the argument. Failure at the shell/`cp` semantic seam, not in `cp`.
- `022_interactive_decline_overwrite.sh` — GNU `cp -i` silently skips the prompt and exits nonzero when stdin is not a TTY. The man page is silent on this behavior.

Both are misread-edge-case failures (Tambon §4.1.1 category 5: "Missing Corner Case"). Hardest and most informative category in the schema.

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

## 3. Plan from here

Decisions already locked in by the team:

1. **Single model for now: `gpt-5.5-2026-04-23`.** Multi-model replication (Astrogator-style six-model setup, SLMFix's eight) is deferred until the GPT-5.5 results are converged. Cost estimate for the multi-model pass is ~$1–2k in API credits.
2. **GNU coreutils version pin: Debian trixie.** Same versions as `scripts/freeze_manpage.sh` pulls man pages from. We are intentionally not replicating Astrogator's three-OS VM matrix (Debian 12 / Ubuntu 24 / RHEL 9.6) at this stage — single oracle keeps the variance small while we develop the technique.
3. **Utility roll-out: all four in parallel.** `cp`, `mv`, `find`, `sudo` get round 1 immediately. Iteration on each runs after the round-1 baseline is collected. This trades depth-first per-utility for breadth-first cross-utility patterns earlier.
4. **Iteration loop:** round N+1 prompt = round N base prompt + structured feedback block (top-10 failed tests with stderrs + cargo `build_error.txt` if present + `_observations.md` analyst notes). Driver tracks `prompt_template_sha256`, `manpage_sha256`, and `feedback_sha256` independently. Convergence criterion to be established empirically — first goal is to see whether iteration moves the needle at all on the two surviving real-oracle failures above.

## 4. Coverage methodology

Two orthogonal metrics, both wired into `scripts/`:

- **Flag coverage** (`scripts/coverage_flags.py`): fraction of flags documented in the canonical man page that are exercised by ≥1 test in the round. Catches "tests cluster on the easy 20% of the surface."
- **Branch / line coverage** (`scripts/coverage_rust.sh`): `cargo tarpaulin` against the Rust crate when it compiles. Decoupled from test pass/fail.

Astrogator's Sec. 6.3 reports per-program acceptance/rejection in a 21-row × 4-column table (Correct-Accepted / Correct-Rejected / Incorrect-Accepted / Incorrect-Rejected). I plan to mirror that shape per utility, with rows = test categories (basic copy, recursion, symlink handling, backup, etc.) and cells = the four test-vs-oracle outcomes from `taxonomy.md` §2. Same structural pattern, different rows.

## 5. One open question

Tambon's taxonomy was coded by three reviewers in 108 person-hours on 333 samples, with inter-rater agreement reported. I'm one labeler doing this part-time. Two options:

- **Single-labeler + caveat.** Ship observations as I write them; explicitly note in any writeup that inter-rater agreement is not reported.
- **Second labeler.** Recruit Aryan, David, or another undergrad for a retroactive cross-check on a representative sample of observations; compute Cohen's κ. More defensible, more time.

Default is option 1 unless you want the stronger claim. Flag at any point — it changes the workflow, not the experiment.

## 6. What we are explicitly **not** doing

- **Not** re-deriving formal specifications. Caruca already mined syntax specs for 120 utilities and behavioral specs for 60. Caruca's syntax output is a candidate seed for the MDL design when you get there.
- **Not** designing or touching the Module Description Language for Bash. That's your work, downstream of this experiment.
- **Not** building the State Calculus extension for Bash. Same.
- **Not** producing production-grade reimplementations. The Rust impls are research artifacts — they exist to give an executable handle on whether the LLM understood the man page; they are not useful as `cp` replacements and we won't pretend otherwise.

## Repo entry points

- `README.md` — project framing + actual repo layout
- `taxonomy.md` — failure schema (Tambon + Astrogator-style)
- `decisions.md` — provenance + design choices (TOC at top)
- `CLAUDE.md` / `AGENTS.md` — onboarding for future agents working on this repo
- `runs/cp/legacy_pre_session/round_01/` — first data point
- `runs/cp/SUMMARY.md` — cross-session metric trajectory

I will send a follow-up after the first GPT-5.5 multi-utility pass produces concrete observations across `cp` / `mv` / `find` / `sudo`.
