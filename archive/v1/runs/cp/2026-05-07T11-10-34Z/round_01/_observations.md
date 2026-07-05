# Observations: cp session=2026-05-07T11-10-34Z round=1

## Numbers
- Tests pass on real-gnu: 26/28 (= 93%)
- Tests pass on rust impl: 26/28 (= 93%)
- Flag coverage: 24/36 flags exercised (= 66.67%)
- Branch/line coverage on Rust impl: 60.0%

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

- **024_interactive_i_decline.sh** [misread edge case] — -i/--interactive prompt
  before overwrite. The test pipes `printf 'n\n' | "$UTIL" -i src dst`. GNU
  `cp -i` only emits the prompt and reads a response when stdin is attached
  to a TTY. With a piped stdin, GNU `cp` does not prompt; instead it falls
  back to the underlying `unlink + open` semantics, which here proceed and
  overwrite the destination. The man page is silent about this isatty(0)
  guard, so the LLM-generated test reads `-i` as "always prompts," which is
  wrong. Same surviving failure category as legacy round-1 test 022.
  Equivalent stderr: `cp -i failed`, exit 1.

- **026_strip_trailing_slashes.sh** [infrastructure] — --strip-trailing-slashes.
  The test creates `link.txt` as a symlink to `target.txt` and then invokes
  `"$UTIL" --strip-trailing-slashes "$link/" "$dst"`. Bash's argument
  expansion / kernel pathname resolution dereferences `link.txt/` before cp
  ever runs (a trailing slash on a symlink is a request to follow), and
  since `target.txt` is a regular file (not a directory), `stat()` returns
  `ENOTDIR`. cp's `--strip-trailing-slashes` flag was meant to be exercised,
  but the trailing slash is consumed at the shell/syscall layer first. This
  is a test-construction bug, not an LLM misreading of the man page. Same
  failure as legacy round-1 test 018.
  Equivalent stderr: `cp: cannot stat '.../link.txt/': Not a directory`.

## Impl-correctness failures (tests that passed on real, failed on rust)

_None._ Both failures above ALSO fail on the Rust impl, with identical
stderr. That's a coincidence of test brokenness rather than the Rust impl
matching real GNU behavior — the failures happen at the bash/syscall layer
before the binary's argv reaches argv[1].

## Compile / runtime failures of the Rust impl

_The Rust impl compiled cleanly._ Cargo check pre-flight gate (item D in
driver.py) returned rc=0. The legacy session E0515 lifetime error did not
recur on this fresh run; lifetime semantics in the new impl are sound.

## Open questions for next round

_Analyst: list the specific feedback you want surfaced in round 2. The
driver appends the verbatim contents of this file under "Manual analyst
observations" in the next round's prompt._

- The two failures above are NOT LLM man-page-reading errors. Test 026 is
  a shell-level bug; test 024 is the LLM not knowing about an undocumented
  isatty(0) precondition for `-i`. Round 2 should rewrite these tests:
    - 024: `script -qc 'printf "n\n"; cp -i src dst' /dev/null` to fake a
      TTY, OR drop the test to "verify cp -i exists and accepts the flag"
      since the prompt-decline semantic isn't testable from a piped stdin.
    - 026: pass a directory-symlink (`ln -s dir/ link`) instead of a
      file-symlink so the trailing slash is meaningful at syscall time.
  These rewrites are within scope: each tests `--strip-trailing-slashes`
  and `-i` against the documented man-page surface, just with shell
  plumbing that doesn't pre-empt the flag.
- Do NOT regress the 26 passing tests. Keep flag coverage >= 24/36.
- Coverage on src/main.rs is only 60% (12/20 lines). The 8 uncovered lines
  are likely error-path branches not exercised by the current suite.
  Round 2 could add tests targeting those, e.g. permission errors,
  missing-source errors, conflicting flags. Caveat: harder to verify
  without inspecting the impl source, which the LLM never sees.
