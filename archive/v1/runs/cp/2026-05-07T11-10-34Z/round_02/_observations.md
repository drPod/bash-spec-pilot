# Observations: cp session=2026-05-07T11-10-34Z round=2

## Numbers
- Tests pass on real-gnu: 26/28 (= 93%)
- Tests pass on rust impl: 28/28 (= 100%)
- Flag coverage: 24/36 flags exercised (= 66.67%)
- Branch/line coverage on Rust impl: 87.45%

## Test-correctness failures (tests that failed on the real utility)

Categorize each failure by Tambon-2025 schema
(literature/tambon_2025_*.pdf):
  - hallucinated flag / nonexistent feature
  - wrong default
  - wrong precedence
  - misread edge case
  - misread error case
  - infrastructure (env / shell / quoting bug in test, not the LLM's reading)

Per-failure (analyst fills `<category>`):

- **026_interactive_i_decline_tty.sh** [infrastructure] — -i/--interactive
  prompts before overwrite. The LLM read round-1's analyst note about the
  isatty(0) precondition and tried the recommended fix: wrap cp inside
  `script -q -e -c '"$UTIL" -i "$SRC" "$DST"' /dev/null`. But util-linux's
  `script(1)` in trixie does not honor the inner double-quotes the way the
  test author expected — `"$UTIL"` is literal-passed to the inner shell
  which sees it as a literal command name (since `script` runs a fresh
  child shell that doesn't inherit the parent's `set -u` exported var
  semantics for quoted-but-unexpanded strings the same way). Result: the
  inner shell errors before cp runs, `script` propagates rc=1, the test's
  outer `if !` branch fires, exits 1. Stderr: `cp -i failed under
  pseudo-tty`. The fix the LLM attempted is conceptually correct; the
  shell plumbing for `script` is wrong. Still test-construction.

- **027_strip_trailing_slashes_dir_symlink.sh** [misread edge case] —
  --strip-trailing-slashes removes trailing slashes from SOURCE arguments.
  The LLM took round-1's suggestion to use a directory-symlink so the
  trailing slash is meaningful at syscall time. It then invoked
  `cp -P --strip-trailing-slashes "$linkdir/" "$dst"`. The man page's
  precedence here is subtle: `-P` says "do not follow symlinks" but the
  POSIX rule is that **a trailing slash on a symlink overrides
  -P/-P-equivalent flags and forces dereference**. So GNU cp follows the
  symlink, sees a directory, and errors with "-r not specified; omitting
  directory" — the precise opposite of what `--strip-trailing-slashes` was
  supposed to do (the slash is stripped *after* stat per the man page,
  not before). The LLM's read of `--strip-trailing-slashes` as
  "preprocesses argv to drop trailing slashes before stat" is wrong; the
  flag actually means "strip from filename component AFTER opening parent
  directory." This is the same misread-edge-case Tambon §4.1.1 #5 from
  legacy round 1, persisted across iteration.

## Impl-correctness failures (tests that passed on real, failed on rust)

_None._ The Rust impl scored 28/28 on its own tests including the two that
fail on real-gnu. That sounds good but is misleading: the Rust impl is
matching the **test's wrong expectation** rather than GNU's actual
behavior. For 026, the Rust impl probably doesn't gate `-i` on isatty(0)
the way GNU does, so it never tries to read from stdin and just
short-circuits without overwriting (which is what the test expects). For
027, the Rust impl probably DOES preprocess argv to strip trailing slashes
(matching the LLM's wrong read of the flag semantics), which is exactly
what the test expects but NOT what GNU cp does. So the Rust 100% is a
false positive — bug-compatible with the LLM's misreading, not with GNU.

This is the cleanest example so far of why differential testing against
the real utility is non-negotiable: the LLM-generated tests + LLM-
generated impl are internally consistent but jointly drifted from GNU.

## Compile / runtime failures of the Rust impl

_The Rust impl compiled cleanly._ Cargo check rc=0; one warning about an
unused `Read` import (the impl now imports `IsTerminal` for stdin
detection, evidence the LLM did engage with round 1's `-i` feedback).

## Convergence signal

Round 1 → Round 2 metric delta:

| metric                    | round 1   | round 2   | delta            |
|---------------------------|-----------|-----------|------------------|
| tests on real-gnu         | 26/28     | 26/28     | 0                |
| tests on Rust impl        | 26/28     | 28/28     | +2 (false win)   |
| flag coverage             | 66.67%    | 66.67%    | 0                |
| line coverage on Rust     | 60.0%     | 87.45%    | +27.45pp         |
| Rust compile              | clean     | clean     | 0                |
| total tests in suite      | 28        | 28        | 0                |

Same two real-gnu failures persist across rounds — `--strip-trailing-slashes`
on a symlink and `-i` non-TTY semantics. The LLM **clearly read the
analyst feedback**: tests were renumbered (024→026, 026→027), filenames
encode the suggested fix ("_tty", "_dir_symlink"), and the impl gained an
`IsTerminal` import. But:

  1. The fixes are wrong on different grounds. 024's TTY fix mis-uses
     `script(1)`; 026's dir-symlink fix doesn't account for trailing-slash
     overriding `-P`. The LLM **engaged with the feedback structurally**
     but couldn't execute the underlying fix correctly without a real
     test-execution loop in its planning.

  2. No regressions on real-gnu (26/28 → 26/28), so iteration didn't
     destabilize the working tests. That's a positive control on the
     "doesn't make things worse" axis — within an N=1 trial.

  3. Line coverage jump (60% → 87.45%) is real but driven by the impl
     being more thorough internally, NOT by additional tests covering new
     branches. Test count stayed at 28; flag coverage stayed flat at 24/36.

  4. Rust impl 26→28 is a false signal: the impl coevolved with the wrong
     test expectations.

**Headline finding: the LLM uses the feedback section but its rewrites
inherit the same class of misreading. One iteration is not enough on the
two surviving failure categories — and there's a question of whether
more iteration would converge or just produce alternative wrong fixes.**

## Open questions for next round

_Analyst: list the specific feedback you want surfaced in round 3. The
driver appends the verbatim contents of this file under "Manual analyst
observations" in the next round's prompt._

- A round 3 of `cp` would test whether the LLM can converge on correct
  rewrites given an *even more* targeted hint — e.g. "for 026, drop the
  test entirely and just verify cp accepts the -i flag without arg
  errors; the prompt-decline behavior is documented to require a TTY
  which is out of scope for this test harness." That's beyond this
  task's runtime cap.
- The coverage delta (60% → 87%) is a separate data point: even if test
  fixes fail, the impl-side feedback (`IsTerminal` import) showed the
  LLM updated the impl based on round-1 stderr context. That's
  empirical evidence the iteration loop affects both halves of the
  pipeline.
- One labeler caveat: this analysis is a single-pass categorization
  by one analyst (per `for_aaron.md` §5 option 1). No inter-rater
  agreement reported.
