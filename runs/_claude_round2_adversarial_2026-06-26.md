# Claude cold-adversarial round 2 (2026-06-26)

Session `2026-06-22T15-46-04Z-claude`, round_02. Follow-on to the round_01 sweep
(`runs/_claude_sweep_2026-06-22.md`). Same NON-CANONICAL caveats apply: generator
is Claude (claude-opus-4-8) subagents, not the pinned gpt-5.5 driver; not
reproducible via `driver.py`, not quantitatively comparable to canonical sessions.

> **Why this round.** The round_01 sweep was general-purpose and surfaced only
> candidates that mostly washed out on scrutiny (sudo `-D` killed on hardening;
> see `runs/sudo/.../round_01/_hardening/`). This round runs the wave-4
> cold-adversarial mode — test authors told to hunt documented overcommitment via
> boundary-value + equivalence partitioning — to aim at the parts of each man page
> most likely to lie. Impls reused from round_01; only the tests are new and cold.

## Method

Per util, one cold test-author subagent (blind: read only `utils/<u>/manpage.txt`,
never the impl), biased toward the `errors`/`flags`/`examples` slices. Each carried
a hardened methodology guard born from the sudo `-D` false positive: a
`manpage_quote` must include any adjacent qualifying clause, so a hedge cannot be
dropped to manufacture a defect. Then `eval_adversarial.sh <u> <sid> 2` (static
filter -> real-gnu -> rust-in-docker -> classify) per util.

## Results

| util | tests | real-gnu | rust | baseline | divergence | manpage_underspec | shared_bug |
|------|-------|----------|------|----------|------------|-------------------|------------|
| cp   | 22    | 21/22    | 22/22| 21       | 0          | **1**             | 0          |
| find | 22    | 21/22    | 20/22| 20       | 1          | 0                 | 1          |
| sudo | 18    | 18/18    | 13/18| 13       | 5          | 0                 | 0          |

## The payload: cp `--strip-trailing-slashes` — CONFIRMED, generalizes mv

The one new man-page-defect candidate, and it hardened to citation strength.
`cp --strip-trailing-slashes file.txt/ out` fails `cannot stat 'file.txt/': Not a
directory` on a regular-file source — identical with and without the flag — yet the
man page says the flag removes trailing slashes from each SOURCE, with no
qualifying clause. Triangulated against the real binary (coreutils 9.7), POSIX
(basedefs/04:412 trailing-slash resolution), and version stability. The man-page
wording is **byte-identical in cp and mv**, so this is the headline mv defect
reproduced in a second utility from an independent cold generation: a shared
coreutils-documentation defect, not a per-utility artifact. Full verdict:
`runs/cp/.../round_02/_hardening/`.

## What washed out (correctly)

- **find: no man-page defect.** The cold author's strong hypotheses (leading-dot
  glob per POSIX interp 126, `-size` round-up, `-a`/`-o` precedence, default
  `-print` inhibition) all held against the real binary. One divergence
  (`-fprint` unimplemented in the round_01 impl) is an impl bug; one shared_bug is
  a test artifact.
- **sudo: zero false manpage_underspec** (round_01 had two). The methodology guard
  did its job. All 5 divergences are documented option-errors the round_01 impl
  fails to enforce (`-K` with command/option, duplicate `-u`, `-u`+`--user`,
  duplicate `-D`) — impl bugs, real sudo rejects each correctly.

## Taxonomy state after this round

- **Confirmed man-page defects: 1 defect class, 2 utilities** — `--strip-trailing-slashes`
  on a regular-file source with a trailing slash (mv from round_01 + cross-version;
  cp confirmed here). Citation-grade.
- **Killed candidates:** sudo `-D`/`--chdir` (documented policy gate), sudo `-s`.
- **Methodology output:** substring grounding is necessary but not sufficient
  (sudo `-D`); the full-governing-span guard added this round prevented recurrence.
  The cp/mv asymmetry vs sudo `-D` (no qualifier vs qualifier present) is the
  operational test for real-defect vs false-positive.

## Reproduce

```
SID=2026-06-22T15-46-04Z-claude
for u in cp find sudo; do scripts/eval/eval_adversarial.sh "$u" "$SID" 2; done
```

Deterministic against the frozen round_02 impls and tests. Re-running the
generation is not (fresh Claude subagents).
