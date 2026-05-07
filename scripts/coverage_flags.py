#!/usr/bin/env python3
"""Compute flag coverage for a round.

flag_coverage = flags_exercised / flags_documented

  documented = flags appearing in utils/<util>/manpage.txt
  exercised  = flags appearing in any test body in
               runs/<util>/<session>/round_<NN>/tests/*.sh

Match heuristic per the brief:
  ^\\s+-[A-Za-z]\\b           short flag in the man page (indented)
  ^\\s+--[A-Za-z][a-z0-9-]+   long flag in the man page (indented)

Test-side: we look for the same patterns anywhere in the test body, not
just at line start, so `"$UTIL" -t "$dst" "$src"` counts as exercising
`-t`. Long flags like `--update=none` count as `--update`.

Writes runs/<util>/<session>/round_<NN>/coverage_flags.json with both
matched and unmatched flag lists for inspection. Returns a percentage on
stdout for shell-level pipelines.

Usage:
    python scripts/coverage_flags.py --util cp --session <sid> --round 1
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


SHORT_DOC_RE = re.compile(r"^\s+(-[A-Za-z])\b")
LONG_DOC_RE = re.compile(r"^\s+(--[A-Za-z][A-Za-z0-9-]*)\b")
SHORT_USE_RE = re.compile(r"(?<![A-Za-z0-9-])(-[A-Za-z])(?![A-Za-z0-9-])")
LONG_USE_RE = re.compile(r"(--[A-Za-z][A-Za-z0-9-]*)\b")


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--util", required=True)
    ap.add_argument("--session", required=True)
    ap.add_argument("--round", type=int, required=True)
    return ap.parse_args()


def documented_flags(manpage: str) -> set[str]:
    flags: set[str] = set()
    for line in manpage.splitlines():
        m = SHORT_DOC_RE.match(line)
        if m:
            flags.add(m.group(1))
        m = LONG_DOC_RE.match(line)
        if m:
            flags.add(m.group(1))
    return flags


def exercised_flags(test_bodies: list[str]) -> set[str]:
    flags: set[str] = set()
    for body in test_bodies:
        flags.update(SHORT_USE_RE.findall(body))
        flags.update(LONG_USE_RE.findall(body))
    return flags


def main() -> None:
    args = parse_args()
    repo = Path(__file__).resolve().parent.parent
    round_dir = repo / "runs" / args.util / args.session / f"round_{args.round:02d}"
    manpage = (repo / "utils" / args.util / "manpage.txt").read_text()
    tests_dir = round_dir / "tests"
    test_bodies = [
        p.read_text() for p in sorted(tests_dir.glob("*.sh"))
    ]

    documented = documented_flags(manpage)
    used = exercised_flags(test_bodies)
    matched = sorted(documented & used)
    unmatched = sorted(documented - used)
    extra = sorted(used - documented)  # used in tests but not in manpage

    pct = (len(matched) / len(documented) * 100.0) if documented else 0.0
    out = {
        "util": args.util,
        "session": args.session,
        "round": args.round,
        "documented_count": len(documented),
        "exercised_count": len(matched),
        "coverage_pct": round(pct, 2),
        "matched": matched,
        "unmatched": unmatched,
        "extra_used_not_documented": extra,
    }
    out_path = round_dir / "coverage_flags.json"
    out_path.write_text(json.dumps(out, indent=2))
    print(
        f"flag_coverage: {len(matched)}/{len(documented)} = {pct:.1f}%  "
        f"(out: {out_path})"
    )


if __name__ == "__main__":
    main()
