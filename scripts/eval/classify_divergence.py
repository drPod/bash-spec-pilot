#!/usr/bin/env python3
"""Wave-4 divergence classifier.

Reads results_real-gnu.jsonl + results_rust.jsonl from an adversarial
round dir and emits:

  - divergences.jsonl  - one row per real-vs-rust disagreement
  - classification.json - four-bucket counts + mut@k + DEPC + effective-test rate

Buckets (mut@k headline metric per docs/research/adversarial_prior_art.md):

  baseline            real_correct=True,  rust_correct=True
  divergence          real_correct=True,  rust_correct=False   <- headline
  shared_bug          real_correct=False, rust_correct=False
  hallucinated_spec   real_correct=False, rust_correct=True

mut@k             = divergences / total_tests
effective_rate    = (divergences + shared_bugs) / total_tests
DEPC              = distinct (rc, stderr_first_line) signatures across divergences

Static-filter exclusion: tests whose name appears in static_filter.json's
`dropped` list are excluded from the mut@k denominator (matching the
SLMFix-style pre-filter rule).

Usage:
    scripts/eval/classify_divergence.py <util> <session> <round>
"""
from __future__ import annotations

import argparse
import json
import pathlib
import sys


def load_jsonl(path: pathlib.Path) -> dict[str, dict]:
    out: dict[str, dict] = {}
    if not path.is_file():
        return out
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        name = row.get("name")
        if name:
            out[name] = row
    return out


def correct(row: dict) -> bool | None:
    if not row:
        return None
    if "correct" in row:
        return bool(row["correct"])
    return row.get("status") == "pass"


def classify(real: dict, rust: dict) -> str:
    rc = correct(real)
    uc = correct(rust)
    if rc is True and uc is True:
        return "baseline"
    if rc is True and uc is False:
        return "divergence"
    if rc is False and uc is False:
        return "shared_bug"
    if rc is False and uc is True:
        return "hallucinated_spec"
    return "incomplete"


def signature(row: dict) -> tuple[int, str]:
    rc = row.get("rc")
    stderr = (row.get("stderr") or "").splitlines()
    head = stderr[0].strip() if stderr else ""
    return (rc if isinstance(rc, int) else -1, head[:120])


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("util")
    ap.add_argument("session")
    ap.add_argument("round", type=int)
    args = ap.parse_args()

    repo = pathlib.Path(__file__).resolve().parents[2]
    rdir = repo / "runs" / args.util / args.session / f"round_{args.round:02d}"
    if not rdir.is_dir():
        print(f"no round dir at {rdir}", file=sys.stderr)
        return 2

    real_rows = load_jsonl(rdir / "results_real-gnu.jsonl")
    rust_rows = load_jsonl(rdir / "results_rust.jsonl")

    sf_path = rdir / "static_filter.json"
    dropped_set: set[str] = set()
    if sf_path.is_file():
        dropped_set = set(json.loads(sf_path.read_text()).get("dropped", []))

    all_names = sorted(set(real_rows) | set(rust_rows))
    buckets: dict[str, list[str]] = {
        "baseline": [],
        "divergence": [],
        "shared_bug": [],
        "hallucinated_spec": [],
        "incomplete": [],
    }
    divergence_rows: list[dict] = []
    div_signatures: set[tuple[int, str]] = set()
    excluded = 0

    for name in all_names:
        real = real_rows.get(name, {})
        rust = rust_rows.get(name, {})
        if name in dropped_set:
            excluded += 1
            continue
        bucket = classify(real, rust)
        buckets[bucket].append(name)
        if bucket == "divergence":
            div_signatures.add(signature(rust))
            divergence_rows.append({
                "name": name,
                "exercises": real.get("exercises") or rust.get("exercises"),
                "expected": real.get("expected") or rust.get("expected"),
                "expected_to_fail": real.get("expected_to_fail")
                if "expected_to_fail" in real
                else rust.get("expected_to_fail"),
                "real_rc": real.get("rc"),
                "real_stderr_head": (real.get("stderr") or "").splitlines()[:3],
                "rust_rc": rust.get("rc"),
                "rust_stderr_head": (rust.get("stderr") or "").splitlines()[:3],
            })

    n_total = sum(len(v) for v in buckets.values())
    n_div = len(buckets["divergence"])
    n_shared = len(buckets["shared_bug"])

    classification = {
        "util": args.util,
        "session": args.session,
        "round": args.round,
        "n_total_scored": n_total,
        "n_static_dropped_excluded": excluded,
        "buckets": {k: len(v) for k, v in buckets.items()},
        "bucket_names": buckets,
        "mut_at_k": (n_div / n_total) if n_total else 0.0,
        "effective_test_rate": ((n_div + n_shared) / n_total) if n_total else 0.0,
        "depc": len(div_signatures),
    }

    (rdir / "classification.json").write_text(json.dumps(classification, indent=2))
    with (rdir / "divergences.jsonl").open("w") as f:
        for row in divergence_rows:
            f.write(json.dumps(row) + "\n")

    print(
        f"{args.util} session={args.session} round={args.round} "
        f"scored={n_total} mut@k={classification['mut_at_k']:.3f} "
        f"depc={classification['depc']} "
        f"buckets=(baseline:{len(buckets['baseline'])},"
        f"divergence:{n_div},shared_bug:{n_shared},"
        f"hallucinated_spec:{len(buckets['hallucinated_spec'])},"
        f"incomplete:{len(buckets['incomplete'])})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
