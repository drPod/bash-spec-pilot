# POSIX mirror — Open Group Base Specifications

Full local mirror of the two POSIX volumes that bear on CLI-utility semantics.
**Edition: Issue 8 / IEEE Std 1003.1-2024.** 172 pages: all 14 Base Definitions
(XBD) chapters, all 3 Shell & Utilities (XCU) front chapters, and every POSIX
utility page (155). Provenance (per-page SHA-256 of the upstream HTML, fetch
timestamp, counts) is in [`_source.json`](_source.json); the URL list is in
[`_urls.txt`](_urls.txt). Regenerate with `scripts/dev/sync_posix_docs.sh`
(`POSIX_ISSUE=7` for the 2018 edition).

Read this mirror, not `pubs.opengroup.org` — the pin makes comparisons
reproducible, the same way `utils/<util>/manpage.txt` freezes the man-page side.
The directory layout follows the upstream URL paths (`basedefs/`, `utilities/`).

**Not mirrored:** the System Interfaces (XSH) volume (~1200 C-function pages —
`open()`, `stat()`, …). That is the libc layer, not the CLI layer this project
studies. Add an `xsh` leg to the sync script if that changes.

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
this mirror: [`basedefs/04_general_concepts.md`](basedefs/04_general_concepts.md)
(Pathname Resolution) documents the trailing-slash-must-be-a-directory rule that
`mv(1)` omits — POSIX sides with the binary, so the GNU man page is the
defective source.

## Scope caveats (read before drawing conclusions)

- **POSIX covers a subset of the GNU surface.** It specifies the *base* utility.
  GNU extensions are out of scope: `cp --reflink`/`--strip-trailing-slashes`,
  `mv --backup`/`--exchange`, find's `-printf`/`-regex`/`-newerXY`. Absence from
  POSIX is not a man-page defect — it is a GNU extension POSIX never claimed to
  cover.
- **`sudo` is not POSIX.** No mirror page exists for it. The three-source method
  drops to two (man page ↔ binary) for `sudo`.
- **POSIX leaves things unspecified on purpose.** The vocabulary is defined in
  [`basedefs/02_conformance.md`](basedefs/02_conformance.md): `unspecified`,
  `undefined`, `implementation-defined`. The useful property is that it *marks*
  the holes where the man page stays silent, not that it has none. Treat "POSIX
  is silent here" as a third outcome, distinct from "POSIX agrees / disagrees
  with the binary."

## Base Definitions (XBD) — `basedefs/`

The cross-utility rulebook. Any single utility page is interpreted against these.

| File | Chapter | When to consult |
|---|---|---|
| [`01_introduction.md`](basedefs/01_introduction.md) | Introduction | Scope, normative-references, how to read the standard. |
| [`02_conformance.md`](basedefs/02_conformance.md) | **Conformance** | `shall`/`should`/`may`; the `unspecified`/`undefined`/`implementation-defined` definitions. The backbone of "POSIX marks its holes." |
| [`03_definitions.md`](basedefs/03_definitions.md) | **Definitions** | Normative glossary: pathname, directory, file type, symbolic link, blank, etc. The exact meaning of terms the utility pages use. |
| [`04_general_concepts.md`](basedefs/04_general_concepts.md) | **General Concepts** | **Pathname Resolution (trailing-slash rule)**, symlink handling, file times, file access permissions. First stop for filesystem-semantics questions. |
| [`05_file_format_notation.md`](basedefs/05_file_format_notation.md) | File Format Notation | The `%`/conversion grammar used in utility output/format descriptions. |
| [`06_character_set.md`](basedefs/06_character_set.md) | Character Set | Portable character set, char encoding assumptions. |
| [`07_locale.md`](basedefs/07_locale.md) | Locale | `LC_*` category semantics — relevant to locale-sensitive utility behavior. |
| [`08_environment_variables.md`](basedefs/08_environment_variables.md) | Environment Variables | `PATH`, `LC_*`, `LANG`, `TMPDIR`, etc. and their effect on utilities (the find case-folding / flaky-env class). |
| [`09_regular_expressions.md`](basedefs/09_regular_expressions.md) | Regular Expressions | BRE/ERE definitions (grep/sed/awk; POSIX `find` has no `-regex`). |
| [`10_directory_structure_and_devices.md`](basedefs/10_directory_structure_and_devices.md) | Directory Structure & Devices | `/dev/null`, `.`/`..` semantics. |
| [`11_general_terminal_interface.md`](basedefs/11_general_terminal_interface.md) | General Terminal Interface | termios; mostly out of scope here. |
| [`12_utility_conventions.md`](basedefs/12_utility_conventions.md) | **Utility Conventions** | Option syntax: single `-`, `--` end-of-options, grouping, option-arguments, operand order. The rulebook a conforming CLI parser must follow. |
| [`13_namespace_and_future_directions.md`](basedefs/13_namespace_and_future_directions.md) | Namespace & Future Directions | Reserved names; rarely needed. |
| [`14_headers.md`](basedefs/14_headers.md) | Headers | C header contents; libc-adjacent, rarely needed for CLI work. |

## Shell & Utilities (XCU) front chapters — `utilities/_chap*.md`

| File | Chapter | When to consult |
|---|---|---|
| [`_chap01_introduction.md`](utilities/_chap01_introduction.md) | Introduction | **Default behaviors for the STDIN/STDOUT/STDERR/EXIT STATUS/CONSEQUENCES OF ERRORS sections** every utility page inherits. Relevant to the stream-convention-silence finding (taxonomy §4.1). |
| [`_chap02_shell_command_language.md`](utilities/_chap02_shell_command_language.md) | **Shell Command Language** | The shell grammar, quoting, expansions, pattern-matching notation, exit-status rules. Directly relevant to the eventual Bash spec — this is the closest thing POSIX has to a Bash spec. |
| [`_chap03_utilities.md`](utilities/_chap03_utilities.md) | Utilities | Preamble to the per-utility pages. |

## Utility pages — `utilities/<name>.md`

All 155 POSIX utility pages are mirrored. In-scope for this project:

- [`utilities/cp.md`](utilities/cp.md) — compare against `utils/cp/manpage.txt`.
- [`utilities/mv.md`](utilities/mv.md) — note the trailing-slash rule lives in `basedefs/04_general_concepts.md`, not here.
- [`utilities/find.md`](utilities/find.md) — POSIX primaries only; GNU adds many (`-printf`, `-regex`, `-newerXY`) that POSIX omits.

`sudo` is not a POSIX utility, so there is no page for it. The full list of 155
is in `_source.json` (or `ls utilities/`). Mirroring all of them is cheap and
makes the discrepancy method scale to any utility the experiment expands to.

## Rendering notes

Source HTML → `scripts/dev/_strip_posix_html.py` (drops Prev/Home/Next nav and
the `codes.js` include) → `pandoc -f html -t gfm`. The DESCRIPTION/OPTIONS prose
renders cleanly; SYNOPSIS lines carry some backtick/bold noise from the upstream
nested `<tt><b>` markup but are faithful. Section anchors are preserved as
`<span id="tag_...">` so they line up with the upstream page.
