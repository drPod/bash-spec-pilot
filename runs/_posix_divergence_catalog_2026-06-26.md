# Man-page vs POSIX divergence catalog (2026-06-26)

A defect-discovery engine, and the result that reframes the project's thesis.
Now spanning 8 utilities (cp, mv, find, ls, rm, ln, chmod, touch), ~42
binary-adjudicated divergences.

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

Net: GNU coreutils is largely POSIX-conformant in behavior; the documented GNU
deviations are few (touch `-`, find action set) and the man page usually *flags*
them. The reliability problem is the man page's silence, not GNU's deviations.

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
- **EXIT STATUS systematic omission**: 7/8 coreutils man pages document no exit
  status at all (deterministic, from frozen texts).
- **ln `-f a a` data-loss**: M's `-f` wording, taken literally, specifies an
  operation POSIX forbids precisely because it destroys data.
- **ls `-1` does not disable long format**: M's one-line `-1` description
  contradicts the binary (which follows POSIX).

## How to find more (the engine menu)

- **A. M vs P mining** (this round): deterministic, free, high-yield. Scaled to 8
  utils; can extend to mkdir, rmdir, mkfifo, head, tail, cat, sort, etc.
- **B. B vs P conformance**: probe the binary against POSIX directly — finds GNU
  deviations regardless of docs. Demonstrated above; the surface is small.
- **C. Omission-fuzzing** (Class 1 at scale): enumerate behaviors NOT grounded in
  M (exit status, stream routing, error continuation, timestamp side effects,
  trailing-slash resolution), probe B, check whether M predicts. This is what
  surfaced the dominant class; EXIT STATUS is the structural instance.
- **D. Corpus scaling**: more utils. `install` is frozen but out of POSIX scope.
- **E. Cross-utility wording propagation**: shared man-page fragments propagate
  defects (proven by `--strip-trailing-slashes` across cp + mv; **negative** for
  install). The EXIT STATUS omission is the largest shared-template defect.
- **F. Diversify the M-vs-B testers**: per-tester attack lenses + loop-until-dry.

## Reproduce

Mining: Claude subagents diffing `utils/<u>/manpage.txt` vs `docs/posix/utilities/<u>.md`.
Behavioral adjudication: `scratchpad/mp_adjudicate.sh` (this session), run
`docker run --rm -u 1000:1000 -e HOME=/tmp -v .../mp_adjudicate.sh:/probe.sh:ro debian:trixie bash /probe.sh`.
EXIT STATUS finding: `grep -niE '^(EXIT STATUS|RETURN VALUE)' utils/*/manpage.txt`.
