> Generator: Claude (claude-opus-4-8) subagents, NOT the gpt-5.5 driver. NON-CANONICAL (see _GENERATOR.json). De-homogenized: impl and tests written by separate subagents with no shared context. Full write-up: `runs/_claude_sweep_2026-06-22.md`.

# cp observations (round 1)

- real-gnu 30/30, rust 29/30. mut@k 0.033, DEPC 1. All baseline except one impl bug.
- **Divergence 025_force_backup_same_name**: `-f --backup` when SOURCE and DEST
  are the same existing regular file. Real cp exits 0; the Rust impl errors
  `No such file or directory` (it backs up then loses the source path). Genuine
  impl edge-case bug.
- No manpage/binary disagreement surfaced for cp this run. The cold test author
  flagged 021 (`--strip-trailing-slashes` on a file source) and 026 (`-f` on an
  unwritable dest) as suspected divergences, but both landed baseline here.
