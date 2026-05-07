# find — session trajectories summary

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

## 2026-05-07T11-17-44Z

Round-1 baseline. GPT-5.5 (`gpt-5.5-2026-04-23`), reasoning_effort=medium,
no iteration feedback. Cost: ~$0.88 (impl + tests).

| Round | test_real-gnu | test_rust    | flag_cov | line_cov | notes |
|-------|---------------|--------------|----------|----------|-------|
| 01    | 30/30 (100%)  | 29/30 (97%)  | 60.0%    | 75.8%    | All 30 tests are faithful man-page readings. 1 impl bug: `-files0-from` with zero-length entry silently skips instead of erroring. Flag-cov is misleading — counts only short flags, ignores `find` primaries. |

What we learned: the headline result of "100% on the real oracle" is
genuine but partly an artifact of conservative test-suite scope. The
LLM wrote 30 tests across happy-path primaries (`-name`, `-type`,
`-maxdepth`, `-prune`, `-print0`, `-files0-from`, `-exec`) and
deliberately did not stress-test depth (no advanced `-printf` format
specifiers, no `-newerXY`, no regex backreferences). The single
impl-side miss is a documented-error case the LLM half-implemented
(`-files0-from` correctly rejects "incompatible with command-line
paths" but silently accepts "zero-length filename"). Important
methodology note: `coverage_flags.py` reports 60% but doesn't
understand `find` primaries — that metric needs a `find`-specific
adapter before it's comparable to cp/mv numbers.

**Token usage note:** input tokens for impl+tests totaled 40,765 — the
prompt did NOT need an `OPENAI_MAX_OUTPUT_TOKENS` bump above the
default 16,000 at reasoning_effort=medium. The pre-task warning that
`find` would saturate context did not materialize.
