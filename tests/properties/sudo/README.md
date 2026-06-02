# Wave-4 metamorphic floor — `sudo`

Hand-curated metamorphic / property-based invariants for GNU `sudo`. No
LLM authorship. Companion control group for the wave-4 adversarial test
generation rollout: if the LLM-authored adversarial tests under
`runs/sudo/...` fail to surface bugs that these hand-written invariants
catch, the homogenization-trap hypothesis is supported.

All tests assume:
- They are invoked through `$UTIL=sudo`, per repo convention.
- A non-root invoking user with a `NOPASSWD: ALL` sudoers entry, e.g.
  `tester ALL=(ALL) NOPASSWD: ALL`. `ALL` (not a per-command allowlist) is
  required because:
  - test 003 runs `sudo -n -E env`; `-E`/`--preserve-env` is policy-gated and
    needs the `SETENV` permission, which sudoers implies for a command matched
    by `ALL`. A bare `NOPASSWD: true,id,env,bash` allowlist would reject `-E`
    with "sorry, you are not allowed to preserve the environment".
  - tests 001/005 run `sudo -u root ...`/`-i`, which need RunAs permission;
    `(ALL)` in the rule grants it.
- `env_reset` is enabled (the Debian default) and `SUDO_TEST_VAR` is not in
  `env_keep`/`env_check`. Tests 003/004 depend on this default-scrub behavior.

This exact setup is created by the canonical runner — see "How to run" below.

Pass criterion: every script exits 0 against real `sudo` in trixie.
A failure means either the invariant over-specifies behavior the
manpage does not guarantee (fix or drop), or the manpage and the real
utility disagree (record under the appropriate Astrogator decomposition
cell in `docs/research/taxonomy.md`).

## Invariants

### 001 — User-propagation identity
Asserts `sudo -u root id -un` prints `root`. Verifies that `-u` actually
switches the effective identity end-to-end through `id`. Backed by
manpage lines 348-357 (`-u user`: run command as a user other than the
default target user). Bug class it would surface: **Misinterpretation**
(Tambon §4.1.1 #1) if Rust impl forwards `-u` but does not change UID,
or **Hallucinated Object** (#7) if the impl drops `-u` entirely.

### 002 — Passwordless sanity
Asserts `sudo -n true` exits 0 under a `NOPASSWD: ALL` sudoers entry.
Provides a floor: the simplest possible sudo invocation must succeed.
Backed by manpage lines 30-50 (sudo propagates the command's exit
status) plus lines 261-264 (`-n` makes the password-required path fail
fast instead of hang). Bug class: **Missing Corner Case** (#5) if the
impl misroutes exit code on the trivial path, or **Incomplete
Generation** (#9) if the impl truncates before reaching exec.

### 003 — `-E` preserves arbitrary parent env var
Asserts `sudo -E env` contains `SUDO_TEST_VAR=<value>` when that var is
exported in the parent. Backed by manpage lines 100-104 (`-E,
--preserve-env`: preserve existing environment variables). Bug class:
**Misinterpretation** (#1) if `-E` is parsed but not wired to the env
filter, or **Wrong Attribute** (#8) if the impl confuses `-E` with
`--preserve-env=<list>` and requires a list argument.

### 004 — Default-scrub without `-E`
Asserts `sudo env` (no `-E`) does NOT contain `SUDO_TEST_VAR`. This is
the contrapositive of 003: `-E` only matters if the default behavior
actually scrubs. This is a harness assumption, not a manpage guarantee:
`-E` is policy-gated, so a policy could in principle choose not to scrub.
The assumption holds here because the runner uses the Debian default
`env_reset` with `SUDO_TEST_VAR` absent from `env_keep`/`env_check` (the
ENVIRONMENT section, manpage lines 553-575, enumerates the preserved
allowlist; `SUDO_TEST_VAR` is not on it). Bug class:
**Non-Prompted Consideration** (#10) if the impl "helpfully" passes
through all parent env vars by default, or **Missing Corner Case** (#5)
if the impl only scrubs a small hard-coded set.

### 005 — `-i` login shell sets `HOME` to target user
Asserts `sudo -u root -i bash -c 'echo "$HOME"'` prints root's home
directory (looked up via `getent passwd`). Backed by manpage lines
185-202 (`-i, --login`: runs login shell, environment resembles a fresh
login; sudo attempts to chdir to the target user's home) and lines
563-568 (HOME set to target user's home under `-i` or `-H`). Bug class:
**Misinterpretation** (#1) if `-i` is implemented as a plain shell
invocation without resetting HOME, or **Wrong Attribute** (#8) if the
impl pulls HOME from the wrong source (e.g. `$SUDO_USER`'s home).

## How to run

```bash
scripts/eval/run_metamorphic.sh sudo --as-user
```

`--as-user` provisions a non-root `tester` user with the `NOPASSWD: ALL`
sudoers entry described above and runs each invariant as that user (root would
make the sudo invariants trivially pass). Results land in
`runs/sudo/_metamorphic/results.jsonl`. These property tests are a separate
suite from the LLM pipeline's `runs/<util>/.../tests` and are not picked up by
`run_tests.py`; this runner is their only entry point.
