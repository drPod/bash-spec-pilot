# Observations: sudo session=2026-05-07T11-25-03Z round=1

## Numbers
- Tests pass on real-gnu: 28/29 (= 97%)
- Tests pass on rust impl: 28/29 (= 97%)
- Flag coverage: 19/29 flags exercised (= 65.52%)
- Branch/line coverage on Rust impl: 69.63% (298/428 lines)

## Container context (read this first)

The trixie container runs as **root** (`docker/Dockerfile` does not add a non-root test user). All 29 sudo tests therefore run as uid=0. Default `/etc/sudoers` contains `Defaults env_reset`, `Defaults mail_badpass`, `Defaults secure_path=...`, `Defaults use_pty`, and the standard `root ALL=(ALL:ALL) ALL` and `%sudo ALL=(ALL:ALL) ALL` rules. The LLM had no knowledge of any of this when it wrote the tests; tests assume "the user running this is permitted to run any command via sudo". That happens to be true (root is permitted) so no test was bricked by privilege, but several tests are **not actually exercising what they claim**:

- "Refuses without password" tests under `-n` mostly pass trivially because root needs no auth anyway.
- "Refuses to run as user X" tests pass because root is allowed to switch to any user.

The 28/29 real-gnu pass rate is therefore an upper bound on the test suite's true informativeness in a more realistic non-root harness. The student should consider whether to add a non-root test user to the Dockerfile in a future round; the trade-off is per-round complexity (sudoers.d/ provisioning, password-cache resets) versus signal quality. This round flags the issue and proceeds.

## Test-correctness failures (tests that failed on the real utility)

- **012_chdir_directory.sh** [Misinterpretation; TEST-MAN-PAGE-MISREAD] — `-D directory` runs the command in `directory`. Test calls `sudo -n -D "$work" /bin/pwd` and expects exit 0 with stdout = `$work`. Real GNU `sudo` rejects with `sudo: you are not permitted to use the -D option with /bin/pwd`. The man page says `-D directory` but **also** says that `-D` is constrained by the `runchroot=` and `runcwd=` settings in `sudoers(5)`, which by default disallow CWD changes per-command. The default trixie sudoers grants no `CWD=` directive for root invoking `/bin/pwd`, so `-D` is policy-rejected even when the user is omnipotent. The LLM read the manpage description of `-D` as a plain flag and missed the sudoers-policy gate. Documented error case **not** explicitly written in `sudo(8)` — it's only resolvable by reading `sudoers(5)` cross-reference. **Expected miss for a man-page-only LLM, but it's a test-side bug, not an impl-side one** (the rust impl just runs `chdir`, accepting the flag — it would also fail on real-policy harnesses, just not visibly at the rust layer).

## Impl-correctness failures (tests that passed on real, failed on rust)

- **028_invalid_preserve_env_name_error.sh** [Hallucinated Object / Misinterpretation; IMPL-WRONG-SEMANTICS] — `--preserve-env=BAD=NAME` (note the `=` inside the value, which is invalid because env-var names cannot contain `=`). Real GNU `sudo` rejects: `--preserve-env` takes a comma-separated list of environment variable **names**; an `=` indicates the user confused it with `--env=K=V`. The Rust impl accepts the malformed name silently and exits 0. Wrong-semantics on validation of a documented flag. The man page says "var" not "var=value" for the `--preserve-env` argument, but doesn't loudly flag what counts as a valid var name. The LLM impl skipped argument validation; `gnu sudo` does the right thing.

## Compile / runtime failures of the Rust impl

The Rust impl compiled cleanly inside the trixie container. (One `unused_variable` warning, no errors.)

## Notes on the experiment

- **Sudoers context** is the central methodology issue here, not a one-off bug. `sudo`'s behavior is policy-driven; the man page describes the binary's argument semantics but most "documented behaviors" are gated by `sudoers(5)`. A faithful LLM-from-man-page test of `sudo` is unavoidably incomplete because half the truth lives in another file. The taxonomy entry for sudo round-1 should record: "manpage-alone is structurally insufficient for this utility — needs sudoers(5) supplement or a sudoers-aware test harness."
- **Privileged-flag pattern:** `-D` in test 012 is the canonical example of "documented in sudo(8), gated by sudoers(5)". Other flags with the same shape: `-u` (RunAs= rule), `-g` (RunAs=:GROUP), `-i`/`-s` (RunAs+Defaults), `-A` (askpass program path Defaults), `-T` (Defaults timestamp_timeout). The LLM tested several of these and got pass results only because root is policy-omnipotent; in a non-root harness more would fail.
- **No infrastructure changes were made.** Per the task brief, the Dockerfile was not modified. The `_observations.md` flags the gap; the analyst (student) decides whether the next round's prompt should include sudoers context, or whether the Dockerfile should add a non-root user.

## Open questions for next round

- Add `sudoers(5)` to the LLM context for sudo-class utilities? Or keep "man page only" as the experiment's input contract and accept the ceiling on what `sudo` round 1 can show? Materials-completeness vs. methodology-purity trade-off.
- Add a non-root test user to `docker/Dockerfile` (with a known-password sudoers.d/ entry) so that "deny without password" and "deny RunAs other user" tests carry signal? Would change every prior `sudo` round's results — needs explicit decision before round 2.
- Argument-validation strictness in the impl: the rust impl is permissive (accept `--preserve-env=BAD=NAME`, accept malformed `-u UID`, etc.). Does the test prompt need to ask for more aggressive error-case coverage? Currently the LLM tests happy-path heavily and error-path lightly.
