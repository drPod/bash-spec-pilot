# mv — session trajectories summary

This file is the per-utility roll-up across all sessions. One section per
session_id, summarizing round-by-round metrics. Stable across sessions —
do not delete entries when a session ends; treat as append-only.

## Schema for each session entry

```
### <session_id>

| Round | test_real-gnu | test_rust | flag_cov | line_cov | notes |
|-------|---------------|-----------|----------|----------|-------|
| 01    | P/T (X%)      | P/T (X%)  | F%       | L%       | one-liner |
| 02    | ...           | ...       | ...      | ...      | what changed |
```

Append a one-paragraph "what we learned" at the end of each session entry.

---

## 2026-05-07T11-11-40Z

Round-1 baseline. GPT-5.5 (`gpt-5.5-2026-04-23`), reasoning_effort=medium,
no iteration feedback. Cost: ~$0.53 (impl + tests).

| Round | test_real-gnu | test_rust    | flag_cov | line_cov | notes |
|-------|---------------|--------------|----------|----------|-------|
| 01    | 24/26 (92%)   | 25/26 (96%)  | 88.9%    | 65.0%    | 2 test-side misreads (`-i` non-tty prompt, `--strip-trailing-slashes` on symlink-to-dir); 1 impl-side wrong-stream bug (`-v` writes to stderr, GNU writes to stdout). |

What we learned: `mv` is the closest of the three to "trivially solvable
from the man page alone". Both surviving test-side misses are subtle
shell/utility-seam issues — `-i` on non-tty stdin and trailing-slash
semantics through a symlink — and they replicate the same shape as
`cp` round-1's failures, suggesting these are LLM-generic rather than
utility-specific. The single rust impl bug is wrong-stream for `-v`,
which is interesting because the man page is silent on stream choice
and the LLM defaulted opposite to coreutils convention.
