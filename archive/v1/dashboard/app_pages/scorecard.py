"""Adversarial scorecard — 5-bucket classification, mut@k, DEPC, effective rate."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import plotly.express as px
import streamlit as st

from data import BUCKETS, discover_classifications

clf = discover_classifications()

st.markdown(
    "Every adversarial round is scored into five buckets. **mut@k** = divergences / scored tests "
    "(the impl-bug kill rate). **DEPC** = distinct (rc, stderr) failure signatures among "
    "divergences. **Effective rate** = (divergences + shared bugs) / scored, the fraction of tests "
    "that surfaced *any* wrong behavior."
)

if clf.empty:
    st.info("No classified rounds yet. Run `scripts/eval/eval_adversarial.sh <util> <session> <round>`.")
    st.stop()

clf = clf.sort_values(["util", "session", "round"]).reset_index(drop=True)
clf["label"] = clf["util"] + " · " + clf["mode"] + " · r" + clf["round"].astype(str)

with st.container(horizontal=True):
    st.metric("Classified rounds", len(clf), border=True)
    st.metric("Best mut@k", f"{clf['mut_at_k'].max():.3f}", border=True)
    st.metric("Max DEPC", int(clf["depc"].max()), border=True)
    st.metric("Total divergences", int(clf["divergence"].sum()), border=True)
    st.metric("Total under-specs", int(clf["manpage_underspec"].sum()), border=True)

st.markdown("### Bucket breakdown per round")
bucket_order = list(BUCKETS)
melted = clf.melt(
    id_vars=["label", "mode"],
    value_vars=bucket_order,
    var_name="bucket",
    value_name="count",
)
color_map = {
    "baseline": "#9aa0a6",
    "divergence": "#d93025",
    "shared_bug": "#f9ab00",
    "hallucinated_spec": "#c0c0c0",
    "manpage_underspec": "#1a73e8",
    "incomplete": "#5f6368",
}
fig = px.bar(
    melted,
    x="label",
    y="count",
    color="bucket",
    category_orders={"bucket": bucket_order},
    color_discrete_map=color_map,
)
fig.update_layout(height=380, xaxis_title="", legend_title="bucket", barmode="stack")
st.plotly_chart(fig, width="stretch")

st.markdown("### Metrics per round")
metrics = clf[
    [
        "util", "session", "round", "mode",
        "n_total_scored", "n_static_dropped_excluded",
        "mut_at_k", "depc", "effective_test_rate",
        "divergence", "shared_bug", "manpage_underspec", "hallucinated_spec",
    ]
].rename(
    columns={
        "n_total_scored": "scored",
        "n_static_dropped_excluded": "static-dropped",
        "mut_at_k": "mut@k",
        "effective_test_rate": "effective",
        "manpage_underspec": "underspec",
        "hallucinated_spec": "halluc",
    }
)
st.dataframe(
    metrics,
    hide_index=True,
    width="stretch",
    column_config={
        "mut@k": st.column_config.NumberColumn(format="%.3f"),
        "effective": st.column_config.NumberColumn(format="%.3f"),
    },
)
