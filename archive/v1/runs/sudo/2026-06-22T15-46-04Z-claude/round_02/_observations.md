> Generator: Claude (claude-opus-4-8) subagents, NOT the gpt-5.5 driver. NON-CANONICAL (_GENERATOR.json). Mode: wave-4 cold-adversarial (test author saw manpage only; impl reused from round_01). Round-02 summary: runs/_claude_round2_adversarial_2026-06-26.md.

# sudo observations (round 2, cold-adversarial)

- 18 tests. real-gnu 18/18, rust 13/18. buckets: baseline 13, divergence 5,
  manpage_underspec 0.
- **Methodology guard worked: zero false manpage_underspec** (vs round_01's two:
  -D and -s). The cold author was told to quote the full governing span incl.
  hedges; it scoped -D to assert only the duplicate-rejection, not the
  policy-gated success. Real sudo passed all 18 documented behaviors (18/18).
- **5 divergences = documented option-errors the round_01 rust impl does not
  enforce** (all real-correct, rust-wrong): 001 `-K` with a command, 002 `-K`
  with another option, 004 duplicate `-u`, 006 `-u`+`--user` same option
  twice, 018 duplicate `-D`. Real sudo rejects each with a usage error; the impl
  accepts them. Impl bugs, not man-page issues.
