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

Wave 3 done. Ran round 2 of `mv`/`find`/`sudo` vs GNU trixie. Deployed dashboard. Positivity breakdown attached.

**Read order (~10 min):**

1. Dashboard: https://bash-spec-pilot.streamlit.app/ — auto-rebuilds from `main`. Pages: *Overview → Test diversity → Failure browser → Trajectory*.
2. `for_aaron.md` § 5: https://github.com/drPod/bash-spec-pilot/blob/7b83674/for_aaron.md
3. `taxonomy.md` § 5: https://github.com/drPod/bash-spec-pilot/blob/7b83674/taxonomy.md#5-iteration-loop-failure-classes-2026-05-14

**Headline: iteration loop ≠ "fix" step.** Four utils, four r1→r2 outcomes:

- `cp`: drift (impl+tests mutual-ratify, miss GNU). Wave-2 finding confirmed.
- `mv`: flag cov 88.89→94.44%, line cov 65.04→82.58%. **But** `-v` stream bug "fixed" by relaxing test `out=$(... -v ...)` → `out=$(... -v ... 2>&1)`. Test got permissive, impl unchanged.
- `find`: impl compile-fail. `?`-operator in `if` expecting `()`.
- `sudo`: impl compile-fail. Macro use-before-def.

Three compile-fail mechanisms, one feedback prompt. Shape: **model responds to test failures by writing *more* code, not *more correct* code.** `mv -v` needed one-line stream fix; LLM rewrote `--exchange` with `renameat2` instead.

**Pos/neg breakdown (your diversity ask):**

| util | pos / neg | pos% | neg% | GNU neg pass | Rust neg pass |
|------|-----------|------|------|--------------|---------------|
| `cp` r0 (legacy) | 28 / 2 | 93% | 7% | 100% | — |
| `cp` r1 | 25 / 3 | 89% | 11% | 100% | 100% |
| `mv` r1 | 23 / 3 | 88% | 12% | 100% | 100% |
| `find` r1 | 27 / 3 | 90% | 10% | 100% | 67% |
| `sudo` r1 | 23 / 6 | 79% | 21% | 100% | 83% |

`sudo` only util with meaningful negative slice (policy-heavy, makes sense). Rest = happy-path heavy. Negative-test GNU pass ~100% across board — LLM writes neg tests only for obvious documented errors.

**Open Q:** three of four r2 impls broken. Round 3 priority: (a) tighter feedback prompt (smallest-possible-diff, no new deps), (b) N≥3 resampling first to get variance bars, (c) both. Lean (c). Arg in `for_aaron.md` § 6.

Per-test stderr in dashboard *Failure browser* (`GNU fail, Rust pass` = drift; `GNU pass, Rust fail` = impl regression).

---

## Notes for future updates

- Dashboard URL: https://bash-spec-pilot.streamlit.app/ (Streamlit Community Cloud, auto-rebuilds from `main`). Local fallback: `uv run streamlit run dashboard/streamlit_app.py`.
- Update the `for_aaron.md` and `taxonomy.md` github permalink SHA to the current `main` commit hash before sending. Get it via `git rev-parse main`.
- Keep this Slack DM ≤ 300 words excluding the table. Anything longer belongs in `for_aaron.md`.
- Lead with the one most-surprising finding of the week. Don't bury it under methodology.
- Numbers in the table should match the dashboard's *Test diversity* page at the moment of sending. Regenerate via `uv run python scripts/positivity.py` first.
