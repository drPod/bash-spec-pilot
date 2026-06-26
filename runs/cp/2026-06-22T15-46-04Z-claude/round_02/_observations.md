> Generator: Claude (claude-opus-4-8) subagents, NOT the gpt-5.5 driver. NON-CANONICAL (_GENERATOR.json). Mode: wave-4 cold-adversarial (test author saw manpage only; impl reused from round_01). Round-02 summary: runs/_claude_round2_adversarial_2026-06-26.md.

# cp observations (round 2, cold-adversarial)

- 22 tests. real-gnu 21/22, rust 22/22. buckets: baseline 21, manpage_underspec 1.
- **CONFIRMED man-page defect, 018_strip_trailing_slashes_source**: `cp
  --strip-trailing-slashes file.txt/ out` fails `Not a directory` (regular-file
  source), identical with/without the flag; man page says the flag removes
  trailing slashes from each SOURCE, unconditionally. This is the headline mv
  defect generalizing to cp (byte-identical man-page wording). Hardened against
  real binary + POSIX (basedefs/04:412) + version. See `_hardening/`.
- No impl-side divergences this round (rust 22/22): the round_01 cp impl handles
  every documented behavior the adversarial suite probed.
