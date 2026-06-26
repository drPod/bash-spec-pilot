# Man-page vs POSIX divergence catalog (2026-06-26)

A defect-discovery engine, and the result that reframes the project's thesis.
Now spanning **27 utilities** across two waves, ~120 binary-adjudicated
divergences:

- **Wave 1 (8 utils):** cp, mv, find, ls, rm, ln, chmod, touch — ~42 divergences.
- **Wave 2 (19 utils, 2026-06-26):** head, tail, cat, wc, cut, tr, uniq, paste,
  comm, sort, od, expr, mkdir, rmdir, du, basename, dirname, readlink, printf —
  ~75 divergences. Same method (Claude-subagent M-vs-P mining → deterministic
  trixie adjudication, non-root). Confirms the omission-dominant pattern at scale
  and adds five citation-grade contradictions (below).

> **Provenance note.** Unlike the Claude sweeps, this catalog does NOT depend on
> any LLM-generated impl. Candidates come from comparing two frozen authoritative
> texts (GNU man page `utils/<u>/manpage.txt` vs POSIX mirror
> `docs/posix/utilities/<u>.md` + basedefs), and each verdict is the real GNU
> binary in trixie (coreutils 9.7 / findutils 4.10.0). The mining step used Claude
> subagents (no OpenAI spend); the adjudication is deterministic shell probes
> (`debian:trixie`, run non-root to avoid the root confound). This is firmer
> ground than the M-vs-impl differential.

## Why this engine

The M-vs-binary differential (the Claude sweeps) mines ONE of three disagreement
axes and is structurally blind to omissions. There are three sources — man page
(M), real binary (B), POSIX (P) — and three axes:

| axis | finds | status |
|---|---|---|
| M vs B | documented-but-false (overcommitment) | mined; low yield, LLM-convergent |
| **M vs P** | man page contradicts / diverges from the standard | this catalog (8 utils) |
| B vs P | GNU binary deviates from the standard | extracted here as a side effect |
| M silent, B acts | undocumented behavior (omission) | the dominant class |

## The reframed thesis

The man page's dominant failure as a spec source is **omission, not falsehood**.
Outright lies (M contradicts B) are rare. Far more common: the man page is silent
where POSIX and the binary commit. Scaled to 8 utilities the pattern holds hard —
of ~42 adjudicated divergences, the large majority are omissions. "Can an LLM
build a trustworthy spec from the man page?" becomes "the man page is a
*characterizably incomplete* spec source," which is sharper and more useful for
Astrogator POPL 2027 §7.2.

## EXIT STATUS: the systematic structural omission

The single cleanest result, deterministic from frozen texts (no probe needed).
A spec-extractor cannot recover even pass/fail semantics from most coreutils man
pages, because the man page never states them:

| util | exit-status documentation in M | POSIX |
|---|---|---|
| cp | **none** | 0 / >0 |
| mv | **none** | 0 / >0 |
| rm | **none** | 0 / >0 (skipped-prompt files excluded from the error count) |
| ln | **none** | 0 / >0 |
| chmod | **none** | 0 / >0 |
| touch | **none** | 0 / >0 |
| install | **none** | (not a POSIX utility) |
| ls | minimal `Exit status:` subsection, GNU `0/1/2` | 0 / >0 |
| find | full `EXIT STATUS` section | 0 / >0 |

7 of 8 coreutils man pages carry **zero** exit-status text. `ls` is the lone
coreutils exception, and even there it diverges by *over*-specifying (GNU
`0/1/2` granularity vs POSIX `0/>0` — a refinement POSIX permits, not a
contradiction). Only `find` (findutils) documents it properly. The binary always
returns a meaningful status; the man page just never tells you what it means.

**Wave 2 confirms this is structural, not a small-sample artifact.** Across the
full 28-page frozen corpus (`grep -niE '^(EXIT STATUS|RETURN VALUE)'
utils/*/manpage.txt`):

- **25 of 28** man pages carry no top-level EXIT STATUS section.
- **`find`** is the only one with a full section.
- **`ls`** has an indented `Exit status:` subsection (over-specified, see above).
- **`expr`** states its exit status inline (the truth value *is* the utility's
  purpose) — and **gets it wrong**. M says "2 if syntactically invalid, **3 if an
  error occurred**"; the binary returns **2** for division by zero, modulo by
  zero, bad operator, and non-integer operand alike (coreutils 9.7 is GMP-built,
  so there is no overflow path, and exit 3 is effectively unreachable). The one
  coreutil that bothers to specify a runtime exit code specifies the wrong one.

So exit status is omitted by 25 utils, over-specified by 1 (ls), mis-specified by
1 (expr), and correct in exactly 1 (find). When the man page is silent a
spec-extractor must guess; when it speaks (expr) it can still be wrong.

## Three-class taxonomy (M vs P)

1. **OMISSION** (`posix-requires / man-page-silent`): POSIX mandates and B does a
   behavior M never documents. A man-page-only spec MISSES it. *Dominant class.*
2. **COMMITS-WHERE-POSIX-HEDGES** (`gnu-commits / posix-latitude`): M pins down
   behavior POSIX leaves unspecified, and B matches M. Here the man page is a
   BETTER spec than POSIX. Net positive — but only verifiable against B.
3. **CONTRADICTION / LIE** (`M vs B disagree`, or M vs P with B picking a side):
   M and B directly disagree (rare), or M documents a deliberate GNU deviation
   from POSIX (M=B, both != P).

## Binary-adjudicated findings (trixie)

### cp (coreutils 9.7)

| # | behavior | class | binary verdict |
|---|---|---|---|
| C4 | exit status + continue-on-error after a per-file failure | **omission** | exit=1, remaining operands still copied. The cp man page has no exit-status section. Foundational omission. |
| C3 | overwrite of an existing regular file | **omission** | keeps perms (700) AND inode (O_TRUNC in place), POSIX-mandated; man page silent. A spec-extractor would assume the source's mode. |
| C1 | `-R` symlink default (no `-H`/`-L`/`-P`) | omission / latitude | POSIX unspecified; man page silent; binary = `-P` (copies the link). |
| C2 | `-i` with a non-affirmative / EOF response | omission | binary skips (keeps old), exit=1 on EOF; man page says only "prompt before overwrite". |
| C5 | same-file `cp a a` | commits-where-hedges | POSIX: "may" no-op; binary errors exit=1; man page documents only the `-f --backup` special case, not the default error. |

### find (findutils 4.10.0)

| # | behavior | class | binary verdict |
|---|---|---|---|
| F1 | which actions suppress the implicit `-print` | **contradiction (M=B != P)** | `find . -fprint X` → stdout empty. Binary follows the GNU page (large suppress set); POSIX suppresses only for `-exec`/`-ok`/`-print`. GNU documents a POSIX deviation. |
| F3 | `-newer` symlink-reference dereference | **contradiction (intra-doc + M vs B)** | man page line 1462 says "always dereferenced"; lines 624-628/282-284 say conditional on `-H`/`-L`. Binary (default `-P`) does NOT dereference (uses the link's own mtime). Line 1462 is false/stale. |
| F2 | `{}` replaced as a substring of an `-exec` arg | commits-where-hedges | `echo pre{}post` → `pre./fpost`. Binary = GNU ("everywhere it occurs"); POSIX impl-defined. |

### mv (coreutils 9.7)

| # | behavior | class | binary verdict |
|---|---|---|---|
| M1 | prompt when dest unwritable + stdin is a terminal, without `-i` | **omission / contradiction** | POSIX mandates the prompt; man page documents prompting only via `-i`; binary does NOT prompt (overwrites). Man page omits a POSIX interaction point; binary sides with the man page over POSIX. |
| M2 | `-n` / `--update=none` skip exit status | commits-where-hedges | binary exit=0 on skip; GNU commits to this; POSIX's exit-0 carve-out covers only non-affirmative prompt responses. |
| M3 | `-i`/`-f`/`-n` precedence | commits-where-hedges | binary = last-of-three (GNU); POSIX defines last-of-(`-f`/`-i`) only. |
| M4 | trailing slash on a non-directory target | contradiction | POSIX: hard error, no operands processed; relates to the confirmed `--strip-trailing-slashes` finding. |

### ls (coreutils 9.7)

Mined 17 candidates, 9 behaviorally adjudicated. M documents `ls` as a bag of
options and is silent on the output *contract* POSIX specifies.

| # | behavior | class | binary verdict |
|---|---|---|---|
| L-order | multi-operand: non-directory operands first, sorted separately | **omission** | `ls d zfile` → `zfile` then `d:`. M silent on operand ordering. |
| L-symdir | bare symlink-to-dir operand expands contents; `-d`/`-l` shows the link | **omission** | `ls lnk` → `inside`; `ls -ld lnk` → `lnk -> realdir`. M has per-option text, never the default rule. |
| L-total | `total %u` status line precedes each long listing | **omission** | `ls -l .` first line = `total 0`. M never documents it. |
| L-header | `dir:` header per directory in multi-dir / `-R` output | **omission** | `ls d1 d2` → `d1:` / `d2:` blocks. M silent. |
| L-arrow | `-l` symlink rendered `name -> target` | **omission** | confirmed `slk -> tgt`. M silent on the arrow form. |
| L-1col | default one-entry-per-line when stdout is not a terminal | **omission** | `ls \| cat` → one per line. M documents `-1`/`-C` as options, never the non-tty default. |
| L-errcont | inaccessible operand: diagnose, continue, exit nonzero | **omission** | `ls nonexistent real` → lists `real`, exit=2. M has exit codes but not the continue-on-error contract. |
| L-1long | `-1` does NOT disable long format | **contradiction** | `ls -l -1 q` → full long line. M's "`-1` list one file per line" read literally predicts plain single-column; binary follows POSIX (`-1` "does not disable long format output"). M is the defective spec. |
| L-loop | `-R` infinite-loop detection + diagnostic | inconclusive | probe via a symlink cycle did not fire (GNU `ls -R` does not follow symlinks by default, so no loop). The POSIX mandate targets hard-link cycles / `-L`; not adjudicated. |

### rm (coreutils 9.7)

Mined 11, 6 adjudicated. All confirmed omissions — M states the happy path,
omits the POSIX error/stream/interaction contract.

| # | behavior | class | binary verdict |
|---|---|---|---|
| R-exit | nonexistent operand (no `-f`) → diagnostic + nonzero exit | **omission** | `rm ghost` → exit=1. M documents only the `-f` side. |
| R-dir | directory operand without `-r`/`-d` → diagnostic + nonzero exit, dir survives | **omission** | exit=1, `cannot remove 'sub': Is a directory`, survives. M says "does not remove directories" but omits the diagnostic + exit. |
| R-symrec | recursion removes symlinks, does not traverse them | **omission** | `rm -r inside` removes the link; `target/keep` survives. M silent. |
| R-dashdash | `--` ends options; following `-r` treated as an operand | **omission** | `rm -- -r` removes the file named `-r`, exit=0. M shows only a single `-foo` example, never the general rule. |
| R-stream | prompts written to standard error | **omission** | `rm -i f` → prompt on stderr, stdout empty. M never states the stream. |
| R-nontty | `-i` prompts even when stdin is not a terminal | **omission** | piped `-i` still prompts (file survives on `n`). M ties prompting to a terminal in the unwritable-default path; silent on the `-i` override. |

### ln (coreutils 9.7)

Mined 12, all adjudicated by the mining agent against trixie. Omission-dominant
(8 of 12). The headline is a **data-loss safety omission**.

| # | behavior | class | binary verdict |
|---|---|---|---|
| LN-04 | `ln -f a a` (same dir entry) must NOT unlink the file | **omission (data-loss)** | refuses, `'a' and 'a' are the same file`, file preserved. M's `-f` ("remove existing destination files") read literally is a **data-destroying spec** POSIX explicitly forbids. Highest-value single omission found. |
| LN-02 | existing dest without `-f` → diagnostic + error, source intact | **omission** | exit=1, `File exists`, source untouched. M says only "should not already exist", never the consequence. |
| LN-03 | trailing `/` on a dest that doesn't resolve to a dir → fail | **omission** | `ln -s a b/` → `No such file or directory`, no link. M silent (no `--strip-trailing-slashes` here, and no trailing-slash text at all). |
| LN-05 | >2 operands, final not an existing dir → error | omission | exit=1. M gives the synopsis form, not the runtime check. |
| LN-06 | target-dir dest = dir + `/` + basename(source) | omission | `ln -s sub/file dest/` → `dest/file`. M says "in DIRECTORY", never the basename rule. |
| LN-07 | with `-s`, source need not exist / any type | omission | dangling symlink created, exit=0. M states existence only for hard links. |
| LN-09 | default hard-link symlink handling pinned to `-P` | commits-where-hedges | binary = `-P` (links the symlink itself); POSIX leaves the default implementation-defined; M commits. |
| LN-10 | hard-linking a directory refused by default | commits-where-hedges | `ln d2 d2link` → `hard link not allowed for directory`; POSIX implementation-defined; M commits. |

### chmod (coreutils 9.7)

Mined 11, 7 adjudicated. Mix of omissions and the cleanest **class-2** example
in the corpus.

| # | behavior | class | binary verdict |
|---|---|---|---|
| CH-ctime | success marks the last-status-change timestamp | **omission** | ctime changes on `chmod`. M never mentions timestamps. |
| CH-exit | nonexistent operand → nonzero exit | **omission** | exit=1. No exit-status section in M. |
| CH-recerr | per-operand failure: continue, exit nonzero | **omission** | `chmod 644 /nonexistent ok` → exit=1, `ok` still set to 644. M silent. |
| CH-osnoop | `o+s` (who `o` only) is a no-op, not an error | **omission** | exit=0, mode unchanged. M's grammar permits `os`; never states the special semantics. |
| CH-tother | `u+t`/`g+t`/`o+t` not an error (meaning unspecified) | **omission** | `chmod u+t d` → exit=0. M silent. |
| CH-eqdir | symbolic `=` preserves a directory's unmentioned setid bits, clears a file's | **commits-where-hedges** | dir `2755 →(=rx) 2555` setgid survives; file `4755 →(a=rx) 555` setuid cleared; octal `=755` clears (no exception). M documents the exact directory exception POSIX's `=` operator text omits (POSIX leaves it implementation-defined). **M is the better spec.** |
| CH-gsclr | `g-s` clears a set-gid bit that `ls -l` shows set | omission | `g+s`→2644, `g-s`→644. POSIX mandates the guarantee; M only hedges about bits being "ignored". |

### touch (coreutils 9.7)

Mined 11, 6 adjudicated. Rich omission surface around time semantics, plus a
documented GNU deviation.

| # | behavior | class | binary verdict |
|---|---|---|---|
| T-ccyy | `-t [[CC]YY]MMDDhhmm[.ss]` field semantics: century rule, SS default | **omission** | `-t 7001010000`→1970, `-t 6901010000`→1969, `.30`→sec=30. M gives the format string with **zero** semantics (no century mapping, no SS default). |
| T-cexit | `touch -c missing` exits 0 | **omission** | exit=0. No exit-status section; a naive reader expects nonzero. |
| T-mode | file creation mode = `0666 & ~umask` | **omission** | `umask 022; touch new` → 644. M says only "created empty". |
| T-csilent | `-c` also suppresses the missing-file diagnostic | **omission** | stderr 0 bytes. M says only "do not create any files". |
| T-tz | `-t`/`-d` time interpreted in `TZ` | **omission** | UTC vs America/New_York differ by 18000s. M never mentions `TZ`. |
| T-dash | `-` operand → file associated with standard output | **contradiction (M=B != P)** | `touch - 1>realfile` updates `realfile`, no literal `-` created. POSIX has no `-` operand (would touch a file named `-`); GNU documents a deliberate deviation. |

## Wave 2 — corpus scaling to 19 utilities (2026-06-26)

Mined by 5 parallel opus subagents (grouped by utility family), all candidates
adjudicated in one deterministic batch (`scratchpad/mp_adjudicate2.sh`, trixie
coreutils 9.7, uid 1000). ~85 candidates probed; ~75 confirmed as real
divergences, ~10 came back as controls (M = P = B agreement, listed for honesty).
The five **contradictions** (M says X, binary does Y) are the headline; everything
else is the same omission class wave 1 established.

### The five citation-grade contradictions (M ≠ B)

| util | finding | what M says | what the binary does |
|---|---|---|---|
| **od** | default output format | DESCRIPTION line 12: "octal **bytes** by default" | `od file` → two-byte octal **shorts** (`-t oS`), matching POSIX *and od's own EXAMPLES* (line 131). M's prose contradicts M's own example. |
| **expr** | runtime error exit code | "3 if an error occurred" | `expr 1 / 0` → exit **2** (and every other runtime error → 2; exit 3 unreachable). |
| **basename** | suffix removal | "also remove a trailing SUFFIX" (unconditional) | `basename foo foo` → **`foo`** (suffix == whole name is NOT removed; POSIX step 6 guard). Reading M literally yields empty output — a data-shape trap. |
| **tail** | `+0` line addressing | `-n +NUM` = "skip NUM-1 lines" | `tail -n +0` → **whole file** (skip-(-1) is nonsense; binary clamps to all). POSIX calls +0 non-conforming; the binary clamps anyway. |
| **cut** | range grammar | "N-M from N'th to M'th" (no constraint) | `cut -c5-2` → **error** `invalid decreasing range`, exit 1. M's grammar admits a form the binary rejects. |

### Omission tables (M silent; binary + POSIX commit)

**head / tail / cat / wc** (line-and-byte tools)

| id | class | binary verdict |
|---|---|---|
| head-exit-status | omission | missing operand → exit 1, later operand still read. No exit section in M. |
| head-multifile-header | omission | `==>` headers go to **stdout** (2 on stdout, 0 on stderr). M never names the stream. |
| head-c-leading-minus | M=B≠P | `head -c -2` → all-but-last-2 bytes; POSIX forbids the sign. GNU extension M documents. |
| head-legacy-number | omission | `head -2` works (legacy bare-number); M documents only `-n`. |
| tail-exit-status | omission | exit 1 on unreadable operand. No exit section. |
| tail-follow-on-pipe | omission | `tail -f` on pipe-stdin exits promptly (rc 0); M never states -f is ignored there. |
| tail-c-sign-addressing | omission | `-c +2`=1-origin from start (BCDE), `-c 2`=from end (DE). M states neither origin nor no-sign meaning. |
| cat-exit-status | omission | exit 1 on missing operand. No exit section. |
| cat-dash-operand | omission | `cat - -` works (multiple `-`, no reopen). M documents singular `-` only. |
| cat-stdout-purity | omission | diagnostic to stderr, stdout carries only data (2 bytes). M never states the purity. |
| wc-exit-status | omission | continues past missing file, still prints `total`, exit 1. No exit section. |
| wc-option-suppression | omission | `wc -c` → 1 field, `wc` → 3. M's "select which counts" underspecifies the rule. |
| wc-no-operand-format | omission | no-operand output is bare `1\n` (no name, no pad). M never gives the format. |
| wc-total-format | omission | multi-file last line = `8 total`. M states the trigger, not the format. |

**cut / tr / uniq / paste / comm** (field/transform tools)

| id | class | binary verdict |
|---|---|---|
| cut-exit-status | omission | missing file → exit 1, readable file still processed. |
| cut-output-delimiter | omission (GNU ext) | `--output-delimiter` inserts between `-c` ranges (`ab:de`); M's "input delimiter" framing misleads. |
| cut-missing-list | omission | no `-b/-c/-f` → exit 1 `must specify a list`. M says "one and only one", not the error. |
| tr-exit-status | omission | ok → 0, missing string2 → 1. No exit section. |
| **tr-string2-padding** | **commits-where-hedges** | `tr 0-9 d` → all `d` (last char repeated). M **commits** BSD padding; POSIX says *unspecified*. M is the better spec; binary agrees. |
| tr-empty-string | omission (P-undefined) | `tr '' x` → exit 0 no-op (not an error). POSIX undefined; binary commits a benign no-op; M silent. |
| tr-d-with-string2 | omission | `tr -d a b` → exit 1 `extra operand`. M silent on -d + 2 strings. |
| paste-open-failure | omission | unreadable file (without -s) → **no stdout at all**, diagnostic to stderr, exit 1. M silent — strong. |
| paste-eof-padding | omission | short file padded with empty fields (trailing tabs). M silent on unequal lengths. |
| paste-backslash-zero | omission | `-d '\0'` = empty-string separator (`axby`). M documents no escapes at all. |
| paste-stdin-circular | omission | `paste - -` reads stdin circularly into columns. M documents singular `-`. |
| paste-s-empty-file | omission | empty file under `-s` → bare empty line. M silent. |
| comm-exit-unsorted | omission | unsorted input → exit 1 `not in sorted order`. No exit section; default order-check unstated. |
| comm-dash-both-stdin | omission | `comm - -` → exit 1 (bad fd). M says "not both", never the consequence. |
| comm-column-tabs | omission | col2 led by 1 tab, col3 by 2 tabs. M says "three columns", never the tab-lead format. |
| comm-total-summary | omission (GNU ext) | `--total` → `1\t1\t1\ttotal` on stdout. M's "a summary" gives no format/stream. |

**sort / od / expr** (semantically rich)

| id | class | binary verdict |
|---|---|---|
| sort-c-no-stdout | omission | `sort -c` → exit 0, **empty** stdout. M's "do not sort" never states stdout suppression. |
| sort-exit-codes | omission | disorder → 1, open-fail → 2 (the 1-vs-2 split). No exit section. |
| sort-o-same-as-input | omission | `sort -o f f` → safe in-place. M never states `-o` may equal an input. |
| sort-tie-break | omission | key-equal lines fall to whole-line byte compare by default. M only says `-s` disables it. |
| sort-incomplete-newline | omission | trailing `\n` appended to an incomplete last line. M silent. |
| od-final-offset | omission | trailing bare-offset line (`0000004`). M never documents it. |
| od-star-suppression | omission | repeated rows collapse to `*` by default. M only documents `-v`. |
| od-c-escape-set | omission | `\001`→`001`, `\a`, NUL→`\0`. M says only "backslash escapes", never the set/octal fallback. |
| od-partial-nulpad | omission | trailing partial word NUL-padded (`000101`). M silent. |
| expr-precedence | omission | `expr 1 - 2 - 3` → -4 (left-assoc). M never states associativity; POSIX does. |
| expr-leading-plus | M=B (GNU ext) | `expr + match` → `match` (force-string). POSIX leaves these keywords unspecified; M commits. |

**mkdir / rmdir / du** (fs/dir)

| id | class | binary verdict |
|---|---|---|
| **mkdir-p-intermediate-mode** | omission | `umask 777; mkdir -p a/b` → parent mode **300** (u+wx force-added per POSIX `(S_IWUSR\|S_IXUSR\|~mask)&0777`). M says intermediates are "unaffected by -m", never the forced u+wx. |
| mkdir-exit-existing | omission | existing dir without `-p` → exit 1. M's "if they do not already exist" reads benign. |
| mkdir-m-symbolic | omission | `mkdir -m -w y` → mode **577** (symbolic relative to a=rwx, who-less op masked by umask). M's terse "-m MODE" can't derive it. |
| mkdir-trailing-slash | omission | `mkdir z/` → succeeds, creates `z`. M silent on trailing slash. |
| rmdir-exit-nonempty | omission | non-empty dir → exit 1. No exit section. |
| rmdir-p-partial | omission | `-p` ancestor non-empty → exit 1, diagnostic to stderr. M silent on partial failure. |
| rmdir-dot-operand | omission | `rmdir .` → exit 1 (rmdir() forbids). M silent on `.`. |
| du-hardlink-once | omission | hard-linked file counted once by default (24 blocks, not ~44). M documents only `-l`. |
| du-symlink-no-follow | omission | `du -s symlink` → 0 (link itself, not target). M's option blurb omits the observable default. |
| du-total-stream | omission | `-c` grand total lands on **stdout**. M never states the output stream. |

**basename / dirname / readlink / printf** (path + format)

| id | class | binary verdict |
|---|---|---|
| basename-all-slashes | omission | `basename ///` → `/`, `basename usr/` → `usr`. M never describes trailing/all-slash. |
| basename-empty | omission (P-hedges) | `basename ''` → empty (POSIX permits `.` too; GNU picks empty). |
| basename-double-slash | omission | `basename //` → `/` (POSIX makes `//` impl-defined). M silent. |
| basename-stdout-newline | omission | output is `%s\n` to stdout (5 bytes for `sort`). M states it only by contrast with `-z`. |
| dirname-empty | omission | `dirname ''` → `.`. M's rule covers "no /'s", not empty. |
| dirname-double-slash | omission | `dirname /` and `dirname //` → `/`. M states no leading-slash carve-out. |
| dirname-stdout-newline | omission | `%s\n` to stdout (9 bytes). Same as basename. |
| **readlink-nonsym-diagnostic** | contradiction (B≠P) | non-symlink operand → exit 1 but **no diagnostic** (`-s` silent is default). POSIX *requires* a stderr diagnostic. GNU suppresses it. |
| readlink-f-on-nonsym | M=B≠P (GNU ext) | `readlink -f` on a regular file → exit 0 (canonicalizes). POSIX base readlink requires nonzero for non-symlinks. |
| printf-format-reuse | omission | `printf '%s\n' a b c` → 3 lines (format reused). M says only "as in C printf" — the defining utility behavior is unstated. |
| printf-missing-args | omission | `printf '[%s][%d]'` → `[][0]` (missing → empty/zero). M silent. |
| printf-invalid-conversion | omission | `printf '%d' 5a` → outputs `5`, exit 1, continues. M states none of it. |
| printf-leading-quote | omission | `printf '%d' "'A"` → 65 (codeset value). M never mentions the leading-quote rule. |

### Controls (M = P = B; M is correct — recorded for honesty)

`cut` no-delim passthrough; `tr -s` squeeze-on-last-array; `uniq` non-adjacent
no-detect, `-d`/`-u` semantics, field-then-char order; `expr` `:` anchoring,
arithmetic-vs-lexicographic comparison (C locale); `dirname a/b/` → `a`;
`readlink -n` newline suppression. These confirm the mining isn't manufacturing
defects — when M, P, and B agree, the probe says so.

### One refuted candidate

`printf %b` octal: M says octal escapes "should have a leading 0 like `\0NNN`".
The binary accepts **both** `\101` and `\0101` as octal `A` (0x41). M's "should"
is loose but harmless — not a defect. Logged so the count stays honest.

## B vs P conformance (extracted from adjudication)

Where the GNU binary deviates from POSIX regardless of what the docs say:

- **touch `-` operand** — B touches the stdout-associated file; POSIX defines no
  `-` operand (a POSIX `touch -` touches a file named `-`). B != P; M documents B.
- **find `-fprint` (and the large GNU action set) suppresses default `-print`** —
  POSIX suppresses only for `-exec`/`-ok`/`-print`. B != P; M documents B.
- **find `-newer` default does not dereference the reference symlink** — uses the
  link's own mtime under default `-P`. Consistent with POSIX's `-H`/`-L` model;
  the man page's line 1462 ("always dereferenced") is the outlier (M-internal).
- **ls exit-code granularity** — B returns `1`/`2`; POSIX says `0`/`>0`. B
  *refines* P (permitted: "unspecified error conditions may be represented by
  specific values not listed"). Not a violation.
- **ls operand ordering, total line, headers, arrow form** — B matches P exactly;
  the gap is entirely M's (pure omissions, B conformant).

Wave-2 deviations (B ≠ P), several of which the man page *correctly* documents:

- **du default block size** — B uses 1024-byte units (8 blocks for 8192 bytes);
  POSIX mandates 512 unless `POSIXLY_CORRECT`. M documents the 1024 default, so
  M = B ≠ P (a flagged GNU deviation, not a man-page defect).
- **readlink suppresses the non-symlink diagnostic** — POSIX requires a stderr
  diagnostic + nonzero exit for a non-symlink operand; GNU exits nonzero but emits
  **nothing** (`-s` is the default). B ≠ P; M's `-s`-on-by-default note is the
  only hook, and it doesn't state the POSIX violation.
- **expr runtime error exit code** — B returns 2 for division/modulo by zero etc.;
  POSIX reserves 2 for "invalid expression" and wants `>2` for other runtime
  errors. B ≠ P *and* B ≠ M (M says 3). The rare triple-divergence.
- **head `-c -NUM`** — B computes all-but-last-N bytes; POSIX requires the `-c`
  argument be a positive integer (no sign). M = B ≠ P (GNU extension).
- **uniq `-c` count format** — B right-pads the count to a fixed width; POSIX
  pins bare `"%d %s"`. B ≠ P; M never gives the format at all.

Net: GNU coreutils is largely POSIX-conformant in behavior; the documented GNU
deviations are flagged more often than not (touch `-`, find action set, du 1024,
head `-c -N`). The reliability problem remains the man page's *silence*, not GNU's
deviations — and the sharpest single counter-example is **readlink**, where the
binary violates a POSIX "shall" (the diagnostic) and the man page doesn't tell you.

## Omission-fuzzing pass (B-first): verbose-flag stream silence

A distinct engine from M-vs-P mining: probe the binary first, then check whether
M predicts the outcome. Targets the blind spot M-grounded methods can't see.
This pass tested the standing taxonomy § 4.1 hypothesis (stream-convention
silence generalizes across the verbose-flag family) and **confirmed it**:

| util | `-v` narration stream (B) | M names the stream? |
|---|---|---|
| cp | stdout (`'s' -> 'dcopy'`) | no |
| mv | stdout (`renamed 's' -> 'dmoved'`) | no |
| ln | stdout (`'hlink' => 's'`) | no |
| ln -s | stdout (`'slink' -> 's'`) | no |
| rm | stdout (`removed 's'`) | no |
| chmod | stdout (`mode of 's' changed ...`) | no |
| mkdir | stdout (`mkdir: created directory 'ddir'`) | n/a |
| install | stdout (`'s' -> 'idest'`) | no |

Every coreutils `-v` writes narration to stdout; stderr is empty in all 8 cases.
Not one of the 6 man-page `-v` paragraphs names the stream. The class is uniform
across the family. A spec-extractor reading any of these pages must *guess* the
stream, and the natural guess for "informational" output is stderr — wrong every
time. `chmod -v` is worse than silent: its text "output a **diagnostic** for
every file processed" uses POSIX's own word for stderr messages, actively
mis-cueing toward the wrong stream while the binary writes stdout. This is the
omission class with a misleading lexical pointer attached.

## Confirmed defects after this round

- **`--strip-trailing-slashes`** (cp + mv): unconditional doc claim, binary
  contradicts. The clean lie. Scope verified: `install` does **not** carry this
  wording (it has `--strip` / `--strip-program`, unrelated), so the defect is
  confined to cp/mv. (See round_02 + `_hardening/` dirs.)
- **find `-newer` "always dereferenced"** (line 1462): false in trixie + internally
  contradicted by the same man page.
- **EXIT STATUS systematic omission**: 25/28 corpus man pages document no exit
  status at all (deterministic, from frozen texts); of the 3 that do, `expr`
  documents it *incorrectly* (says 3, binary 2).
- **ln `-f a a` data-loss**: M's `-f` wording, taken literally, specifies an
  operation POSIX forbids precisely because it destroys data.
- **ls `-1` does not disable long format**: M's one-line `-1` description
  contradicts the binary (which follows POSIX).
- **od "octal bytes by default"** (line 12): the binary's default is octal
  *shorts* (`-t oS`) — contradicted by od's own EXAMPLES section and POSIX.
- **expr "3 if an error occurred"**: binary returns 2 for every runtime error
  (div-by-zero, non-integer, bad operator). The documented code is unreachable.
- **basename unconditional suffix removal**: `basename foo foo` → `foo`, not
  empty; M omits the POSIX step-6 guard (suffix == whole name is not removed).
- **readlink silent on non-symlink**: POSIX requires a stderr diagnostic; GNU
  emits none (a POSIX "shall" violated, undocumented).
- **tail `-n +0`**: M's "skip NUM-1 lines" formula yields nonsense for +0; the
  binary outputs the whole file.
- **cut decreasing range**: M's `N-M` grammar admits `5-2`; the binary rejects it
  (`invalid decreasing range`, exit 1).

## How to find more (the engine menu)

- **A. M vs P mining** (waves 1+2): deterministic, free, high-yield. Scaled to 27
  utils. Remaining POSIX coreutils with pages: cksum, csplit, expand, fold, join,
  nl, pr, split, tee, unexpand, plus the env/id/sleep/date family.
- **B. B vs P conformance**: probe the binary against POSIX directly — finds GNU
  deviations regardless of docs. Now a standalone deliverable:
  `scripts/eval/omission_fuzz.sh` codifies the B-first sweep. Surface is small but
  the readlink "shall"-violation shows it isn't empty.
- **C. Omission-fuzzing** (Class 1 at scale): `scripts/eval/omission_fuzz.sh`
  enumerates the M-blind behavior classes (exit status, stream routing, error
  continuation) and reports, per util, which the man page names. Reusable across
  the corpus; EXIT STATUS is the structural instance it formalizes.
- **D. Corpus scaling**: ~10 POSIX coreutils pages remain (see A). `install`,
  `sudo` are frozen but out of POSIX scope.
- **E. Cross-utility wording propagation**: shared man-page fragments propagate
  defects (proven by `--strip-trailing-slashes` across cp + mv; **negative** for
  install). The EXIT STATUS omission is the largest shared-template defect, now
  quantified at 25/28.
- **F. Diversify the M-vs-B testers**: per-tester attack lenses + loop-until-dry.

## Reproduce

Mining: 5 parallel opus subagents diffing `utils/<u>/manpage.txt` vs
`docs/posix/utilities/<u>.md` (+ basedefs), grouped by family, carrying the
full-governing-span guard ([[sudo-d-candidate-killed]]).

Behavioral adjudication (trixie, coreutils 9.7, non-root):
- Wave 1: `scratchpad/mp_adjudicate.sh`
- Wave 2: `scratchpad/mp_adjudicate2.sh` + `scratchpad/expr_reprobe.sh`
- run: `docker run --rm -u 1000:1000 -e HOME=/tmp -v .../<probe>.sh:/probe.sh:ro debian:trixie bash /probe.sh`

EXIT STATUS finding: `grep -niE '^(EXIT STATUS|RETURN VALUE)' utils/*/manpage.txt`.
Omission-fuzz sweep: `scripts/eval/omission_fuzz.sh [util...]`.
