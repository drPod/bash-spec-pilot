# Metamorphic invariants for `cp` (wave-4 non-LLM control)

Hand-curated metamorphic / property tests. No LLM involvement. These assert
behaviors any correct `cp` must preserve regardless of flag combinations, and
serve as the adversarial-floor control group against the wave-3 LLM-generated
suites in `runs/cp/`.

Verified against real GNU `cp` (coreutils 9.7) in a Debian trixie container;
every test exits 0. Per `CLAUDE.md`, that container is the canonical oracle.

## Invariants

- **`001_single_file_roundtrip.sh`** — asserts `cp X Y` produces a destination
  byte-equal to the source (mixed printable, whitespace, and binary bytes
  including NUL). Manpage DESCRIPTION line 12: "Copy SOURCE to DEST". Would
  surface `IMPL-WRONG-SEMANTICS` (truncated/transformed copy) or
  `IMPL-CORNER-CASE` (binary-byte handling) per `docs/research/taxonomy.md`
  §2A; Tambon overlap: Misinterpretation, Missing Corner Case.

- **`002_recursive_tree_roundtrip.sh`** — asserts `cp -r DIR1 DIR2` yields
  `diff -r DIR1 DIR2` clean across nested files, empty subdirs, and mixed
  contents. Manpage line 69: "`-R, -r, --recursive` copy directories
  recursively". Surfaces `IMPL-MISSING-FLAG` or `IMPL-CORNER-CASE` (empty
  subdirs, depth handling); Tambon: Incomplete Generation, Missing Corner
  Case.

- **`003_preserve_mode_p.sh`** — asserts `cp -p` preserves mode bits via
  `stat -c %a` equality. Uses 0741 to avoid collision with default umask
  outputs. Manpage line 58: "`-p` same as `--preserve=mode,ownership,
  timestamps`". Surfaces `IMPL-MISSING-FLAG` (no `-p` handling) or
  `IMPL-WRONG-SEMANTICS` (mode silently re-masked by umask); Tambon:
  Misinterpretation, Non-Prompted Consideration (gratuitous chmod after
  copy).

- **`004_preserve_mtime_p.sh`** — asserts `cp -p` preserves mtime via
  `stat -c %Y`, with 1s tolerance for filesystem timestamp resolution.
  Source mtime is pinned to a fixed past date so the test does not depend
  on copy latency. Same manpage line 58. Surfaces `IMPL-WRONG-SEMANTICS`
  (forgot timestamps) or `IMPL-CORNER-CASE` (preserves mode but not mtime);
  Tambon: Misinterpretation, Missing Corner Case.

- **`005_symlink_L_vs_P.sh`** — asserts `-L` and `-P` diverge in the
  documented direction on a symlink source: `-L` materializes the referent
  as a regular file, `-P` preserves the symlink itself. Manpage lines
  49-56. Surfaces `IMPL-WRONG-SEMANTICS` (flags swapped or one stubbed) or
  `IMPL-MISSING-FLAG`; Tambon: Misinterpretation, Hallucinated Object (if
  impl invents a third semantic).

## Why these five

Each invariant is a *behavioral property*, not a per-flag exercise. The
homogenization trap documented for wave-3 (same model writes impl + tests,
tests cover impl's blind spots) does not apply: these were written from the
manpage by a human, against the same Debian trixie GNU oracle, before any
LLM generation ran.

The five collectively cover: content fidelity (001, 002), attribute
preservation (003, 004), and a divergence property between two flags whose
documented semantics are direct opposites (005). Together they form the
minimum-viable floor; failure on any one is unambiguously an impl bug, since
the manpage backing is direct.

## Skipped on purpose

Same boundaries as the wave-3 baseline: no SELinux, ACLs, xattrs,
`--reflink=`, sparse files, signals, network. Ownership preservation under
`-p` is skipped because tests run in containers as root with no second UID
available; the mode + mtime checks exercise the surviving two-thirds of the
`-p` contract.

## Run

```bash
# From repo root, inside trixie container (canonical oracle):
export UTIL=cp
for t in tests/properties/cp/*.sh; do bash "$t" && echo "PASS $t" || echo "FAIL $t"; done
```

Host (macOS) BSD `cp` is **not** the truth source — `stat -c` is GNU-only
and `cp -L`/`-P` BSD semantics differ. Always run inside trixie.
