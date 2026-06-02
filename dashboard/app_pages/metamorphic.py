"""Metamorphic floor — hand-written, non-LLM invariants run against real GNU."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import streamlit as st

from data import all_metamorphic

meta = all_metamorphic()

st.markdown(
    "The metamorphic floor is a set of **hand-written, non-LLM** invariant tests (e.g. copy-then-"
    "read round-trips) run against the real GNU binary in trixie. It is the sanity floor: if these "
    "ever fail, the harness or container is broken, not the model. Everything here should be green."
)

if meta.empty:
    st.info("No metamorphic results yet. Run `scripts/eval/run_metamorphic.sh <util>`.")
    st.stop()

total = len(meta)
passed = int(meta["pass"].sum())
with st.container(horizontal=True):
    st.metric("Utilities", meta["util"].nunique(), border=True)
    st.metric("Invariant tests", total, border=True)
    st.metric("Passing", f"{passed}/{total}", border=True)
    floor_ok = passed == total
    st.metric("Floor", "green" if floor_ok else "BROKEN", border=True,
              delta=None if floor_ok else "investigate harness", delta_color="inverse")

st.markdown("### Per-utility")
summary = (
    meta.groupby("util")["pass"]
    .agg(tests="count", passing="sum")
    .reset_index()
)
summary["status"] = summary.apply(
    lambda r: "all pass" if r["passing"] == r["tests"] else f"{r['tests'] - r['passing']} FAIL",
    axis=1,
)
st.dataframe(summary, hide_index=True, width="stretch")

st.markdown("### Per-test")
for util in sorted(meta["util"].unique()):
    sub = meta[meta["util"] == util]
    with st.expander(f"`{util}` — {int(sub['pass'].sum())}/{len(sub)} pass"):
        for _, r in sub.iterrows():
            mark = "✅" if r["pass"] else "❌"
            st.write(f"{mark} `{r['name']}` · rc `{r.get('rc')}`")
            if not r["pass"]:
                cap = r.get("captured") or ""
                if cap:
                    st.code(cap[:1500])
