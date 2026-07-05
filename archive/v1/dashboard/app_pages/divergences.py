"""Divergence browser — real GNU correct, Rust impl wrong, across all runs/."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import streamlit as st

from data import all_divergences

div = all_divergences()

st.markdown(
    "A **divergence** is a test the real GNU binary passes and the LLM Rust impl fails — a genuine "
    "implementation bug the adversarial test caught. These feed mut@k. The Rust impl is "
    "LLM-generated and not a trusted oracle, so a divergence is a finding about *the impl*, not "
    "about the manpage."
)

if div.empty:
    st.info("No divergences recorded yet.")
    st.stop()

with st.container(horizontal=True):
    st.metric("Divergences", len(div), border=True)
    st.metric("Utilities", div["util"].nunique(), border=True)
    st.metric("Sessions", div[["util", "session"]].drop_duplicates().shape[0], border=True)

utils = sorted(div["util"].unique())
pick = st.sidebar.multiselect("Utilities", utils, default=utils)
div = div[div["util"].isin(pick)]

st.markdown("### Divergences")
for _, r in div.iterrows():
    with st.container(border=True):
        st.markdown(f"**`{r['util']}` · {r['name']}**")
        st.caption(f"{r['session']} · round {r['round']} · mode {r.get('mode', '?')}")
        st.markdown(f"**Exercises:** {r.get('exercises', '')}")
        st.markdown(f"**Expected:** {r.get('expected', '')}")

        cols = st.columns(2)
        with cols[0]:
            with st.container(border=True):
                st.markdown("**Real GNU (correct)**")
                st.write(f"rc: `{r.get('real_rc')}`")
                head = r.get("real_stderr_head") or []
                if isinstance(head, list) and head:
                    st.code("\n".join(str(h) for h in head))
        with cols[1]:
            with st.container(border=True):
                st.markdown("**Rust impl (wrong)**")
                st.write(f"rc: `{r.get('rust_rc')}`")
                head = r.get("rust_stderr_head") or []
                if isinstance(head, list) and head:
                    st.code("\n".join(str(h) for h in head))
