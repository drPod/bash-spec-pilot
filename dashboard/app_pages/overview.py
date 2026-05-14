"""Cross-utility overview: latest round per util + headline findings."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pandas as pd
import plotly.express as px
import streamlit as st

from data import discover_rounds

rounds = discover_rounds()
# Drop reproducibility-test sessions that never generated tests (empty rounds).
rounds = rounds[rounds["tests_generated"] > 0].copy()

if rounds.empty:
    st.warning("No round data yet. Run `scripts/eval_round.sh <util> <session> <round>`.")
    st.stop()

st.markdown(
    "**Question:** can an LLM extract behaviorally-faithful information from a Unix man page? "
    "Each row below is one round of one utility — Rust impl + Bash test suite generated from the frozen man page, "
    "differential-tested against the real GNU utility in Debian trixie."
)

# KPIs across all rounds.
total_runs = len(rounds)
total_utils = rounds["util"].nunique()
total_tests = int(rounds["tests_generated"].sum())
total_cost = float(rounds["est_cost_usd"].sum())

with st.container(horizontal=True):
    st.metric("Utilities probed", total_utils, border=True)
    st.metric("Total rounds run", total_runs, border=True)
    st.metric("Tests generated", total_tests, border=True)
    st.metric("API spend (est.)", f"${total_cost:.2f}", border=True)

st.markdown("### Latest round per utility")
latest = rounds.sort_values(["util", "round"]).groupby("util").tail(1).reset_index(drop=True)

display = latest[
    [
        "util",
        "round",
        "session",
        "tests_generated",
        "real-gnu_pass",
        "real-gnu_pass_rate",
        "rust_pass",
        "rust_pass_rate",
        "flag_cov_pct",
        "line_cov_pct",
        "tests_pos",
        "tests_neg",
    ]
].rename(
    columns={
        "real-gnu_pass": "GNU pass",
        "real-gnu_pass_rate": "GNU %",
        "rust_pass": "Rust pass",
        "rust_pass_rate": "Rust %",
        "flag_cov_pct": "Flag cov %",
        "line_cov_pct": "Line cov %",
        "tests_pos": "Positive",
        "tests_neg": "Negative",
    }
)

display["GNU %"] = display["GNU %"] * 100
display["Rust %"] = display["Rust %"] * 100
st.dataframe(
    display,
    hide_index=True,
    column_config={
        "GNU %": st.column_config.ProgressColumn(format="%.0f%%", min_value=0, max_value=100),
        "Rust %": st.column_config.ProgressColumn(format="%.0f%%", min_value=0, max_value=100),
    },
)

st.markdown("### Pass rates across all rounds")
chart_df = rounds.melt(
    id_vars=["util", "round"],
    value_vars=["real-gnu_pass_rate", "rust_pass_rate"],
    var_name="oracle",
    value_name="pass_rate",
)
chart_df["oracle"] = chart_df["oracle"].map(
    {"real-gnu_pass_rate": "vs GNU (oracle)", "rust_pass_rate": "vs Rust impl"}
)
fig = px.line(
    chart_df.dropna(subset=["pass_rate"]),
    x="round",
    y="pass_rate",
    color="oracle",
    facet_col="util",
    markers=True,
    range_y=[0, 1.05],
)
fig.update_layout(yaxis_tickformat=".0%", height=340)
fig.update_xaxes(dtick=1)
st.plotly_chart(fig, use_container_width=False, width="stretch")

st.markdown("### Headline findings")

c1, c2 = st.columns(2)
with c1:
    with st.container(border=True):
        st.markdown("**LLM-vs-LLM drift (cp round 2).**")
        st.markdown(
            "Rust impl scored 28/28 on its own LLM-generated tests but 26/28 against real GNU. "
            "Both halves coevolved a wrong story about `--strip-trailing-slashes`. "
            "Direct evidence that differential testing against a real binary catches what "
            "spec-vs-spec (Caruca-style) validation cannot."
        )
    with st.container(border=True):
        st.markdown("**Split man-page failure class (sudo).**")
        st.markdown(
            "`sudo(8)` alone misses policy rules in `sudoers(5)`. "
            "Most flags pass today only because Docker runs as root. "
            "Same shape applies to `crontab(1)`/`crontab(5)`, `ssh(1)`/`ssh_config(5)`."
        )

with c2:
    with st.container(border=True):
        st.markdown("**Test diversity is low.**")
        st.markdown(
            "80-90% of generated tests are positive (happy path). "
            "Negative tests cluster on the most-documented error cases. "
            "See *Test diversity* page for the per-util 2x2 matrix."
        )
    with st.container(border=True):
        st.markdown("**N=1 reproducibility caveat.**")
        st.markdown(
            "Same prompt + same model + two calls = 291 vs 393 line outputs and a compile-success flip. "
            "Every cell needs N≥3 resampling before it carries weight. "
            "See *Reproducibility* page."
        )

st.divider()
st.markdown(
    "**Where to read more:** [`for_aaron.md`](https://github.com/) — weekly status. "
    "[`taxonomy.md`](https://github.com/) — failure classes. "
    "[`decisions.md`](https://github.com/) — provenance + design choices."
)
