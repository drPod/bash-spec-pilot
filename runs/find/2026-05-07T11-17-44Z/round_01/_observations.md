# Observations: find session=2026-05-07T11-17-44Z round=1

## Numbers
- Tests pass on real-gnu: 30/30 (= 100%)
- Tests pass on rust impl: 29/30 (= 97%)
- Flag coverage: 6/10 short flags exercised (= 60.0%) — note `coverage_flags.py` only counts single-letter flags, so the bulk of `find`'s surface (its "primaries" like `-name`, `-type`, `-exec`, `-files0-from`, etc.) is invisible to this metric. The 30 tests do exercise a wide subset of primaries; the 60% number is misleadingly low. Flag-coverage methodology debt for `find` specifically — flagged for next round.
- Branch/line coverage on Rust impl: 75.84% (135/178 lines)

## Test-correctness failures (tests that failed on the real utility)

_None._ All 30 tests are faithful readings of the man page that GNU `find` honors.

## Impl-correctness failures (tests that passed on real, failed on rust)

- **030_files0_from_empty_name_errors.sh** [Misinterpretation; IMPL-WRONG-SEMANTICS] — `-files0-from` with a zero-length filename. The man page documents: "Filenames read are not permitted to be empty (zero-length)." GNU `find` exits nonzero with `invalid zero-length file name in input file` when a `\0`-only line is encountered. The Rust impl reads `-files0-from`, splits on `\0`, and does `if part.is_empty() { continue; }` — silently skipping the empty entry rather than raising. The LLM read the documented restriction but coded "skip" instead of "error". Wrong-semantics on a documented error case. Compare to a related test that did pass: `029_files0_from_with_path_errors.sh` (the same primary's "incompatible with command-line paths" rule) where the impl did raise correctly. So the LLM understood part of the `-files0-from` semantics and missed part — partial reading of an error-case bullet list.

## Compile / runtime failures of the Rust impl

The Rust impl compiled cleanly inside the trixie container.

## Notes on the experiment, not the model

- **Manpage size:** find's manpage is 1931 lines / 90,749 bytes after `mandoc` rendering. Input tokens for `impl` were 20,116 and for `tests` were 20,649 — well under any practical context limit on `gpt-5.5-2026-04-23`. Output tokens for `impl` were 12,285 (under the 16,000 default cap) and for `tests` 10,403. **No `OPENAI_MAX_OUTPUT_TOKENS` bump was needed.** The pre-task warning that the response might saturate did not materialize at reasoning_effort=medium.
- **Implementation scope:** The impl is 272 LOC, deliberately small. The `_deps_rationale.txt` says: "intentionally simplifying locale/SELinux/xattrs/sparse handling and some exact GNU formatting details." That explains why 178 instrumented lines is so much smaller than `mv` (369). The LLM made a defensible scope-cut and the test suite mostly stayed inside that scope, hence 29/30. Tests of unimplemented primaries (e.g. `-printf %T@`) would have produced more impl-side failures — a future-round prompt could ask for more aggressive primary coverage.
- **Tests stayed conservative:** 30 tests, almost all on documented happy-path semantics with 2-3 directory entries. None exercise the more interesting features (`-fstype`, `-printf` advanced format specifiers, `-newerXY` time comparisons, `-{a,c,m}min`, regex backreferences). The LLM appears to have used its "test budget" on breadth-of-primaries rather than depth-of-flag — that's a property of the tests prompt to interrogate.

## Open questions for next round

- `coverage_flags.py` should be extended (or supplemented) to count `find` primaries, not only short flags. Currently it scans for `-[a-z]` style tokens and misses the entire primary surface that defines `find`'s semantics.
- Should the prompt explicitly ask the LLM to test documented error cases (one per primary)? The single rust-side failure was on a documented error, and the man page lists many such conditions that went un-tested.
- The `extra_used_not_documented` set in coverage_flags includes `-c -e -p -s -v` — these are almost certainly false positives from the metric (it's parsing `tests/*.sh` and finding tokens like `cp -p` or `mkdir -p` in setup code). Methodology bug.
