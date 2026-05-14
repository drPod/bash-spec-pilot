<!--
Weekly Slack DM template to Aaron.

Send the rendered "Draft (paste into Slack)" section below. Update the SHA
and the wave-N numbers before each weekly send. This file lives in the repo
so future weeks can diff against the previous draft and surface what
genuinely changed.

NEVER paste this whole file. Paste just the "Draft (paste into Slack)"
block, top to bottom.
-->

# Slack DM template — weekly update to Aaron

The DM is intentionally short. Depth goes in the dashboard and `for_aaron.md`.

---

## Draft (paste into Slack)

Quick update from this week. Ran round 2 of `mv`, `find`, `sudo` against the GNU oracle in trixie, built a Streamlit dashboard so the numbers don't have to live in markdown anymore, and added a positivity breakdown to answer your test-diversity question.

**Read in this order — under 10 min total:**

1. **Dashboard** (live, reads `runs/` directly):
   ```
   git pull && uv run streamlit run dashboard/streamlit_app.py
   ```
   Pages, in order: *Overview* → *Test diversity* → *Failure browser* → *Trajectory*.
2. **[`for_aaron.md`](https://github.com/) @ `<SHA>`** — weekly status report. New § 5 covers wave 3.
3. **[`taxonomy.md`](https://github.com/) § 5** — three new failure classes from this round.

**The one finding to lead with:** the iteration loop is not behaving as a "fix" step. Four utilities, four different outcomes at round 1 → round 2:

- `cp`: drift — impl and tests coevolve into mutual ratification (wave-2 finding, confirmed).
- `mv`: real coverage gain (88.89% → 94.44% flag, 65.04% → 82.58% line) — **but** the `-v` stream bug was "fixed" by relaxing the test from `out=$(... -v ...)` to `out=$(... -v ... 2>&1)`, not by fixing the Rust impl's stderr-vs-stdout choice. Test got more permissive instead of impl getting more correct.
- `find`: impl regressed to a hard compile error (`?` operator misuse inside `if` expecting `()`).
- `sudo`: impl regressed to a hard compile error (macro use-before-definition).

Three distinct compile-fail mechanisms in three utilities, all triggered by the same feedback prompt. The shared shape is "model responds to test-failure feedback by writing *more* code, not *more correct* code." A one-line stream-convention fix would have closed `mv` cleanly; instead the LLM rewrote `--exchange` with a `renameat2` syscall.

**Test diversity (the breakdown you asked for):**

| util | pos / neg | pos% | neg% | GNU neg pass | Rust neg pass |
|------|-----------|------|------|--------------|---------------|
| `cp` r1 | 25 / 3 | 89% | 11% | 100% | 100% |
| `mv` r1 | 23 / 3 | 88% | 12% | 100% | 100% |
| `find` r1 | 27 / 3 | 90% | 10% | 100% | 67% |
| `sudo` r1 | 23 / 6 | 79% | 21% | 100% | 83% |

`sudo` is the only one with a meaningful negative slice — consistent with it being policy-heavy. The other three default hard to happy-path tests. Negative-test pass rates against GNU are ~100% across the board, which I read as "the few negative tests the LLM does write are clustered on the most obvious documented errors."

**Open question:** with three of four round-2 impls broken, where should round 3 go — (a) refine the feedback prompt to constrain the kind of edit (no new dependencies, smallest-possible-diff framing), (b) commit to N≥3 resampling on round 1 before iterating further, or (c) both? My lean is (c) but `<for_aaron.md § 6>` is the right place to argue it.

Full per-test stderr in the dashboard's *Failure browser* page (`GNU fail, Rust pass` quadrant is the drift case; `GNU pass, Rust fail` is the impl-regression case).

---

## Notes for future updates

- Dashboard URL: `http://localhost:8501` after `streamlit run dashboard/streamlit_app.py`. Not hosted yet — local-only by design while data is still N=1. If hosting becomes useful later, Streamlit Community Cloud is free and matches a public repo branch.
- Replace `<SHA>` with the current `main` commit hash before sending.
- Keep this Slack DM ≤ 300 words excluding the table. Anything longer belongs in `for_aaron.md`.
- Lead with the one most-surprising finding of the week. Don't bury it under methodology.
- Numbers in the table should match the dashboard's *Test diversity* page at the moment of sending. Regenerate via `uv run python scripts/positivity.py` first.
