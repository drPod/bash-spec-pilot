"""Narrative landing page — the experiment, the method, the findings, the proof."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import streamlit as st

from data import (
    all_divergences,
    all_underspec,
    discover_classifications,
    discover_rounds,
    load_crossver,
)

rounds = discover_rounds()
rounds = rounds[rounds["tests_generated"] > 0].copy()
underspec = all_underspec()
divergences = all_divergences()
clf = discover_classifications()
crossver = load_crossver()

# Headline numbers.
n_underspec = len(underspec)
n_divergence = len(divergences)
best_mut = clf["mut_at_k"].max() if not clf.empty else 0.0
adversarial_sessions = (
    rounds[rounds["mode"] != "baseline"][["util", "session"]].drop_duplicates().shape[0]
    if not rounds.empty
    else 0
)
n_utils = rounds["util"].nunique() if not rounds.empty else 0
spend = float(rounds["est_cost_usd"].sum()) if not rounds.empty else 0.0

with st.container(horizontal=True):
    st.metric("Manpage under-specs", n_underspec, border=True,
              help="Tests that followed the documented text verbatim yet the real binary rejected — the manpage lies.")
    st.metric("Impl divergences", n_divergence, border=True,
              help="Real GNU correct, LLM Rust impl wrong — bugs the adversarial tests caught.")
    st.metric("Best mut@k", f"{best_mut:.3f}", border=True,
              help="divergences / scored tests, the headline kill rate of an adversarial round.")
    st.metric("Adversarial sessions", adversarial_sessions, border=True)
    st.metric("Utilities", n_utils, border=True)
    st.metric("API spend", f"${spend:.2f}", border=True)

st.divider()

# 1 — the question.
st.markdown("## 1 · The question")
st.markdown(
    "Astrogator formally verifies LLM-generated code against a user-confirmed query. Its paper "
    "names Bash as a future target, but a Bash verifier needs per-utility formal semantics that no "
    "public source provides. This experiment asks the prerequisite question: **can an LLM go from a "
    "Linux man page straight to an implementation that matches the real GNU utility, and what does "
    "it get wrong when it can't?** Rust stands in for the not-yet-existent Bash spec language."
)

# 2 — the method.
st.markdown("## 2 · The method")
c1, c2, c3 = st.columns(3)
with c1:
    with st.container(border=True):
        st.markdown("**Generate**")
        st.markdown(
            "From a frozen Debian-trixie man page, the model writes a Rust impl **and** a Bash test "
            "suite. Adversarial test variants are generated in a separate conversation so the impl's "
            "misreadings can't leak into the tests."
        )
with c2:
    with st.container(border=True):
        st.markdown("**Differential test**")
        st.markdown(
            "Every test runs twice in a pinned trixie container: once against the real GNU binary "
            "(the oracle), once against the Rust impl. Disagreement is the signal."
        )
with c3:
    with st.container(border=True):
        st.markdown("**Classify**")
        st.markdown(
            "Each disagreement lands in one of five buckets. The interesting two: the impl is wrong "
            "(a **divergence**), or the impl followed the manpage and the *manpage* is wrong (a "
            "**manpage under-spec**)."
        )

# 3 — the five buckets.
st.markdown("## 3 · The five buckets")
st.markdown(
    "Real-vs-Rust correctness splits every scored test into a 2×2, and the one off-diagonal cell "
    "where the impl looks *more* correct than reality is split again by provenance grounding."
)
st.table(
    {
        "Bucket": [
            "baseline", "divergence", "shared_bug", "hallucinated_spec", "manpage_underspec",
        ],
        "real GNU": ["correct", "correct", "wrong", "wrong", "wrong"],
        "Rust impl": ["correct", "wrong", "wrong", "correct", "correct"],
        "Meaning": [
            "both right — no signal",
            "impl bug the test caught (headline mut@k)",
            "both wrong the same way",
            "test cites no manpage line — noise",
            "test quotes the manpage verbatim — the manpage lies",
        ],
    }
)

# 4 — the findings.
st.markdown("## 4 · The findings")
if underspec.empty:
    st.info("No manpage under-spec findings recorded yet.")
else:
    st.markdown(
        f"**{n_underspec}** test{'s' if n_underspec != 1 else ''} followed the documented text "
        "exactly and the real binary still rejected the call. Each one is a place where a spec "
        "language built from the manpage would describe behavior the binary does not have."
    )
    for _, r in underspec.iterrows():
        with st.container(border=True):
            st.markdown(f"**`{r['util']}` · {r['name']}**")
            st.markdown(f"> {r.get('manpage_quote', '')}")
            real_head = r.get("real_stderr_head") or []
            real_msg = real_head[0] if isinstance(real_head, list) and real_head else ""
            st.markdown(
                f"The manpage says the slash is stripped. The Rust impl read that literally and "
                f"the move succeeded (`rc={r.get('rust_rc')}`). Real GNU `{r['util']}` rejected it "
                f"with `rc={r.get('real_rc')}`:"
            )
            if real_msg:
                st.code(real_msg)

# 5 — the proof.
st.markdown("## 5 · Is it real, or a 9.7 quirk?")
if not crossver:
    st.info("No cross-version replay recorded yet.")
else:
    for res in crossver:
        with st.container(border=True):
            st.markdown(f"**`{res['util']}` — replayed across coreutils versions**")
            st.markdown(f"`{res.get('repro', '')}`")
            vers = res.get("versions") or []
            badge_cols = st.columns(len(vers)) if vers else []
            for col, v in zip(badge_cols, vers):
                with col:
                    ok = v.get("reproduces_finding")
                    st.metric(
                        f"coreutils {v.get('pinned_version')}",
                        "reproduces" if ok else "no repro",
                        border=True,
                    )
            stable = res.get("version_stable")
            verified = res.get("all_versions_verified")
            st.markdown(
                f"**version-stable: `{stable}`** · all versions verified: `{verified}` · "
                f"arch: `{res.get('container_arch', '?')}`"
            )

st.divider()
st.markdown(
    "The Rust impl matched the manpage. Real `mv` didn't. The LLM didn't mess up — the manpage "
    "lied. That is the whole point: a Bash spec language mined from man pages would inherit the "
    "lie. Use the sidebar for the per-finding catalogue, the adversarial scorecard, the divergence "
    "browser, and the hand-written quality floor."
)
