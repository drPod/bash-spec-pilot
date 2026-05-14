"""Pos/neg × pass/fail 2x2 matrix — Aaron's diversity ask."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st

from data import discover_rounds

rounds = discover_rounds()
rounds = rounds[rounds["tests_generated"] > 0].copy()

st.markdown(
    "A **positive** test exercises a documented success case (utility should succeed). "
    "A **negative** test exercises a documented error case (utility should error exactly as the man page says). "
    "Test pass/fail is independent — a negative test PASSES when the utility errored correctly."
)

# Stacked bars: pos / neg per util per round.
diversity_df = rounds[["util", "round", "tests_pos", "tests_neg"]].copy()
diversity_df["label"] = diversity_df["util"] + " r" + diversity_df["round"].astype(str)
long_df = diversity_df.melt(
    id_vars=["util", "round", "label"],
    value_vars=["tests_pos", "tests_neg"],
    var_name="type",
    value_name="count",
)
long_df["type"] = long_df["type"].map({"tests_pos": "positive", "tests_neg": "negative"})

with st.container(border=True):
    st.markdown("**Test-suite composition** — positive vs negative count")
    fig = px.bar(long_df, x="label", y="count", color="type", text="count")
    fig.update_layout(height=320, xaxis_title="util / round", legend_title="")
    st.plotly_chart(fig, width="stretch")

st.markdown("### 2x2 matrix per round")

util = st.sidebar.selectbox("Utility", sorted(rounds["util"].unique()))
util_df = rounds[rounds["util"] == util].sort_values(["session", "round"])

for _, row in util_df.iterrows():
    st.markdown(f"#### `{util}` · session `{row['session']}` · round {row['round']}")

    cols = st.columns(2)
    for col, oracle, label in [
        (cols[0], "real-gnu", "vs GNU (oracle)"),
        (cols[1], "rust", "vs Rust impl"),
    ]:
        with col:
            with st.container(border=True):
                pp = int(row[f"{oracle}_pos_pass"])
                pf = int(row[f"{oracle}_pos_fail"])
                np_ = int(row[f"{oracle}_neg_pass"])
                nf = int(row[f"{oracle}_neg_fail"])

                # Heatmap-style 2x2.
                z = [[pp, pf], [np_, nf]]
                fig = go.Figure(
                    data=go.Heatmap(
                        z=z,
                        x=["test pass", "test fail"],
                        y=["positive", "negative"],
                        text=z,
                        texttemplate="%{text}",
                        colorscale="Blues",
                        showscale=False,
                    )
                )
                fig.update_layout(
                    title=label,
                    height=240,
                    margin=dict(t=40, b=20, l=20, r=20),
                )
                st.plotly_chart(fig, width="stretch", key=f"hm-{row['session']}-{row['round']}-{oracle}")

                pos_total = pp + pf
                neg_total = np_ + nf
                pos_rate = pp / pos_total if pos_total else None
                neg_rate = np_ / neg_total if neg_total else None
                st.caption(
                    f"positive pass rate: {pos_rate:.0%} ({pp}/{pos_total})    "
                    f"negative pass rate: {neg_rate:.0%} ({np_}/{neg_total})"
                    if pos_total and neg_total
                    else "no results yet for this oracle"
                )
