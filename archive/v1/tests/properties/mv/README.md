# mv — metamorphic property tests (wave-4 non-LLM floor)

Hand-curated invariants any correct `mv` implementation must satisfy. No LLM
in the loop: these are the lab floor against which wave-4 adversarial
LLM-generated tests get compared. Assertions are over *post-state*, not over
stdout/stderr framing — exactly the failure mode wave-3 round 2 missed when
the feedback loop relaxed a test rather than fix a stream-convention bug
(see `docs/research/taxonomy.md` § 5.2).

All tests follow the wave-3 baseline conventions: `set -euo pipefail`,
per-test `mktemp -d` + `trap`, utility invoked only via `"$UTIL"`, absolute
paths inside `$tmpdir`, exit 0 on pass.

## Invariants

### 001 — round-trip identity (`mv A B && mv B A`)

Asserts that moving a file out and back leaves the original path holding
byte-identical content. Manpage backing: NAME line "mv - move (rename)
files" and DESCRIPTION line 12 "Rename SOURCE to DEST" — a rename that
mutates contents is not a rename. Surfaces Tambon-style **silent
incorrectness** (taxonomy § 1) and the specific **test-relaxation-by-
feedback** failure recorded for mv round 2 in taxonomy § 5.2: wave-3 had no
post-state byte check, so impl + tests co-drifted.

### 002 — within-device atomic move

Asserts that after `mv A B` (same directory => same filesystem => `rename(2)`
path), source A is gone and destination B holds the source's bytes. Manpage
backing: SEE ALSO line 108 "rename(2)" plus DESCRIPTION line 12. Surfaces
**bilateral omission** (taxonomy § 4.3): wave-3 baseline tests checked
existence-after-move but not the conjunction (source gone *and* dest has
exact bytes), letting partial-state impls slip through.

### 003 — permissions preserved on within-device move

Asserts `stat -c %a` is identical before and after the move. Manpage
backing: SEE ALSO "rename(2)" — `rename(2)` is inode-preserving, so mode
bits survive by construction. Surfaces **stream-convention silence**
(taxonomy § 4.1) in its broader form: when the manpage delegates to a
syscall it names, the delegation's invariants are part of the contract,
not free-form impl choice. A Rust impl that opens a fresh file and
re-copies bytes can plausibly forget mode bits and pass all wave-3 tests.

### 004 — `-n` (no-clobber) leaves both paths intact

Asserts source AND destination both exist and both hold their original
bytes after `mv -n src dst` when dst pre-exists. Manpage backing: lines
34-35 "-n, --no-clobber  do not overwrite an existing file". The manpage
does not specify exit status for the skip case, but the trixie oracle
(coreutils 9.x) skips silently with exit 0; we assert that too, so an impl
that merely errors on an unrecognized `-n` (leaving both paths intact by
accident) cannot pass on post-state alone. Surfaces
**test-relaxation-by-feedback** (taxonomy § 5.2): wave-3 round-2 feedback
rewrote a mv test to swallow stderr rather than enforce post-state. This
test enforces post-state and nothing else.

### 005 — `-i` does not prompt when destination is absent

Asserts that `mv -i src dst < /dev/null` completes the rename when dst
does not pre-exist: source gone, destination present. Manpage backing:
lines 31-32 "-i, --interactive  prompt before overwrite". No overwrite =>
no prompt => no read from stdin => the `/dev/null` redirect must not
matter. Surfaces **self-cut scope** (taxonomy § 4.3): wave-3 tests for
`-i` exercised the prompt path but never the no-prompt path, so an impl
that prompts unconditionally (or hangs on empty stdin) would pass wave-3.

## How to run

Canonical runner (writes `runs/mv/_metamorphic/results.jsonl`):

```bash
scripts/eval/run_metamorphic.sh mv
```

Ad-hoc equivalent. Note the explicit `fail` flag and trailing `exit` — a
`bash "$t" && echo PASS || echo FAIL` loop would mask failures (the `echo
FAIL` succeeds, so the loop exits 0 and CI sees a false green):

```bash
docker run --rm -v "$PWD:/repo" -w /repo debian:trixie-slim sh -c '
  apt-get update -qq && apt-get install -y -qq coreutils >/dev/null
  export UTIL=mv
  fail=0
  for t in tests/properties/mv/*.sh; do
    echo "== $t =="
    if bash "$t"; then echo PASS; else echo FAIL; fail=1; fi
  done
  exit "$fail"
'
```

Pass criterion: every invariant exits 0 against real GNU `mv` in trixie.
A failing invariant means either the invariant over-specifies (fix or drop)
or the manpage is wrong (record which here).
