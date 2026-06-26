> Generator: Claude (claude-opus-4-8) subagents, NOT the gpt-5.5 driver. NON-CANONICAL (_GENERATOR.json). Mode: wave-4 cold-adversarial (test author saw manpage only; impl reused from round_01). Round-02 summary: runs/_claude_round2_adversarial_2026-06-26.md.

# find observations (round 2, cold-adversarial)

- 22 tests. real-gnu 21/22, rust 20/22. buckets: baseline 20, divergence 1,
  shared_bug 1, manpage_underspec 0.
- **No new man-page defect.** The cold author's strongest hypotheses (leading-dot
  glob match per POSIX interp 126, `-size` round-up, `-a`/`-o` precedence,
  default `-print` inhibition) all held against the real binary: the find man
  page is accurate on these points.
- **divergence 014_explicit_action_suppresses_default_print**: impl bug, not a
  spec issue. rust errors `unknown predicate '-fprint'` (rc=2); the round_01
  find impl never implemented `-fprint`. Documented behavior; impl gap.
- 1 shared_bug: test-design artifact (both targets fail).
