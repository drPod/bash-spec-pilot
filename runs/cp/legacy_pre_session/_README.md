# Legacy round_01 (pre-session layout)

This directory holds the very first `cp` run, conducted on macOS against BSD
`/bin/cp` before the iteration / Docker / session-id infrastructure existed.
It is preserved verbatim as a historical baseline. Do not edit the
contents — treat this as a read-only artifact.

## Why it lives here

The original layout was `runs/<util>/round_<NN>/`. That was flat: a rerun
would clobber it, and there was no notion of distinct iteration trajectories
(sessions). The current layout is `runs/<util>/<session_id>/round_<NN>/`
where `session_id` is an ISO 8601 UTC timestamp of the first round in that
trajectory. To preserve the existing data without losing it under the new
scheme, the old `runs/cp/round_01/` was moved wholesale to
`runs/cp/legacy_pre_session/round_01/`.

## What's worth knowing about this run

- **Oracle was BSD `/bin/cp` on macOS, not GNU.** This is wrong for the
  experiment's stated target (Linux/GNU userland, see `decisions.md`
  Section 1). 13/30 tests passed, mostly the ones using flags BSD and GNU
  share (`-T`, `-R`, `-l`, `-s`, `-P`, `-L`, `-H`, `-f`, `-p`, `-a`).
  Failures were predominantly because BSD `cp(1)` doesn't accept `-t`, `-d`,
  `-u`, `-b`, `--update=`, `--attributes-only`, `--strip-trailing-slashes`,
  `--parents`, `--remove-destination`, `--keep-directory-symlink`, `--debug`.
  These are not LLM hallucinations — they are flags GNU `cp` documents but
  BSD `cp` doesn't implement. The test suite read the GNU man page
  faithfully; the host oracle was the wrong tool.
- **The Rust impl failed to compile.** Single rustc error
  (E0515 lifetime issue at `src/main.rs:159`). See
  `runs/cp/legacy_pre_session/round_01/impl/` for the full source.
- **Tests `021_no_clobber_skips_existing.sh` and
  `022_interactive_decline_overwrite.sh`** "fail" only because BSD `cp`
  prints to stderr in an unexpected way for the `--no-clobber` / `-i`
  paths the GNU man page documents. With a GNU oracle these would likely
  pass. (Verifiable by re-running against `--target real-gnu` once the
  Docker oracle is wired up.)

## Should this be replayed in the new structure?

See the closing paragraph of `decisions.md` § "Iteration + Docker +
coverage rebuild (2026-05-07)" for the answer. Short version: **no**, this
trajectory is contaminated by the wrong oracle and the wrong infra. Treat
it as a historical baseline and start a fresh session against `real-gnu`
when the team is ready to spend more API credits.
