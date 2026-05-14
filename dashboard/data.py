"""Data loaders for the dashboard.

All readers go through @st.cache_data so the dashboard only re-parses runs/
when the underlying files change.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

import pandas as pd
import streamlit as st

REPO = Path(__file__).resolve().parent.parent
RUNS = REPO / "runs"
UTILS_DIR = REPO / "utils"

SESSION_RE = re.compile(r"^(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z|legacy_pre_session)$")
ROUND_RE = re.compile(r"^round_(\d{2})$")
ORACLES = ("real-gnu", "rust")


def _load_jsonl(path: Path) -> list[dict]:
    if not path.is_file():
        return []
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()]


def _load_json(path: Path) -> dict | None:
    if not path.is_file():
        return None
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError:
        return None


@st.cache_data(show_spinner=False)
def list_utils() -> list[str]:
    return sorted(d.name for d in RUNS.iterdir() if d.is_dir())


@st.cache_data(show_spinner=False)
def discover_rounds() -> pd.DataFrame:
    """One row per (util, session, round). Includes pass counts, coverage,
    positivity, log metadata."""
    rows = []
    for util_dir in sorted(RUNS.iterdir()):
        if not util_dir.is_dir():
            continue
        util = util_dir.name
        for session_dir in sorted(util_dir.iterdir()):
            if not session_dir.is_dir() or not SESSION_RE.match(session_dir.name):
                continue
            session = session_dir.name
            for round_dir in sorted(session_dir.iterdir()):
                m = ROUND_RE.match(round_dir.name)
                if not m:
                    continue
                round_n = int(m.group(1))
                row = {
                    "util": util,
                    "session": session,
                    "round": round_n,
                    "round_dir": str(round_dir.relative_to(REPO)),
                }

                # Test counts vs each oracle.
                for oracle in ORACLES:
                    results = _load_jsonl(round_dir / f"results_{oracle}.jsonl")
                    total = len(results)
                    passed = sum(1 for r in results if r.get("status") == "pass")
                    correct = sum(1 for r in results if r.get("correct") is True)
                    row[f"{oracle}_total"] = total
                    row[f"{oracle}_pass"] = passed
                    row[f"{oracle}_correct"] = correct
                    row[f"{oracle}_pass_rate"] = passed / total if total else None

                # Coverage. JSON keys are documented_count / exercised_count.
                cov_flags = _load_json(round_dir / "coverage_flags.json") or {}
                row["flag_cov_pct"] = cov_flags.get("coverage_pct")
                row["flags_documented"] = cov_flags.get("documented_count")
                row["flags_exercised"] = cov_flags.get("exercised_count")

                cov_rust = _load_json(round_dir / "coverage_rust.json") or {}
                row["line_cov_pct"] = cov_rust.get("line_coverage_pct")
                row["compile_failed"] = cov_rust.get("compile_failed", False)

                # Positivity (regenerate cheaply rather than depend on file existing).
                manifest = _load_json(round_dir / "tests" / "_manifest.json") or []
                pos = sum(1 for t in manifest if not t.get("expected_to_fail"))
                neg = sum(1 for t in manifest if t.get("expected_to_fail"))
                row["tests_generated"] = pos + neg
                row["tests_pos"] = pos
                row["tests_neg"] = neg

                # Per-oracle pos/neg pass rate.
                for oracle in ORACLES:
                    results = _load_jsonl(round_dir / f"results_{oracle}.jsonl")
                    pp = sum(1 for r in results if not r.get("expected_to_fail") and r.get("status") == "pass")
                    pf = sum(1 for r in results if not r.get("expected_to_fail") and r.get("status") != "pass")
                    np_ = sum(1 for r in results if r.get("expected_to_fail") and r.get("status") == "pass")
                    nf = sum(1 for r in results if r.get("expected_to_fail") and r.get("status") != "pass")
                    row[f"{oracle}_pos_pass"] = pp
                    row[f"{oracle}_pos_fail"] = pf
                    row[f"{oracle}_neg_pass"] = np_
                    row[f"{oracle}_neg_fail"] = nf
                    row[f"{oracle}_pos_pass_rate"] = pp / (pp + pf) if (pp + pf) else None
                    row[f"{oracle}_neg_pass_rate"] = np_ / (np_ + nf) if (np_ + nf) else None

                # Cost / tokens from log.jsonl (sum across all calls in this round).
                log = _load_jsonl(round_dir / "_logs" / "log.jsonl")
                in_tok = out_tok = reason_tok = 0
                for entry in log:
                    u = entry.get("usage") or {}
                    in_tok += u.get("input_tokens") or 0
                    out_tok += u.get("output_tokens") or 0
                    reason_tok += (u.get("output_tokens_details") or {}).get("reasoning_tokens") or 0
                row["input_tokens"] = in_tok
                row["output_tokens"] = out_tok
                row["reasoning_tokens"] = reason_tok
                # Pricing per CLAUDE.md: $5/1M in, $30/1M out, $0.50/1M cached. Cached split not tracked here.
                row["est_cost_usd"] = (in_tok * 5 + out_tok * 30) / 1_000_000

                rows.append(row)

    return pd.DataFrame(rows)


@st.cache_data(show_spinner=False)
def load_results(util: str, session: str, round_n: int, oracle: str) -> pd.DataFrame:
    """Per-test rows for a single (util, session, round, oracle)."""
    rd = RUNS / util / session / f"round_{round_n:02d}"
    rows = _load_jsonl(rd / f"results_{oracle}.jsonl")
    if not rows:
        return pd.DataFrame()
    df = pd.DataFrame(rows)
    df["round"] = round_n
    df["util"] = util
    df["oracle"] = oracle
    return df


@st.cache_data(show_spinner=False)
def load_manifest(util: str, session: str, round_n: int) -> pd.DataFrame:
    rd = RUNS / util / session / f"round_{round_n:02d}"
    manifest = _load_json(rd / "tests" / "_manifest.json") or []
    return pd.DataFrame(manifest)


@st.cache_data(show_spinner=False)
def load_observations(util: str, session: str, round_n: int) -> str:
    rd = RUNS / util / session / f"round_{round_n:02d}"
    p = rd / "_observations.md"
    return p.read_text() if p.is_file() else ""


@st.cache_data(show_spinner=False)
def load_manpage_meta(util: str) -> dict:
    p = UTILS_DIR / util / "_source.json"
    return _load_json(p) or {}
