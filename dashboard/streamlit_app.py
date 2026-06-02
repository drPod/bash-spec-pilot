"""Bash man-page → Rust experiment dashboard.

Entry point: `streamlit run dashboard/streamlit_app.py` from the repo root.
"""
import streamlit as st

st.set_page_config(
    page_title="Bash man-page experiment",
    page_icon=":material/terminal:",
    layout="wide",
    initial_sidebar_state="expanded",
)

page = st.navigation(
    {
        "": [
            st.Page("app_pages/story.py", title="The experiment", icon=":material/auto_stories:", default=True),
            st.Page("app_pages/overview.py", title="Overview", icon=":material/dashboard:"),
        ],
        "Findings": [
            st.Page("app_pages/findings.py", title="Research findings", icon=":material/menu_book:"),
            st.Page("app_pages/scorecard.py", title="Adversarial scorecard", icon=":material/scoreboard:"),
            st.Page("app_pages/divergences.py", title="Divergences", icon=":material/call_split:"),
            st.Page("app_pages/crossver.py", title="Cross-version", icon=":material/history:"),
        ],
        "Per utility": [
            st.Page("app_pages/trajectory.py", title="Trajectory", icon=":material/timeline:"),
            st.Page("app_pages/positivity.py", title="Test diversity", icon=":material/grid_view:"),
            st.Page("app_pages/failures.py", title="Failure browser", icon=":material/bug_report:"),
        ],
        "Quality floor": [
            st.Page("app_pages/metamorphic.py", title="Metamorphic floor", icon=":material/foundation:"),
            st.Page("app_pages/static_filter.py", title="Static filter", icon=":material/filter_alt:"),
        ],
        "Methodology": [
            st.Page("app_pages/reproducibility.py", title="Reproducibility (A/B)", icon=":material/replay:"),
            st.Page("app_pages/cost.py", title="Cost & tokens", icon=":material/payments:"),
        ],
    },
    position="sidebar",
)

st.title(f"{page.icon} {page.title}")
st.caption("Bash man-page → LLM → Rust + tests · differential test vs GNU coreutils")

page.run()
