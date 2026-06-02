# Metamorphic floor — `find`

Hand-written property tests for GNU `find`. Wave-4 non-LLM control group:
the lab floor that any correct re-implementation must clear before any
LLM-authored test suite (under `runs/find/...`) is taken at face value.

These tests encode **metamorphic invariants** — relationships every
correct `find` must preserve — rather than fixed output snapshots. They
are deliberately authored by hand to avoid the wave-3 "homogenization
trap" in which the same model wrote impl and tests, then graded itself.

## Conventions

- Invoke utility via `"$UTIL"` env var. The runner sets this; the tests
  never name `find` literally.
- All scratch state lives under `mktemp -d`, cleaned up via `EXIT` trap.
- Exit 0 = invariant held. Nonzero exit + a stderr diagnostic = invariant
  violated. Some tests print extra context on failure (e.g. the full `find`
  output), so a diagnostic may span multiple lines.

Run inside the trixie oracle (matches the rest of the pipeline):

```bash
docker run --rm -v "$PWD:/repo" -w /repo debian:trixie-slim sh -c '
  apt-get update -qq && apt-get install -y -qq findutils >/dev/null
  export UTIL=find
  for t in tests/properties/find/*.sh; do
    echo "== $t =="
    bash "$t" && echo PASS || echo FAIL
  done
'
```

## Invariants

### 001 — default action includes the starting-point

`find $d` (no expression) emits `$d` itself as one of the output lines.
Backed by the `-mindepth 1` definition (utils/find/manpage.txt lines
410-413: "Using -mindepth 1 means process all files except the
starting-points"), which is the dual of the default. Catches impls that
silently start their walk one level below the argument. Bug class:
**Missing Corner Case** (Tambon §4.1.1).

### 002 — `-type f` count matches an independent recursive walk

`"$UTIL" $d -type f | wc -l` equals a pure-shell BFS over `$d` that
counts only regular non-symlink entries. Backed by the `-type c`
definition (utils/find/manpage.txt lines 779-790) plus the description's
"evaluating the given expression ... until the outcome is known" (lines
12-15). Symlinks are explicitly excluded from `-type f` under the default
`-P` mode (manpage line 55: "Never follow symbolic links. This is the
default behaviour."). Catches impls that miscount hidden files,
skip the starting-point, or mis-classify symlinks. Bug classes:
**Hallucinated Object** / **Missing Corner Case**.

### 003 — `-name` is a restricting predicate

`"$UTIL" $d -type f -name '*.x'` is a subset of `"$UTIL" $d -type f`.
Backed by `-name pattern` (utils/find/manpage.txt lines 601-606: "Base of
file name ... matches shell pattern pattern"). The full set is the
unrestricted enumeration; the predicate can only filter, never invent.
Catches impls that misapply the glob to whole paths (turning the
predicate into something that matches paths absent from the base set) or
that emit duplicate / paraphrased lines. Bug class:
**Misinterpretation**.

### 004 — `-maxdepth` is monotone in its argument

The result set for `-maxdepth k` is contained in the result set for
`-maxdepth (k+1)`. Verified for k = 0..4 on a four-level tree. Backed by
`-maxdepth levels` (utils/find/manpage.txt lines 403-407: "Descend at
most levels ... below the starting-points"). Catches off-by-one bugs at
the depth boundary, and impls that swap `-maxdepth` semantics with
`-mindepth`. Bug class: **Missing Corner Case**.

### 005 — `-print0` matches `-print` on NUL/newline-free names

For a tree whose filenames contain neither NUL nor newline, the set of
paths emitted by `-print0` (after `tr '\0' '\n'`) equals the set emitted
by the default `-print`. Backed by the `-print` and `-print0` definitions
(utils/find/manpage.txt lines 1009-1024), which differ only in the
trailing delimiter byte. Catches impls that build `-print0` on a separate
codepath that drops or rearranges entries. Bug classes:
**Hallucinated Object** / **Wrong Attribute**.
