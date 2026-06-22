# Claude-subagent pipeline sweep (2026-06-22)

Session id: `2026-06-22T15-46-04Z-claude` (all four utils share it).

> **NON-CANONICAL RUN. Read before citing any number here.**
>
> The generator was **Claude (claude-opus-4-8) subagents**, not the pinned
> `gpt-5.5-2026-04-23` OpenAI driver. It was run to exercise the full pipeline
> end-to-end without spending OpenAI credits. Consequences:
>
> - **Not reproducible** via `scripts/pipeline/driver.py`. There is no
>   `response_id`, no prompt/manpage/feedback sha trail in `_logs/log.jsonl`
>   (the driver was never invoked).
> - **Not comparable** to the canonical `runs/<util>/<ISO>Z/` sessions. A
>   different model writes different Rust and different tests.
> - Each round dir carries `_GENERATOR.json` flagging this.
>
> Findings below are real signals from a real differential test, but any one
> worth promoting to `docs/research/taxonomy.md` or `decisions.md` should be
> re-run through the canonical gpt-5.5 driver first. Nothing here is written
> into the canonical research docs.

## Method

Standard differential pipeline, with Claude subagents standing in for the
OpenAI call, and with the wave-4 de-homogenization preserved:

1. Per util, **two independent subagents** (separate contexts, no shared state):
   an *impl* agent (frozen manpage -> single-file Rust crate, build-verified in
   the trixie container) and a *tests* agent (frozen manpage only, cold, never
   shown the impl -> 15-30 grounded Bash tests + `_manifest.json`). 8 agents
   total, run in parallel.
2. `scripts/eval/eval_adversarial.sh <util> <session> 1` per util: static
   pre-filter (`bash -n` + `shellcheck -S error`) -> real-gnu oracle in trixie
   -> rust impl in trixie -> `classify_divergence.py` (5-bucket + mut@k + DEPC).

All four Rust impls compiled clean. No tests were dropped by the static filter.

## Results

| util | tests | real-gnu correct | rust correct | mut@k | DEPC | baseline | divergence | manpage_underspec | shared_bug |
|------|-------|------------------|--------------|-------|------|----------|------------|-------------------|------------|
| cp   | 30    | 30/30            | 29/30        | 0.033 | 1    | 29       | 1          | 0                 | 0          |
| mv   | 30    | 29/30            | 27/30        | 0.100 | 3    | 26       | 3          | 1                 | 0          |
| find | 30    | 30/30            | 29/30        | 0.033 | 1    | 29       | 1          | 0                 | 0          |
| sudo | 29    | 26/29            | 24/29        | 0.138 | 4    | 22       | 4          | 2                 | 1          |

Bucket meanings (`classify_divergence.py`): **baseline** = both match the
oracle; **divergence** = real-correct, rust-incorrect (impl bug); **manpage_underspec**
= real-incorrect, rust-correct, and the test is grounded in a verbatim manpage
span (the manpage commits to behavior the binary does not honor); **shared_bug**
= both fail the test (usually a test-design artifact).

## The research payload: manpage / binary disagreement (3 cases)

These are the point of the project. The test author (cold, manpage-only)
asserted the manpage's literal wording; the real binary does something else.

### mv `--strip-trailing-slashes` (test 022): replication of the headline finding

- **Manpage span quoted:** "remove any trailing slashes from each SOURCE argument".
- **Real GNU mv 9.7:** `mv --strip-trailing-slashes src/ dst` on a regular-file
  `src` fails with `cannot move '.../src' to '.../dst': Not a directory`.
- **Rust impl:** strips the slash literally and moves, exit 0 (matches the manpage).

This independently reproduces the project's central result (decisions.md §10
and the cross-version check in `runs/mv/_crossver/`) from a completely fresh,
de-homogenized, Claude-generated impl+test pair. The trailing slash carries a
hidden "must be a directory" check the manpage never states. A different model,
different code, same defect surfaced: that is the strongest evidence so far that
this is a property of the manpage, not of any one generation.

### sudo `-D` / `--chdir` (test 012): candidate new finding

- **Manpage span quoted:** "Run the command in the specified directory instead
  of the current working directory."
- **Real sudo:** `you are not permitted to use the -D option with /usr/bin/pwd`,
  nonzero exit, even running as root.
- The manpage presents `-D` as an unconditional capability. Real sudo gates it
  behind a sudoers setting (`runcwd`) the SUDO(8) page never mentions. The
  manpage underspecifies the policy precondition.
- Caveat: confounded by the as-root execution context (see sudo caveat below),
  but the refusal here is a policy gate, not an auth prompt, so the signal holds.

### sudo `-s` shell command (test 018): weak, likely test-construction

- **Manpage span quoted:** "If a command is specified, it is passed to the shell
  as a simple command using the -c option."
- **Real sudo:** `/bin/sh: 1: printf shell_ran: not found`, exit 127.
- The failure looks like the test's command was not a valid `sh -c` simple
  command rather than a genuine manpage defect. Counted by the classifier
  (grounded + real-fail + rust-pass) but should not be promoted without a
  cleaner repro.

## Impl-side divergences (impl bugs + coverage gaps)

Genuine edge-case bugs (flag implemented, edge handled wrong):

- **cp 025** force+backup when SOURCE and DEST are the same existing file: rust
  errors `No such file or directory`; real cp exits 0.
- **mv 009** `-i` with no affirmative answer (EOF on stdin): rust overwrites;
  real mv keeps the destination.
- **sudo 020** `-i` login: rust's login-shell invocation mishandles the command
  (printf usage error); real sudo runs it and sets HOME.
- **sudo 023** `SUDO_COMMAND`: rust includes the `sh -c` wrapper in the value;
  real sudo sets the bare command path.
- **sudo 027** duplicate `-u`: rust accepts it (exit 0); real sudo rejects it as
  documented.
- **sudo 029** `-K` with a command: rust accepts it; real sudo rejects it as
  documented.

Coverage gaps (flag deliberately not implemented by the impl agent, so the test
diverges by construction; real binary supports it):

- **mv 021** `--exchange`, **mv 030** `--debug`, **find 019** `-delete`.

## Test-design artifacts

- **sudo 021** `-i -u daemon` sets LOGNAME: both real and rust fail (`daemon`
  has no login shell), so the test cannot run. shared_bug, not a spec signal.

## sudo caveat (known limitation, unchanged from the repo's design)

`run_tests.py` runs the oracle as **root** inside the container. As root, sudo
grants everything without authentication, so every password/authorization gate
the manpage describes is bypassed. The sudo numbers measure argument-parsing and
env/identity fidelity only, not the authorization core. The metamorphic floor
(`tests/properties/sudo/`, run via `run_metamorphic.sh --as-user`) is the place
that exercises non-root behavior.

## What this run licenses

- **Strong:** the mv `--strip-trailing-slashes` manpage defect is model- and
  generation-independent. Reproduced here from scratch.
- **Worth a canonical re-run:** the sudo `-D`/`--chdir` policy-gate gap looks
  like a genuine second manpage-underspec case.
- **Not licensed:** any quantitative comparison of these mut@k numbers against
  the gpt-5.5 sessions. Different generator.

## Reproduce

```
SID=2026-06-22T15-46-04Z-claude
for u in cp mv find sudo; do
  scripts/eval/eval_adversarial.sh "$u" "$SID" 1
done
```

(Re-running the eval is deterministic against the frozen impls and tests. Re-running
the *generation* is not: it would dispatch fresh Claude subagents.)
