"""Cost + token rollup — pricing per CLAUDE.md ($5/1M in, $30/1M out)."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import plotly.express as px
import streamlit as st

from data import discover_rounds

rounds = discover_rounds()
rounds = rounds[rounds["tests_generated"] > 0].copy()
if rounds.empty:
    st.warning("No rounds yet.")
    st.stop()

with st.container(horizontal=True):
    st.metric("Total est. spend", f"${rounds['est_cost_usd'].sum():.2f}", border=True)
    st.metric("Input tokens", f"{int(rounds['input_tokens'].sum()):,}", border=True)
    st.metric("Output tokens", f"{int(rounds['output_tokens'].sum()):,}", border=True)
    st.metric("Reasoning tokens", f"{int(rounds['reasoning_tokens'].sum()):,}", border=True)

cols = st.columns(2)
with cols[0]:
    with st.container(border=True):
        st.markdown("**Cost per round**")
        fig = px.bar(
            rounds.sort_values(["util", "round"]),
            x="round",
            y="est_cost_usd",
            color="util",
            facet_col="util",
        )
        fig.update_layout(height=320, showlegend=False)
        st.plotly_chart(fig, width="stretch")

with cols[1]:
    with st.container(border=True):
        st.markdown("**Tokens per round (output)**")
        fig = px.bar(
            rounds.sort_values(["util", "round"]),
            x="round",
            y="output_tokens",
            color="util",
            facet_col="util",
        )
        fig.update_layout(height=320, showlegend=False)
        st.plotly_chart(fig, width="stretch")

st.markdown("### Per-round detail")
st.dataframe(
    rounds[
        [
            "util",
            "session",
            "round",
            "input_tokens",
            "output_tokens",
            "reasoning_tokens",
            "est_cost_usd",
        ]
    ].rename(columns={"est_cost_usd": "cost $"}),
    hide_index=True,
)
