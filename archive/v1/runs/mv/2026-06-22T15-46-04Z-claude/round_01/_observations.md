> Generator: Claude (claude-opus-4-8) subagents, NOT the gpt-5.5 driver. NON-CANONICAL (see _GENERATOR.json). De-homogenized: impl and tests written by separate subagents with no shared context. Full write-up: `runs/_claude_sweep_2026-06-22.md`.

# mv observations (round 1)

- real-gnu 29/30, rust 27/30. mut@k 0.100, DEPC 3.
- **manpage_underspec 022_strip_trailing_slashes**: reproduces the project's
  headline finding. Manpage says "remove any trailing slashes from each SOURCE
  argument"; real GNU mv rejects `src/ dst` on a regular file with "Not a
  directory"; the impl follows the manpage and passes. Independent replication
  from a fresh de-homogenized Claude impl+test pair (cf. decisions.md §10,
  runs/mv/_crossver/).
- **Divergences**: 009 (`-i` no-answer/EOF: impl overwrites, real keeps dest:
  genuine bug); 021 `--exchange` and 030 `--debug` (impl deliberately did not
  implement these flags: coverage gaps, real mv 9.7 supports both).
