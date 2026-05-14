"""Per-test failure browser — pivot GNU vs Rust outcomes side by side."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pandas as pd
import streamlit as st

from data import discover_rounds, load_manifest, load_observations, load_results

rounds = discover_rounds()
rounds = rounds[rounds["tests_generated"] > 0].copy()
if rounds.empty:
    st.warning("No rounds yet.")
    st.stop()

util = st.sidebar.selectbox("Utility", sorted(rounds["util"].unique()))
util_rounds = rounds[rounds["util"] == util].sort_values(["session", "round"])
session = st.sidebar.selectbox("Session", util_rounds["session"].unique())
session_rounds = util_rounds[util_rounds["session"] == session]
round_n = st.sidebar.selectbox("Round", session_rounds["round"].tolist())

gnu = load_results(util, session, round_n, "real-gnu")
rust = load_results(util, session, round_n, "rust")
manifest = load_manifest(util, session, round_n)

if gnu.empty and rust.empty:
    st.warning("No results jsonl for this round yet.")
    st.stop()

# Pivot: one row per test, columns = GNU status, Rust status, exercises, expected.
m = manifest.set_index("filename") if not manifest.empty else pd.DataFrame()
gnu_idx = gnu.set_index("name")[["status", "rc", "stderr"]].rename(
    columns={"status": "GNU status", "rc": "GNU rc", "stderr": "GNU stderr"}
) if not gnu.empty else pd.DataFrame()
rust_idx = rust.set_index("name")[["status", "rc", "stderr"]].rename(
    columns={"status": "Rust status", "rc": "Rust rc", "stderr": "Rust stderr"}
) if not rust.empty else pd.DataFrame()

combined = m.join(gnu_idx, how="outer").join(rust_idx, how="outer").reset_index().rename(columns={"index": "test"})
combined = combined.rename(columns={"filename": "test"}) if "filename" in combined.columns else combined

# Outcome quadrant.
def quadrant(row):
    g = row.get("GNU status")
    r = row.get("Rust status")
    if pd.isna(g) or pd.isna(r):
        return "missing"
    if g == "pass" and r == "pass":
        return "both pass"
    if g == "pass" and r != "pass":
        return "GNU pass, Rust fail"
    if g != "pass" and r == "pass":
        return "GNU fail, Rust pass (drift!)"
    return "both fail"

combined["quadrant"] = combined.apply(quadrant, axis=1)

quad_filter = st.sidebar.multiselect(
    "Show quadrants",
    options=combined["quadrant"].unique().tolist(),
    default=combined["quadrant"].unique().tolist(),
)
combined = combined[combined["quadrant"].isin(quad_filter)]

# Outcome quadrant counts.
counts = combined["quadrant"].value_counts()
with st.container(horizontal=True):
    for q, c in counts.items():
        delta_color = "off"
        if q == "GNU fail, Rust pass (drift!)":
            delta_color = "inverse"
        st.metric(q, int(c), border=True)

st.markdown("### Per-test outcomes")

display_cols = [
    "test",
    "exercises",
    "expected_to_fail",
    "GNU status",
    "Rust status",
    "quadrant",
]
display_cols = [c for c in display_cols if c in combined.columns]
st.dataframe(combined[display_cols], hide_index=True, width="stretch")

# Drill-down on one test.
st.markdown("### Test drill-down")
selected = st.selectbox("Inspect a test", combined["test"].tolist())
if selected:
    row = combined[combined["test"] == selected].iloc[0]
    cols = st.columns(2)
    with cols[0]:
        with st.container(border=True):
            st.markdown("**GNU oracle**")
            st.write(f"status: `{row.get('GNU status')}` · rc: `{row.get('GNU rc')}`")
            stderr = row.get("GNU stderr") or ""
            if stderr:
                st.code(stderr[:2000])
    with cols[1]:
        with st.container(border=True):
            st.markdown("**Rust impl**")
            st.write(f"status: `{row.get('Rust status')}` · rc: `{row.get('Rust rc')}`")
            stderr = row.get("Rust stderr") or ""
            if stderr:
                st.code(stderr[:2000])

obs = load_observations(util, session, round_n)
if obs:
    with st.expander("Analyst observations (`_observations.md`)"):
        st.markdown(obs)
