"""Research findings catalogue — every manpage_underspec row across runs/."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import streamlit as st

from data import all_underspec, load_crossver

underspec = all_underspec()

st.markdown(
    "A **manpage under-spec** is a test that quotes a man-page line verbatim, follows it exactly, "
    "and is still rejected by the real GNU binary. The Rust impl — which read the same line — "
    "agrees with the documentation, so the impl looks *more* correct than reality. These are the "
    "research findings: places where a spec language mined from the manpage would be wrong."
)

if underspec.empty:
    st.info("No manpage under-spec findings yet. Run an adversarial round and classify it.")
    st.stop()

with st.container(horizontal=True):
    st.metric("Findings", len(underspec), border=True)
    st.metric("Utilities affected", underspec["util"].nunique(), border=True)
    st.metric("Sessions", underspec[["util", "session"]].drop_duplicates().shape[0], border=True)

# Cross-version stability lookup, keyed by util.
crossver = {res["util"]: res for res in load_crossver()}

st.markdown("### Catalogue")
for _, r in underspec.iterrows():
    util = r["util"]
    with st.container(border=True):
        head = st.columns([3, 1])
        with head[0]:
            st.markdown(f"**`{util}` · {r['name']}**")
            st.caption(f"{r['session']} · round {r['round']} · mode {r.get('mode', '?')}")
        with head[1]:
            cv = crossver.get(util)
            if cv is not None:
                if cv.get("version_stable"):
                    st.success("version-stable")
                else:
                    st.warning("version-specific")

        st.markdown("**Manpage quote (the line the test leaned on):**")
        st.markdown(f"> {r.get('manpage_quote', '')}")

        st.markdown(f"**Exercises:** {r.get('exercises', '')}")
        st.markdown(f"**Expected (per the manpage):** {r.get('expected', '')}")

        cols = st.columns(2)
        with cols[0]:
            with st.container(border=True):
                st.markdown("**Real GNU**")
                st.write(f"rc: `{r.get('real_rc')}`")
                head_list = r.get("real_stderr_head") or []
                if isinstance(head_list, list) and head_list:
                    st.code("\n".join(str(h) for h in head_list))
        with cols[1]:
            with st.container(border=True):
                st.markdown("**Rust impl (followed the manpage)**")
                st.write(f"rc: `{r.get('rust_rc')}`")
                st.caption("Stripped the slash and moved, exactly as documented.")

        if cv is not None:
            with st.expander("Cross-version replay"):
                st.markdown(f"`{cv.get('repro', '')}`")
                for v in cv.get("versions") or []:
                    flag = "reproduces" if v.get("reproduces_finding") else "does NOT reproduce"
                    st.write(
                        f"coreutils `{v.get('pinned_version')}` "
                        f"(reported `{v.get('reported_version')}`): rc `{v.get('rc')}` — {flag}"
                    )
