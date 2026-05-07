# sudo — session trajectories summary

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

## 2026-05-07T11-25-03Z

Round-1 baseline. GPT-5.5 (`gpt-5.5-2026-04-23`), reasoning_effort=medium,
no iteration feedback. Cost: ~$0.76 (impl + tests).

| Round | test_real-gnu | test_rust    | flag_cov | line_cov | notes |
|-------|---------------|--------------|----------|----------|-------|
| 01    | 28/29 (97%)   | 28/29 (97%)  | 65.5%    | 69.6%    | 1 test-side: `-D` is policy-gated by sudoers(5), test treats as plain flag. 1 impl-side: rust accepts malformed `--preserve-env=BAD=NAME` instead of rejecting. Container runs as root → many "deny without sudo rule" tests pass trivially. |

What we learned: the central methodology issue for `sudo` is that the
binary is policy-driven and half its truth lives in `sudoers(5)`,
which the LLM never sees. Test 012 (`-D` for chdir) is a clean
example: GNU sudo refuses with `not permitted to use -D with /bin/pwd`
because default sudoers grants no per-command CWD directive. The LLM
read sudo(8)'s `-D` description as a plain flag. This is a structural
incompleteness, not a one-off LLM miss. The trixie container also
runs as root, so any test of "deny without password" or "deny RunAs
other user" passes trivially (root is sudoers-omnipotent), inflating
the visible pass rate. Recommend (for student) deciding before round
2 whether to (a) supplement man-page input with a sudoers excerpt,
(b) add a non-root user + sudoers.d/ to the Dockerfile, or (c) keep
"man page only" as the input contract and accept the ceiling. None of
these were touched in round 1 per task scope; flagged in
`runs/sudo/2026-05-07T11-25-03Z/round_01/_observations.md`.

**Privilege context did not bork the run.** All 29 tests executed and
produced JSONL rows. The container being root is a signal-quality
issue, not a blocker; sudo testing was not "impossible without
container changes" — it was "less informative than it could be".
