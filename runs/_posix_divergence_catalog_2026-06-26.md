# Man-page vs POSIX divergence catalog (2026-06-26)

A new defect-discovery engine, and the result that reframes the project's thesis.

> **Provenance note.** Unlike the Claude sweeps, this catalog does NOT depend on
> any LLM-generated impl. Candidates come from comparing two frozen authoritative
> texts (GNU man page `utils/<u>/manpage.txt` vs POSIX mirror
> `docs/posix/utilities/<u>.md` + basedefs), and each verdict is the real GNU
> binary in trixie (coreutils 9.7 / findutils 4.10.0). The mining step used Claude
> subagents (no OpenAI spend); the adjudication is deterministic shell probes.
> This is firmer ground than the M-vs-impl differential.

## Why this engine

The M-vs-binary differential (the Claude sweeps) mines ONE of three disagreement
axes and is structurally blind to omissions. There are three sources — man page
(M), real binary (B), POSIX (P) — and three axes:

| axis | finds | status |
|---|---|---|
| M vs B | documented-but-false (overcommitment) | mined; low yield, LLM-convergent |
| **M vs P** | man page contradicts / diverges from the standard | this catalog |
| B vs P | GNU binary deviates from the standard | next |
| M silent, B acts | undocumented behavior (omission) | surfaced here as a side effect |

## The reframed thesis

The man page's dominant failure as a spec source is **omission, not falsehood**.
Outright lies (M contradicts B) are rare. Far more common: the man page is silent
where POSIX and the binary commit. The GNU `cp` man page has **no EXIT STATUS
section at all** — a spec-extractor cannot recover even pass/fail semantics from
it. "Can an LLM build a trustworthy spec from the man page?" becomes "the man page
is a *characterizably incomplete* spec source," which is sharper and more useful
for Astrogator POPL 2027 §7.2.

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
| C4 | exit status + continue-on-error after a per-file failure | **omission** | exit=1, remaining operands still copied. **The cp man page has no exit-status section.** Foundational omission. |
| C3 | overwrite of an existing regular file | **omission** | keeps perms (700) AND inode (O_TRUNC in place), POSIX-mandated; man page silent. A spec-extractor would assume the source's mode. |
| C1 | `-R` symlink default (no `-H`/`-L`/`-P`) | omission / latitude | POSIX unspecified; man page silent; binary = `-P` (copies the link). |
| C2 | `-i` with a non-affirmative / EOF response | omission | binary skips (keeps old), exit=1 on EOF; man page says only "prompt before overwrite". |
| C5 | same-file `cp a a` | commits-where-hedges | POSIX: "may" no-op; binary errors exit=1; man page documents only the `-f --backup` special case, not the default error. |

### find (findutils 4.10.0)

| # | behavior | class | binary verdict |
|---|---|---|---|
| F1 | which actions suppress the implicit `-print` | **contradiction (M=B != P)** | `find . -fprint X` → stdout empty. Binary follows the GNU page (large suppress set); POSIX suppresses only for `-exec`/`-ok`/`-print`. GNU documents a POSIX deviation. (Corroborates round_02 test 014.) |
| F3 | `-newer` symlink-reference dereference | **contradiction (intra-doc + M vs B)** | man page line 1462 says "always dereferenced"; lines 624-628/282-284 say conditional on `-H`/`-L`. Binary (default `-P`) does NOT dereference (uses the link's own mtime). Line 1462 is false/stale. |
| F2 | `{}` replaced as a substring of an `-exec` arg | commits-where-hedges | `echo pre{}post` → `pre./fpost`. Binary = GNU ("everywhere it occurs"); POSIX impl-defined. |

### mv (coreutils 9.7; adjudicated by the mining subagent)

| # | behavior | class | binary verdict |
|---|---|---|---|
| M1 | prompt when dest unwritable + stdin is a terminal, without `-i` | **omission / contradiction** | POSIX mandates the prompt; man page documents prompting only via `-i`; binary does NOT prompt (overwrites). Man page omits a POSIX interaction point; binary sides with the man page over POSIX. |
| M2 | `-n` / `--update=none` skip exit status | commits-where-hedges | binary exit=0 on skip; GNU commits to this; POSIX's exit-0 carve-out covers only non-affirmative prompt responses. |
| M3 | `-i`/`-f`/`-n` precedence | commits-where-hedges | binary = last-of-three (GNU); POSIX defines last-of-(`-f`/`-i`) only. |
| M4 | trailing slash on a non-directory target | contradiction | POSIX: hard error, no operands processed; relates to the confirmed `--strip-trailing-slashes` finding. |

Not deterministically probed (candidates): cp `-p` setuid/setgid clearing on
chown failure (needs non-root + setuid source); mv cross-device characteristic-copy
exit-status rule and copy-then-delete completeness guarantee.

## Confirmed defects after this round

- **`--strip-trailing-slashes`** (cp + mv): unconditional doc claim, binary
  contradicts. The clean lie. (See round_02 + `_hardening/` dirs.)
- **find `-newer` "always dereferenced"** (line 1462): false in trixie + internally
  contradicted by the same man page. Strong; remaining step is reading the man
  page HISTORY section it references to characterize the version story.

## How to find more (the engine menu)

- **A. M vs P mining** (this round): deterministic, free, high-yield. Scale to more utils.
- **B. B vs P conformance**: probe the binary against POSIX directly — finds GNU
  deviations regardless of what the docs say.
- **C. Omission-fuzzing** (Class 1 at scale): generate behaviors NOT grounded in M,
  run B, check whether M predicts the outcome. Targets the omission class the
  M-grounded method is blind to.
- **D. Corpus scaling**: more utils (ls, rm, ln, chmod, touch, mkdir, install).
  `install` shares the `--strip-trailing-slashes` wording — likely recurs.
- **E. Cross-utility wording propagation**: shared man-page fragments propagate
  defects (proven by strip-trailing-slashes across cp + mv).
- **F. Diversify the M-vs-B testers**: per-tester attack lenses + loop-until-dry to
  fix the convergence that capped the Claude sweeps.

## Reproduce

Mining: 3 Claude subagents diffing `utils/<u>/manpage.txt` vs `docs/posix/utilities/<u>.md`.
Adjudication probes: see this session's transcript; each is a self-contained
`docker run --rm debian:trixie-slim` one-liner.
