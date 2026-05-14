"""Per-utility round-over-round trajectory."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import plotly.express as px
import streamlit as st

from data import discover_rounds, load_manpage_meta

rounds = discover_rounds()
rounds = rounds[rounds["tests_generated"] > 0].copy()

if rounds.empty:
    st.warning("No rounds yet.")
    st.stop()

util = st.sidebar.selectbox("Utility", sorted(rounds["util"].unique()))
util_df = rounds[rounds["util"] == util].sort_values(["session", "round"]).reset_index(drop=True)

if util_df.empty:
    st.warning(f"No rounds for {util}.")
    st.stop()

manpage = load_manpage_meta(util)
with st.container(border=True):
    if manpage:
        st.markdown(
            f"**{util}** · source: `{manpage.get('package', '?')}` "
            f"({manpage.get('package_version', '?')}) · "
            f"section {manpage.get('section', '?')} · "
            f"frozen {manpage.get('fetched_at', '?')[:10]}"
        )
    else:
        st.markdown(f"**{util}**")

# KPI row for the most-recent round.
latest = util_df.iloc[-1]
with st.container(horizontal=True):
    st.metric(
        "vs GNU",
        f"{int(latest['real-gnu_pass'])}/{int(latest['real-gnu_total'])}",
        f"{(latest['real-gnu_pass_rate'] or 0):.0%}",
        border=True,
    )
    st.metric(
        "vs Rust impl",
        f"{int(latest['rust_pass'])}/{int(latest['rust_total'])}",
        f"{(latest['rust_pass_rate'] or 0):.0%}",
        border=True,
    )
    st.metric(
        "Flag coverage",
        f"{(latest['flag_cov_pct'] or 0):.0f}%",
        f"{int(latest['flags_exercised'] or 0)}/{int(latest['flags_documented'] or 0)} flags",
        border=True,
    )
    line_cov = latest["line_cov_pct"]
    st.metric(
        "Rust line coverage",
        f"{line_cov:.1f}%" if line_cov is not None else "n/a",
        "tarpaulin in trixie",
        border=True,
    )

st.markdown("### Round trajectory")

cols = st.columns(2)
with cols[0]:
    with st.container(border=True):
        st.markdown("**Test pass rate by round**")
        chart_df = util_df.melt(
            id_vars=["round"],
            value_vars=["real-gnu_pass_rate", "rust_pass_rate"],
            var_name="oracle",
            value_name="pass_rate",
        )
        chart_df["oracle"] = chart_df["oracle"].map(
            {"real-gnu_pass_rate": "vs GNU", "rust_pass_rate": "vs Rust impl"}
        )
        fig = px.line(chart_df.dropna(), x="round", y="pass_rate", color="oracle", markers=True, range_y=[0, 1.05])
        fig.update_layout(yaxis_tickformat=".0%", height=300, margin=dict(t=20, b=20))
        st.plotly_chart(fig, width="stretch")

with cols[1]:
    with st.container(border=True):
        st.markdown("**Coverage by round**")
        cov_df = util_df.melt(
            id_vars=["round"],
            value_vars=["flag_cov_pct", "line_cov_pct"],
            var_name="metric",
            value_name="pct",
        )
        cov_df["metric"] = cov_df["metric"].map({"flag_cov_pct": "flag coverage", "line_cov_pct": "rust line coverage"})
        fig = px.line(cov_df.dropna(), x="round", y="pct", color="metric", markers=True, range_y=[0, 105])
        fig.update_layout(height=300, margin=dict(t=20, b=20), yaxis_title="%")
        st.plotly_chart(fig, width="stretch")

st.markdown("### Per-round detail")
st.dataframe(
    util_df[
        [
            "session",
            "round",
            "tests_generated",
            "tests_pos",
            "tests_neg",
            "real-gnu_pass",
            "real-gnu_total",
            "rust_pass",
            "rust_total",
            "flag_cov_pct",
            "line_cov_pct",
            "compile_failed",
            "est_cost_usd",
        ]
    ].rename(columns={"est_cost_usd": "cost $"}),
    hide_index=True,
)
