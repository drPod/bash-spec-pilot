# Wave-4 metamorphic floor — `sudo`

Hand-curated metamorphic / property-based invariants for GNU `sudo`. No
LLM authorship. Companion control group for the wave-4 adversarial test
generation rollout: if the LLM-authored adversarial tests under
`runs/sudo/...` fail to surface bugs that these hand-written invariants
catch, the homogenization-trap hypothesis is supported.

All tests assume:
- They are invoked through `$UTIL=sudo`, per repo convention.
- The invoking user is non-root and has a `NOPASSWD` sudoers entry
  permitting the specific commands (`true`, `id`, `env`, `bash`).
  Container recipe in `tests/properties/sudo/README.md` mirrors the
  one in the worker brief.

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
actually scrubs. Backed by manpage lines 100-104 (existence of `-E`
implies a scrubbing default) and lines 553-575 (explicit allowlist of
preserved vars; `SUDO_TEST_VAR` is not on it). Bug class:
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
