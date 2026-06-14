# POSIX mirror — Open Group Base Specifications

Local mirror of the POSIX pages this project compares Linux man pages against.
**Edition: Issue 8 / IEEE Std 1003.1-2024.** Provenance (source URLs, per-page
SHA-256 of the upstream HTML, fetch timestamp) is in [`_source.json`](_source.json);
the URL list is in [`_urls.txt`](_urls.txt). Regenerate with
`scripts/dev/sync_posix_docs.sh` (set `POSIX_ISSUE=7` for the 2018 edition).

Read this mirror, not `pubs.opengroup.org` — the pin makes comparisons
reproducible, the same way `utils/<util>/manpage.txt` freezes the man-page side.

## Why POSIX is here

The project's question is whether a Linux man page is a good enough source to
build a formal spec of a utility from. The `mv` finding (see the root README)
showed a man page can be flat wrong: GNU `mv` enforces a "source-with-trailing-
slash must be a directory" check that `mv(1)` never documents. POSIX is a third
description of the same utilities, alongside the GNU man page and the real
binary:

| Source | What it is | Role here |
|---|---|---|
| GNU man page (`utils/<util>/manpage.txt`) | Informal prose, the LLM's input | The thing under test |
| **POSIX (this mirror)** | Committee standard, precise `shall`/`may` language, marks its own gaps | Second opinion — localizes which document is at fault |
| Real GNU binary (Docker trixie) | Ground truth | The behavioral oracle |

Triangulating the three lets you say *which* document is wrong when behaviors
diverge, not just *that* they diverge. The headline case is already settled by
this mirror: [`general_concepts.md`](general_concepts.md) (Pathname Resolution)
documents the trailing-slash-must-be-a-directory rule that `mv(1)` omits — POSIX
sides with the binary, so the GNU man page is the defective source.

## Scope caveats (read before drawing conclusions)

- **POSIX covers a subset of the GNU surface.** It specifies the *base* utility.
  GNU extensions are out of scope: `cp --reflink`/`--strip-trailing-slashes`,
  `mv --backup`/`--exchange`, find's `-printf`/`-regex`/`-newerXY`. Absence from
  POSIX is not a man-page defect — it is a GNU extension POSIX never claimed to
  cover.
- **`sudo` is not POSIX.** No mirror page exists for it. The three-source method
  drops to two (man page ↔ binary) for `sudo`.
- **POSIX leaves things unspecified on purpose.** It has labeled categories —
  `unspecified`, `undefined`, `implementation-defined`. The useful property is
  that it *marks* the holes where the man page stays silent, not that it has
  none. Treat "POSIX is silent here" as a third outcome, distinct from "POSIX
  agrees / disagrees with the binary."

## Files

| File | Lines | Upstream | When to consult |
|---|---|---|---|
| [`cp.md`](cp.md) | 358 | `utilities/cp.html` | `cp` semantics: synopsis forms, `-RHLPfip` options, operands, exit status, the concatenation/overwrite rules. Compare against `utils/cp/manpage.txt`. |
| [`mv.md`](mv.md) | 296 | `utilities/mv.html` | `mv` semantics: rename vs copy-and-remove, `-fi` options, the directory/existing-file rules. The trailing-slash behavior is **not** here — it's in `general_concepts.md`. |
| [`find.md`](find.md) | 586 | `utilities/find.html` | `find` primaries and operators POSIX defines (`-name`, `-type`, `-perm`, `-exec`, `-print`, expression grammar). GNU adds many primaries POSIX omits — expect partial coverage. |
| [`general_concepts.md`](general_concepts.md) | 595 | `basedefs/V1_chap04.html` | Base Definitions ch. 4. **Pathname Resolution (the trailing-slash rule), symbolic-link handling, file times, file access permissions.** First stop for any cross-utility filesystem-semantics question. |
| [`utility_conventions.md`](utility_conventions.md) | 177 | `basedefs/V1_chap12.html` | Base Definitions ch. 12. Option syntax conventions: single `-`, `--` end-of-options, grouping, option-arguments, operand ordering. The rulebook for what a conforming CLI parser must accept. |
| [`shell_utilities_intro.md`](shell_utilities_intro.md) | 1039 | `utilities/V3_chap01.html` | Shell & Utilities vol. intro. **Default behaviors for the STDIN / STDOUT / STDERR / EXIT STATUS / CONSEQUENCES OF ERRORS sections** every utility page inherits. Relevant to the stream-convention-silence finding (taxonomy §4.1): POSIX states defaults the man page leaves implicit. |

## Rendering notes

Source HTML → `scripts/dev/_strip_posix_html.py` (drops Prev/Home/Next nav and
the `codes.js` include) → `pandoc -f html -t gfm`. The DESCRIPTION/OPTIONS prose
renders cleanly; the SYNOPSIS line carries some backtick/bold noise from the
upstream nested `<tt><b>` markup but is faithful. Section anchors are preserved
as `<span id="tag_...">` so they line up with the upstream page.
