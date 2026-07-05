"""Static pre-filter — bash -n + shellcheck kept/dropped counts per round."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pandas as pd
import streamlit as st

from data import discover_rounds, load_static_filter

rounds = discover_rounds()
rounds = rounds[rounds["tests_generated"] > 0].copy()
if rounds.empty:
    st.warning("No rounds yet.")
    st.stop()

st.markdown(
    "Before scoring, every generated test is run through `bash -n` and `shellcheck -S error`. "
    "Tests that fail to parse are **dropped** and excluded from the mut@k denominator — the "
    "SLMFix-style pre-filter rule, so the kill rate isn't diluted by tests that never ran."
)

# Collect static_filter.json per round.
recs = []
for _, row in rounds.iterrows():
    sf = load_static_filter(row["util"], row["session"], int(row["round"]))
    if not sf:
        continue
    kept = sf.get("kept") or []
    dropped = sf.get("dropped") or []
    recs.append({
        "util": row["util"],
        "session": row["session"],
        "round": int(row["round"]),
        "mode": row.get("mode"),
        "kept": len(kept),
        "dropped": len(dropped),
        "_sf": sf,
    })

if not recs:
    st.info("No static_filter.json files yet. Run `scripts/eval/static_filter.sh <util> <session> <round>`.")
    st.stop()

df = pd.DataFrame(recs)

with st.container(horizontal=True):
    st.metric("Rounds filtered", len(df), border=True)
    st.metric("Total kept", int(df["kept"].sum()), border=True)
    st.metric("Total dropped", int(df["dropped"].sum()), border=True)

st.markdown("### Per-round")
st.dataframe(
    df[["util", "session", "round", "mode", "kept", "dropped"]],
    hide_index=True,
    width="stretch",
)

st.markdown("### Per-file detail")
labels = [f"{r['util']} · {r['session']} · r{r['round']}" for r in recs]
choice = st.selectbox("Round", range(len(recs)), format_func=lambda i: labels[i])
sf = recs[choice]["_sf"]
per_file = sf.get("per_file") or {}
rows = []
for fname, checks in per_file.items():
    bash_n = (checks or {}).get("bash_n") or {}
    shellcheck = (checks or {}).get("shellcheck")
    rows.append({
        "test": fname,
        "bash -n rc": bash_n.get("rc"),
        "bash -n stderr": (bash_n.get("stderr") or "")[:120],
        "shellcheck": "clean" if shellcheck is None else str(shellcheck)[:120],
        "dropped": fname in (sf.get("dropped") or []),
    })
if rows:
    st.dataframe(pd.DataFrame(rows), hide_index=True, width="stretch")
else:
    st.caption("No per-file records for this round.")
