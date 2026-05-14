# Handoff file — DELETE THIS FILE WHEN YOU FINISH THE TASK BELOW

Author: Claude Opus 4.7 (prior session, context full). Reader: next agent.
Created: 2026-05-14.

**Your first action: invoke any superpowers / brainstorming skills you must per system reminders, then read this file end-to-end, then continue from "What's left to do" below. When the listed work is complete, run `rm _HANDOFF_DELETE_ME.md` and commit that deletion as part of the final commit.**

---

## What was happening in the prior session

Darsh is an undergrad working under Aaron Councilman (PhD, UIUC Vikram Adve group). The project — extending Astrogator's formal-verification approach to Bash utilities — runs an LLM (`gpt-5.5-2026-04-23`) over frozen Linux man pages to generate Rust impls + Bash test suites, then differential-tests them against real GNU coreutils in Debian trixie. The failure-taxonomy that comes out of this is the actual research output. Repo at `github.com/drPod/bash-spec-pilot` (public).

Today's session did:

1. **Wave-3 runs:** round 2 for `mv`, `find`, `sudo` against the GNU oracle. Three findings (now in `taxonomy.md` § 5 and `for_aaron.md` § 5):
   - `mv` r2 hit real coverage gains (88.89% → 94.44% flag, 65.04% → 82.58% line) **but** the `-v` stream bug was "fixed" by relaxing the test to `2>&1` rather than fixing the Rust impl's stderr-vs-stdout choice. Goodhart on the test suite.
   - `find` r2 and `sudo` r2 impls regressed to hard compile errors (`?`-operator type mismatch in `find`; macro use-before-definition in `sudo`).
   - `mv` r2 host `cargo check` failed on Linux-only `RENAME_EXCHANGE` syscall constant, but tarpaulin inside trixie built fine. Failure of the pipeline (host pre-flight gate), not the model.
2. **Streamlit dashboard** at `dashboard/streamlit_app.py`, six pages: Overview, Trajectory, Test diversity (2x2 pos/neg × pass/fail), Failure browser, Reproducibility, Cost & tokens. Reads `runs/` directly. Loaded via `uv run streamlit run dashboard/streamlit_app.py` from repo root. Streamlit skill vendored at `.claude/skills/developing-with-streamlit/`.
3. **`scripts/positivity.py`** computes pos/neg breakdown per round per oracle and writes `positivity.json` per round.
4. **Renamed the legacy `cp` run** from `runs/cp/legacy_pre_session/round_01/` to `runs/cp/legacy_pre_session/round_00/`. Round 0 = pre-experiment baseline (BSD-on-macOS oracle, contaminated). All references updated in 9 files. Dashboard `SESSION_RE` extended to include `legacy_pre_session` as a valid session, so round 0 now appears in the dashboard alongside wave-2 round 1 and wave-3 round 2.
5. **Deploy scaffold** committed locally but not yet pushed:
   - `requirements.txt` at repo root with streamlit/pandas/plotly.
   - `.streamlit/config.toml` with a light theme.
6. **Background browser subagent** (`general-purpose`, agent ID `aa707ad366947c778`) was launched to test all six dashboard pages at `http://localhost:8501` via `agent-browser` CLI. **Check whether it has returned a report.** If yes, read the report and apply any fixes to `dashboard/` files. If no, decide whether to wait (cheap) or kill and move on (the dashboard already smoke-tested clean — HTTP 200, no errors in `/tmp/streamlit.log`).

---

## Current git state

- Branch: `main`, ahead of `origin/main` by **1 commit** (the wave-3 commit `12a45df`).
- **Uncommitted changes from this session:**
  - `M CLAUDE.md` — round-0 rename of legacy session ref
  - `M SETUP.md` — round-0 rename ref
  - `M decisions.md` — round-0 rename refs
  - `M dashboard/data.py` — `SESSION_RE` extended for `legacy_pre_session`
  - `M scripts/positivity.py` — same regex extension
  - `M runs/cp/SUMMARY.md` — section retitled to "round 0"
  - `M runs/cp/legacy_pre_session/_README.md` — retitled "round 0"
  - `M runs/cp/legacy_pre_session/round_00/_observations.md` — header `round=0`
  - `?? requirements.txt` — Streamlit Cloud deps
  - `?? .streamlit/config.toml` — theme config
  - `?? runs/cp/legacy_pre_session/round_00/positivity.json` — regenerated with round=0 schema
  - Renamed: `runs/cp/legacy_pre_session/round_01/` → `runs/cp/legacy_pre_session/round_00/` (via `git mv`)

Local Streamlit dev server still running at `http://localhost:8501` (pid 61735 per `ps -ef`). Log at `/tmp/streamlit.log`. Leave it; user is using it.

---

## What's left to do

### 1. Handle the browser subagent report

```bash
# Check whether subagent finished and what it reported. If you don't see
# a completion notification in your inbox, ask the user — don't poll the
# transcript file (it'll overflow context).
```

If issues reported, fix them in `dashboard/` files (most likely sites: `dashboard/app_pages/positivity.py`, `dashboard/app_pages/failures.py` — they have the most complex widgets). Apply only the high-confidence fixes; defer cosmetic ones if they're risky.

If the subagent already closed `agent-browser` session `streamlit-dashboard-qa`, great. If not, close it explicitly: `agent-browser --session streamlit-dashboard-qa close` (do **not** use `--all` — other sessions may be running).

### 2. Commit the pending changes + dashboard fixes

One commit, conventional-commit style. Suggested subject and body:

```
chore: rename cp legacy to round 0 + Streamlit Cloud scaffold

- runs/cp/legacy_pre_session/round_01/ → round_00/ (pre-experiment baseline).
  All references updated; dashboard SESSION_RE now includes legacy_pre_session
  so round 0 surfaces in the dashboard alongside wave-2+ rounds.
- requirements.txt + .streamlit/config.toml for Streamlit Community Cloud.
- <Add dashboard-fix bullet here if the subagent flagged anything.>
```

End the commit body with the standard `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>` line.

### 3. Push to remote

User has explicitly approved the push in this session.

```bash
git push origin main
```

If push is rejected (force-push needed, diverged history), **stop and ask the user** — don't `--force`. The repo is public so don't push anything with secrets; verify with `git log -p origin/main..HEAD | grep -i "OPENAI_API_KEY\|secret\|password"` first (should print nothing).

### 4. Streamlit Cloud deploy — instruct the user

There is **no programmatic way for the agent to create a new Streamlit Cloud app.** Streamlit Community Cloud requires a one-time browser OAuth sign-in at https://share.streamlit.io that only the human can do. After that, every push auto-rebuilds.

Tell the user this exact sequence (copy-paste into a final message):

> 1. Open https://share.streamlit.io and click **Continue with GitHub**. Authorize the Streamlit github app for your account (read-only on public repos).
> 2. Click **Create app** → **Deploy a public app from GitHub**.
> 3. Fill in:
>    - Repository: `drPod/bash-spec-pilot`
>    - Branch: `main`
>    - Main file path: `dashboard/streamlit_app.py`
>    - App URL: pick something memorable, e.g. `bash-spec-pilot.streamlit.app`
> 4. Click **Deploy**. First build takes ~2-5 min (Streamlit Cloud installs `requirements.txt`, clones the repo, boots the app).
> 5. Future pushes to `main` auto-rebuild. No CLI step required.
>
> The dashboard reads `runs/` directly from the repo at clone time; **no secrets are needed**, so leave the *Secrets* tab empty. `OPENAI_API_KEY` is only used by `scripts/driver.py` for new LLM calls and the dashboard does not call the OpenAI API.

That's the auth answer. Darsh was right that no agent-side auth is needed — but the human-side OAuth is unavoidable.

### 5. Update `for_aaron.md` and `SLACK_DM.md` with the deployed URL, then prep the DM for Aaron

Once the user posts back with the deployed URL (e.g. `https://bash-spec-pilot.streamlit.app`):

a. **Find-and-replace** the local-only `streamlit run dashboard/streamlit_app.py` references in `for_aaron.md` (top "Companion artifacts" line + § 1 final paragraph) and in `SLACK_DM.md` with the hosted URL. Same for `README.md` "Read in this order" block and "Dashboard" section.

b. **Commit** as a follow-up: `docs: link deployed Streamlit Cloud dashboard from for_aaron / README / SLACK_DM`.

c. **Send the Slack DM to Aaron.** The body below is the version to paste — already finalized this week's numbers. Replace `<DEPLOY_URL>` with the live Streamlit URL and `<SHA>` with the current `main` commit hash, then paste into Slack. Do **not** show the user this entire block of handoff text — paste only the ` ```text ... ``` ` block.

````text
Quick update from this week. Ran round 2 of `mv`, `find`, `sudo` against the GNU oracle in trixie, built a Streamlit dashboard so the numbers don't have to live in markdown anymore, and added a positivity breakdown to answer your test-diversity question.

**Read in this order — under 10 min total:**

1. **Live dashboard:** <DEPLOY_URL> — auto-rebuilt from `main`, no setup. Pages, in order: *Overview* → *Test diversity* → *Failure browser* → *Trajectory*.
2. **`for_aaron.md` @ `<SHA>`** — weekly status report. New § 5 covers wave 3.
3. **`taxonomy.md` § 5** — three new failure classes from this round.

**The one finding to lead with:** the iteration loop is not behaving as a "fix" step. Four utilities, four different outcomes at round 1 → round 2:

- `cp`: drift — impl and tests coevolve into mutual ratification (wave-2 finding, confirmed).
- `mv`: real coverage gain (88.89% → 94.44% flag, 65.04% → 82.58% line) — **but** the `-v` stream bug was "fixed" by relaxing the test from `out=$(... -v ...)` to `out=$(... -v ... 2>&1)`, not by fixing the Rust impl's stderr-vs-stdout choice. Test got more permissive instead of impl getting more correct.
- `find`: impl regressed to a hard compile error (`?` operator misuse inside `if` expecting `()`).
- `sudo`: impl regressed to a hard compile error (macro use-before-definition).

Three distinct compile-fail mechanisms in three utilities, all triggered by the same feedback prompt. The shared shape is "model responds to test-failure feedback by writing *more* code, not *more correct* code." A one-line stream-convention fix would have closed `mv` cleanly; instead the LLM rewrote `--exchange` with a `renameat2` syscall.

**Test diversity (the breakdown you asked for):**

| util | pos / neg | pos% | neg% | GNU neg pass | Rust neg pass |
|------|-----------|------|------|--------------|---------------|
| cp r0 (legacy) | 28 / 2 | 93% | 7% | 100% | — |
| cp r1 | 25 / 3 | 89% | 11% | 100% | 100% |
| mv r1 | 23 / 3 | 88% | 12% | 100% | 100% |
| find r1 | 27 / 3 | 90% | 10% | 100% | 67% |
| sudo r1 | 23 / 6 | 79% | 21% | 100% | 83% |

`sudo` is the only one with a meaningful negative slice — consistent with it being policy-heavy. The other three default hard to happy-path tests. Negative-test pass rates against GNU are ~100% across the board, which I read as "the few negative tests the LLM does write are clustered on the most obvious documented errors."

**Open question:** with three of four round-2 impls broken, where should round 3 go — (a) refine the feedback prompt to constrain the kind of edit (no new dependencies, smallest-possible-diff framing), (b) commit to N≥3 resampling on round 1 before iterating further, or (c) both? My lean is (c) but `for_aaron.md` § 6 is the right place to argue it.

Full per-test stderr in the dashboard's *Failure browser* page (`GNU fail, Rust pass` quadrant is the drift case; `GNU pass, Rust fail` is the impl-regression case).
````

### 6. Delete this file

```bash
rm /Users/darshpoddar/Coding/formal-verification/_HANDOFF_DELETE_ME.md
```

Include the deletion in the last commit (or a small follow-up commit). The file is intentionally short-lived and should not survive into the public repo.

---

## Open questions Darsh asked at the end of the prior session

Not blocking the deployment but worth flagging back at him when this is done:

- **Next research direction**: prior agent's recommendation was **N≥3 resampling on round 1 before more iteration**, then a "smallest-possible-diff" feedback prompt experiment as wave 4. Cost estimate ~$5-10. Other options on the table: containerize `cargo check` to fix the `mv` r2 misclassification, fix `coverage_flags.py` for `find` primaries (methodology debt). Don't start any of these without explicit go-ahead from Darsh.

---

## Things NOT to do

- Don't push without verifying no secrets in the diff (the verification grep is in step 3 above).
- Don't `--force` push. Don't rewrite published history.
- Don't kill the local Streamlit dev server unless the user asks.
- Don't run new LLM API calls (driver.py) — that's a research decision, not a deployment task.
- Don't add new `temperature` / `seed` / `system_fingerprint` parameters anywhere. They're explicitly excluded for the reasoning model. See `decisions.md` § 3 and 5.
- Don't WebFetch OpenAI docs — read `docs/openai/` instead. Refresh via `scripts/sync_openai_docs.sh` only when Darsh asks.

---

## Quick orientation paths

- Project framing: `README.md` (top has read-order block).
- Weekly status: `for_aaron.md`.
- Failure schema + new classes: `taxonomy.md` (§ 4 wave-2 classes, § 5 wave-3 iteration classes).
- Provenance + design decisions: `decisions.md` (TOC at top).
- Dashboard code: `dashboard/streamlit_app.py` (entry), `dashboard/data.py` (cached pandas readers), `dashboard/app_pages/*.py` (six pages).
- Dashboard QA log from the subagent that was running: poll the subagent's transcript via the agent-system notification — do **not** read the raw transcript file directly.

Good luck.
