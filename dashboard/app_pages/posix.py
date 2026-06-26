"""Man-page vs POSIX — the divergence engine and the omission-dominant thesis.

The tables here are the citation-grade distillation; the full catalog
(runs/_posix_divergence_catalog_*.md) is rendered verbatim at the bottom.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pandas as pd
import streamlit as st

from data import load_posix_catalog

st.markdown(
    "Three sources describe each utility: the GNU **man page (M)**, the real GNU "
    "**binary (B)** in Debian trixie, and the **POSIX standard (P)**. Diffing M "
    "against P and settling every disagreement against B is deterministic, spends no "
    "API budget, and is far higher-yield than the man-page-vs-binary differential "
    "(~185 divergences across 45 utilities vs ~1 per utility). It also reframed the "
    "thesis: **the man page's dominant failure as a spec source is omission, not "
    "falsehood.** An LLM reading only the man page cannot recover what the page never "
    "states, and exit-status semantics are the flagship of what it never states."
)

with st.container(horizontal=True):
    st.metric("Utilities mined", "45", help="47 frozen incl. install + sudo; 45 POSIX-relevant", border=True)
    st.metric("Divergences", "~185", help="binary-adjudicated across 3 waves", border=True)
    st.metric("Omission share", "~85%", help="of ~120 class-tagged divergences", border=True)
    st.metric("Exit-status silent", "41 / 47", help="man pages with no exit-status text at all", border=True)

st.caption(
    "Provenance: candidates from diffing two frozen authoritative texts (no LLM-generated impl, "
    "no OpenAI spend); every verdict is the real GNU binary in `debian:trixie` (coreutils 9.7 / "
    "findutils 4.10.0), probed non-root to avoid the root confound."
)

# --- Three-class taxonomy ---------------------------------------------------
st.markdown("### The three-class taxonomy (M vs P)")
st.dataframe(
    pd.DataFrame(
        [
            {"Class": "Omission — posix-requires / man-page-silent", "Share": "~85%",
             "What it means": "POSIX and the binary commit to a behavior the man page never documents. A man-page-only spec misses it. Dominant class."},
            {"Class": "Commits-where-POSIX-hedges", "Share": "~9%",
             "What it means": "The man page pins down behavior POSIX leaves unspecified, and the binary agrees. Here the man page is a BETTER spec than POSIX."},
            {"Class": "Contradiction / deviation", "Share": "~6%",
             "What it means": "Man page and binary directly disagree (rare lie), or the man page documents a deliberate GNU deviation from POSIX (M=B≠P)."},
        ]
    ),
    hide_index=True,
    width="stretch",
)

# --- EXIT STATUS flagship ---------------------------------------------------
st.markdown("### Flagship omission: EXIT STATUS")
st.markdown(
    "Exit status is exactly what a formal spec must capture — it is the program's "
    "contract. Across the 47-page frozen corpus, only **`find`** carries a real "
    "top-level EXIT STATUS section. **41 of 47** say nothing at all. Of the few that "
    "speak, one is wrong and one names no values:"
)
st.dataframe(
    pd.DataFrame(
        [
            {"Utility": "find", "What M says about exit status": "full EXIT STATUS section", "Verdict": "correct"},
            {"Utility": "env", "What M says about exit status": "125 / 126 / 127 inline", "Verdict": "correct — binary matches (not-found→127, non-exec→126)"},
            {"Utility": "ls", "What M says about exit status": "0/1/2 subsection", "Verdict": "over-specified — POSIX says 0/>0; a permitted refinement"},
            {"Utility": "expr", "What M says about exit status": '"3 if an error occurred"', "Verdict": "WRONG — binary returns 2 for every runtime error; 3 unreachable"},
            {"Utility": "test", "What M says about exit status": '"status determined by EXPRESSION"', "Verdict": "no numeric values — binary commits exit 2 on a malformed expression"},
            {"Utility": "other 41", "What M says about exit status": "nothing", "Verdict": "silent — a spec-extractor must guess"},
        ]
    ),
    hide_index=True,
    width="stretch",
)
st.caption("When the man page is silent a spec-extractor must guess; when it speaks it is right only about half the time.")

# --- New contradiction sub-class --------------------------------------------
st.markdown("### New sub-class: the man page documents constructs the standard *deleted*")
st.info(
    "`test -a` / `-o` / `(` / `)` were **removed** by POSIX Issue 8 (Austin Group Defect 1330), "
    "and `-l STRING` was excluded (its job moved to the shell). GNU still runs all of them (every "
    "one exits 0), and the man page lists them as live primaries with **no deprecation note**. "
    "So a man-page-only spec encodes constructs the standard no longer defines. M = B ≠ P."
)

# --- Minimal repros ---------------------------------------------------------
st.markdown("### Citation-grade minimal repros (paper-ready)")
st.markdown(
    "The shortest command that demonstrates each finding, with the observed trixie output "
    "(coreutils 9.7 / findutils 4.10.0, uid 1000). Verified together via "
    "`scratchpad/minimal_repros.sh`. This is the \"run this, see that\" a §7.2 writeup cites."
)
st.dataframe(
    pd.DataFrame(
        [
            {"Finding": "cp --strip-trailing-slashes is not unconditional", "Command": "cp --strip-trailing-slashes src/ dst  (src a regular file)", "Observed": "exit 1: cp: cannot stat 'src/': Not a directory", "Divergence": "M says it strips slashes unconditionally; cp stats the slashed path first and fails. mv mirrors it. The clean lie."},
            {"Finding": "od default is octal shorts, not bytes", "Command": "printf AB | od", "Observed": "0000000 041101", "Divergence": 'octal short (LE 0x4241), not two octal bytes. M says "octal bytes by default" — contradicting od\'s own EXAMPLES + POSIX.'},
            {"Finding": "expr runtime error → exit 2", "Command": "expr 1 / 0", "Observed": "exit 2", "Divergence": 'M says "3 if an error occurred"; 3 is unreachable (GMP build).'},
            {"Finding": "basename keeps a whole-name suffix", "Command": "basename foo foo", "Observed": "foo", "Divergence": "M's unconditional \"remove SUFFIX\" reading yields empty; POSIX step-6 guard keeps it. A data-shape trap."},
            {"Finding": "tail +0 → whole file", "Command": "printf 'a\\nb\\nc\\n' | tail -n +0", "Observed": "a b c", "Divergence": 'M\'s "skip NUM-1 lines" is nonsense at +0; the binary clamps to all.'},
            {"Finding": "cut decreasing range rejected", "Command": "echo abcdef | cut -c5-2", "Observed": "exit 1: invalid decreasing range", "Divergence": "M's N-M grammar admits a form the binary refuses."},
            {"Finding": "readlink silent on a non-symlink", "Command": "readlink regularfile", "Observed": "exit 1, stderr empty", "Divergence": 'POSIX: "shall write a diagnostic message to standard error." GNU writes none — a POSIX "shall" violated, undocumented.'},
            {"Finding": "df default 1K, not POSIX 512", "Command": "df / ; POSIXLY_CORRECT=1 df /", "Observed": "block counts differ 2.0×", "Divergence": "M = B ≠ P (documented GNU deviation; the du parallel)."},
            {"Finding": "pr header date is ISO", "Command": "printf 'x\\n' | pr | sed -n 3p", "Observed": "2026-06-26 15:01 ...", "Divergence": 'POSIX mandates date "+%b %e %H:%M %Y" (Jun 26 15:01 2026). B ≠ P, M silent on the format.'},
            {"Finding": "nl numbers multiple files", "Command": "nl f1 f2", "Observed": "1\\ta then 2\\tb (continuous)", "Divergence": 'POSIX: "only one file can be named." M\'s [FILE]... synopsis sides with GNU.'},
            {"Finding": "test documents deleted primaries", "Command": "test 1 -eq 1 -a 2 -eq 2 ; test -l abc -eq 3", "Observed": "both exit 0", "Divergence": "POSIX Issue 8 removed -a/-o/(/) (Austin Group Defect 1330) and excluded -l."},
            {"Finding": "tee - is a filename", "Command": "printf X | tee -", "Observed": "creates file ./- containing X", "Divergence": "POSIX: `-` shall NOT mean standard output. M silent — high mislead risk."},
            {"Finding": "echo escapes off by default", "Command": "echo 'a\\tb'", "Observed": "a\\tb (literal)", "Divergence": "POSIX-XSI recognizes \\t unconditionally; GNU needs -e. M commits the opposite."},
        ]
    ),
    hide_index=True,
    width="stretch",
)

# --- Honesty notes ----------------------------------------------------------
st.markdown("### Methodology honesty (candidates killed / corrected)")
st.markdown(
    "Every candidate was re-verified against the real binary, and findings that did not hold were "
    "thrown out rather than shipped:\n"
    "- **Killed:** sudo `-D`/`--chdir` looked like a man-page defect but is a documented policy gate "
    "— a false positive from naive substring matching (the full-governing-span guard caught it).\n"
    "- **Corrected:** `ln -f a a` is *not* data loss — coreutils 9.7 guards self-links "
    "(`'a' and 'a' are the same file`, bytes intact). It is a documentation hazard only (M's literal "
    "`-f` wording), excluded from the repros above (no binary repro exists).\n"
    "- **Refuted:** `printf %b` octal — M's \"should have a leading 0\" is loose but harmless; the "
    "binary accepts both `\\101` and `\\0101`. Logged so the count stays honest.\n"
    "- **Controls:** when M, P, and B agree, the probe says so (recorded per wave) — the mining is "
    "not manufacturing defects."
)

# --- Full catalog -----------------------------------------------------------
st.divider()
catalog = load_posix_catalog()
if catalog:
    with st.expander("Full catalog — everything (runs/_posix_divergence_catalog_*.md)"):
        st.markdown(catalog)
else:
    st.info("Catalog file not found under runs/.")
