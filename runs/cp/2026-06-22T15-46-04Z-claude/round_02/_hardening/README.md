# Hardening: cp `--strip-trailing-slashes` (round_02 test 018) — verdict: CONFIRMED man-page defect

Three-oracle triangulation of the cold-adversarial `manpage_underspec` candidate
`018_strip_trailing_slashes_source.sh`. Reproducible probe in `cp_sts_probe.sh` /
`cp_sts_probe.out` (trixie, coreutils 9.7). This is the headline mv finding
**generalizing to cp** from an independent cold de-homogenized generation.

## The claim vs the behavior

Man page (utils/cp/manpage.txt:82-83), unconditional, no qualifying clause:

> "--strip-trailing-slashes  remove any trailing slashes from each SOURCE argument"

A faithful reader concludes: with the flag, `file.txt/` becomes `file.txt` and the
copy succeeds. The real binary does not honor this for a regular-file source.

## Oracle 1 — real binary (trixie, coreutils 9.7)

| invocation | rc | result |
|---|---|---|
| `cp --strip-trailing-slashes file.txt/ out` | 1 | `cannot stat 'file.txt/': Not a directory` (slash still present) |
| `cp file.txt/ out` (no flag) | 1 | identical error — **the flag is a no-op for a regular-file source** |
| `cp --strip-trailing-slashes file.txt out` (no slash) | 0 | sanity: flag is fine |
| `cp -r --strip-trailing-slashes dir/ copy` | 0 | directory source works (flag or not) |
| `mv --strip-trailing-slashes file.txt/ moved` | 1 | `cannot move 'file.txt' to 'moved': Not a directory` |

For cp the with-flag and no-flag cases are byte-identical: `--strip-trailing-slashes`
does not strip the trailing slash before the failing `stat`, and the flag changes
nothing for a regular-file source. (mv strips the name in its message yet still
fails the documented operation — same observable contract, slightly different
internal mechanism. Matches the prior mv finding: a trailing slash carries a
hidden must-be-a-directory check the man page never states.)

## Oracle 2 — POSIX

`cp` is in POSIX; `--strip-trailing-slashes` is a GNU extension, not in POSIX. But
the trailing-slash pathname-resolution rule IS POSIX-mandated
(docs/posix/basedefs/04_general_concepts.md:412):

> "A pathname that contains at least one non-<slash> character and that ends with
> one or more trailing <slash> characters shall not be resolved successfully
> unless the last pathname component before the trailing <slash> characters
> resolves ... to an existing directory ..."

So POSIX explains why `file.txt/` fails, and confirms the GNU flag is the only
mechanism that could neutralize it for a regular file. It doesn't. The man page's
unconditional promise is the defect.

## Oracle 3 — version stability

coreutils 9.7. The one-line entry is long-standing coreutils doc text and is
**byte-identical in cp and mv** (utils/cp/manpage.txt:82-83, utils/mv/manpage.txt:43-44).
The mv instance also has a cross-version check in `runs/mv/_crossver/`. Stable.

## Verdict

**Confirmed man-page defect**, and the strongest result of the adversarial round:
the mv `--strip-trailing-slashes` defect is not utility-specific. Identical man-page
wording across cp and mv produces the same binary-contradicting behavior, surfaced
independently by a cold test author who never saw the impl or the mv finding. This
is a shared coreutils-documentation defect, not a per-utility artifact — the
generality that makes it citation-grade.

Contrast with the killed sudo `-D` candidate (same session, round_01): there the
man page carried a qualifying clause the test dropped. Here the entry has no
qualifier in either cp or mv. That asymmetry is exactly what separates a real
man-page defect from a substring-grounding false positive.
