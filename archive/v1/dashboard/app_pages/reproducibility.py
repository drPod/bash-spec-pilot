"""Reproducibility A/B — the N=1 caveat made visible.

The cp reproducibility test (2026-05-07) ran the same prompt + same model
twice. The summary lives at runs/cp/_reproducibility_*.md.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import streamlit as st

from data import REPO, discover_rounds

repro_files = sorted((REPO / "runs" / "cp").glob("_reproducibility_*.md"))

if not repro_files:
    st.info("No reproducibility report yet.")
    st.stop()

with st.container(border=True):
    st.markdown(
        "**Why this page exists.** Reasoning models do not support `temperature` or `seed`. "
        "Reproducibility is not pinned at the API layer. The only way to gauge variance is to run the same "
        "prompt N times and look at the spread. Below: the cp reproducibility A/B from 2026-05-07. "
        "Pending: N≥3 resampling across all four utilities."
    )

for f in repro_files:
    with st.expander(f.name, expanded=True):
        st.markdown(f.read_text())
