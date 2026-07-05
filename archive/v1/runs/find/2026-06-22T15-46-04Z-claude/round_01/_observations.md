> Generator: Claude (claude-opus-4-8) subagents, NOT the gpt-5.5 driver. NON-CANONICAL (see _GENERATOR.json). De-homogenized: impl and tests written by separate subagents with no shared context. Full write-up: `runs/_claude_sweep_2026-06-22.md`.

# find observations (round 1)

- real-gnu 30/30, rust 29/30. mut@k 0.033, DEPC 1.
- **Divergence 019_delete_removes_file**: impl did not implement `-delete`
  (`unknown predicate '-delete'`); real find supports it. Coverage gap, not a
  spec defect.
- No manpage/binary disagreement surfaced for find. The cold author flagged
  -path slash-spanning globs (027), basename-only -name (003), and -print0
  trailing-byte behavior (012) as likely divergence points; all landed baseline,
  so the impl handled the documented semantics correctly.
