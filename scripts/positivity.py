#!/usr/bin/env python3
"""Compute positive vs negative test breakdown for each round.

A "positive" test exercises a documented success case (expected_to_fail=false);
a "negative" test exercises a documented error case (expected_to_fail=true).
Test pass/fail is independent: a negative test PASSES when the utility errored
exactly as the man page documents.

For each round of each util we emit a 2x2 cell:

    +--------+-----------+-----------+
    |        | test pass | test fail |
    +--------+-----------+-----------+
    | pos    |  ...      |  ...      |
    | neg    |  ...      |  ...      |
    +--------+-----------+-----------+

evaluated independently against the GNU oracle and against the Rust impl.

Outputs:
    runs/<util>/<session>/round_NN/positivity.json   per-round JSON
    stdout: markdown summary table over all rounds discovered

Usage:
    python scripts/positivity.py                 # walk all runs/<util>/...
    python scripts/positivity.py --util cp       # restrict to one util
    python scripts/positivity.py --util cp --session 2026-05-07T11-10-34Z --round 2
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
RUNS = REPO / "runs"

ORACLES = ("real-gnu", "rust")
SESSION_RE = re.compile(r"^(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z|legacy_pre_session)$")
ROUND_RE = re.compile(r"^round_(\d{2})$")


def load_jsonl(path: Path) -> list[dict]:
    if not path.is_file():
        return []
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()]


def load_manifest(round_dir: Path) -> list[dict]:
    p = round_dir / "tests" / "_manifest.json"
    if not p.is_file():
        return []
    return json.loads(p.read_text())


def cell(rows: list[dict]) -> dict:
    """Compute 2x2 positivity cell from a results jsonl."""
    pos_pass = pos_fail = neg_pass = neg_fail = 0
    for r in rows:
        is_neg = bool(r.get("expected_to_fail"))
        passed = r.get("status") == "pass"
        if is_neg:
            if passed:
                neg_pass += 1
            else:
                neg_fail += 1
        else:
            if passed:
                pos_pass += 1
            else:
                pos_fail += 1
    pos_total = pos_pass + pos_fail
    neg_total = neg_pass + neg_fail
    return {
        "pos_total": pos_total,
        "neg_total": neg_total,
        "pos_pass": pos_pass,
        "pos_fail": pos_fail,
        "neg_pass": neg_pass,
        "neg_fail": neg_fail,
        "pos_pass_rate": pos_pass / pos_total if pos_total else None,
        "neg_pass_rate": neg_pass / neg_total if neg_total else None,
    }


def manifest_breakdown(manifest: list[dict]) -> dict:
    """Computed from the test manifest regardless of run results."""
    if not manifest:
        return {"total": 0, "pos": 0, "neg": 0, "pos_pct": None, "neg_pct": None}
    pos = sum(1 for t in manifest if not t.get("expected_to_fail"))
    neg = sum(1 for t in manifest if t.get("expected_to_fail"))
    total = pos + neg
    return {
        "total": total,
        "pos": pos,
        "neg": neg,
        "pos_pct": pos / total if total else None,
        "neg_pct": neg / total if total else None,
    }


def analyse_round(round_dir: Path) -> dict:
    manifest = load_manifest(round_dir)
    out = {
        "round_dir": str(round_dir.relative_to(REPO)),
        "manifest": manifest_breakdown(manifest),
        "oracles": {},
    }
    for oracle in ORACLES:
        rows = load_jsonl(round_dir / f"results_{oracle}.jsonl")
        out["oracles"][oracle] = cell(rows) if rows else None
    return out


def discover_rounds(util: str | None, session: str | None, round_n: int | None):
    utils = [util] if util else sorted(d.name for d in RUNS.iterdir() if d.is_dir())
    for u in utils:
        util_dir = RUNS / u
        if not util_dir.is_dir():
            continue
        sessions = (
            [session]
            if session
            else sorted(d.name for d in util_dir.iterdir() if d.is_dir() and SESSION_RE.match(d.name))
        )
        for s in sessions:
            session_dir = util_dir / s
            if not session_dir.is_dir():
                continue
            rounds = (
                [f"round_{round_n:02d}"]
                if round_n
                else sorted(d.name for d in session_dir.iterdir() if ROUND_RE.match(d.name))
            )
            for r in rounds:
                round_dir = session_dir / r
                if not round_dir.is_dir():
                    continue
                yield u, s, int(ROUND_RE.match(r).group(1)), round_dir


def fmt_pct(x: float | None) -> str:
    if x is None:
        return "  -  "
    return f"{x * 100:5.1f}%"


def emit_markdown(rows: list[dict]) -> str:
    out = []
    out.append("| util | session | round | pos / neg | pos% | neg% | GNU pos-pass | GNU neg-pass | Rust pos-pass | Rust neg-pass |")
    out.append("|------|---------|-------|-----------|------|------|--------------|--------------|---------------|---------------|")
    for r in rows:
        m = r["manifest"]
        gnu = r["oracles"].get("real-gnu") or {}
        rust = r["oracles"].get("rust") or {}
        out.append(
            f"| {r['util']} | {r['session']} | {r['round']} "
            f"| {m['pos']}/{m['neg']} "
            f"| {fmt_pct(m.get('pos_pct'))} "
            f"| {fmt_pct(m.get('neg_pct'))} "
            f"| {fmt_pct(gnu.get('pos_pass_rate'))} "
            f"| {fmt_pct(gnu.get('neg_pass_rate'))} "
            f"| {fmt_pct(rust.get('pos_pass_rate'))} "
            f"| {fmt_pct(rust.get('neg_pass_rate'))} |"
        )
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--util", help="restrict to one util")
    ap.add_argument("--session", help="restrict to one session")
    ap.add_argument("--round", type=int, help="restrict to one round number")
    ap.add_argument("--no-write", action="store_true", help="do not write positivity.json per round")
    args = ap.parse_args()

    rows = []
    for util, session, round_n, round_dir in discover_rounds(args.util, args.session, args.round):
        analysis = analyse_round(round_dir)
        analysis["util"] = util
        analysis["session"] = session
        analysis["round"] = round_n
        rows.append(analysis)
        if not args.no_write:
            (round_dir / "positivity.json").write_text(json.dumps(analysis, indent=2) + "\n")

    if not rows:
        print("No rounds discovered. Check --util/--session/--round filters.", file=sys.stderr)
        sys.exit(1)

    print(emit_markdown(rows))


if __name__ == "__main__":
    main()
