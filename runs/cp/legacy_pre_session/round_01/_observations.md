# Observations: cp session=legacy_pre_session round=1

## Numbers
- Tests pass on real-gnu: 28/30 (= 93%)
- Tests pass on rust impl: n/a
- Flag coverage: 28/36 flags exercised (= 77.78%)
- Branch/line coverage on Rust impl: compile_failed

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

- **018_strip_trailing_slashes.sh** [<category>] — --strip-trailing-slashes with -P
- **022_interactive_decline_overwrite.sh** [<category>] — -i, --interactive prompt before overwrite

## Impl-correctness failures (tests that passed on real, failed on rust)

_None._

## Compile / runtime failures of the Rust impl

First-line summary of the cargo error: `    Updating crates.io index`

## Open questions for next round

_Analyst: list the specific feedback you want surfaced in round 2. The
driver appends the verbatim contents of this file under "Manual analyst
observations" in the next round's prompt._

- (write here)
