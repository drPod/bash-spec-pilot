#!/usr/bin/env bash
# Run all four metrics for a single round and emit a one-line summary.
#
# Usage:
#   scripts/eval_round.sh <util> <session> <round>
#
# Example:
#   scripts/eval_round.sh cp 2026-05-07T18-30-00Z 1
#
# Order of operations:
#   1. real-gnu tests (the canonical oracle)
#   2. rust tests (the LLM-generated impl)
#   3. flag coverage (parses manpage + tests)
#   4. rust line coverage (cargo tarpaulin in trixie container)
# Step 4 is skipped gracefully when the impl fails to compile.

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <util> <session> <round>" >&2
    exit 2
fi
UTIL="$1"
SESSION="$2"
ROUND="$3"
RR=$(printf '%02d' "$ROUND")

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ROUND_DIR="${REPO}/runs/${UTIL}/${SESSION}/round_${RR}"

echo "==> real-gnu tests" >&2
python3 "${REPO}/scripts/run_tests.py" --util "$UTIL" --session "$SESSION" \
    --round "$ROUND" --target real-gnu || true

echo "==> rust tests (in docker)" >&2
python3 "${REPO}/scripts/run_tests.py" --util "$UTIL" --session "$SESSION" \
    --round "$ROUND" --target rust --in-docker || true

echo "==> flag coverage" >&2
python3 "${REPO}/scripts/coverage_flags.py" --util "$UTIL" --session "$SESSION" \
    --round "$ROUND" || true

echo "==> rust coverage" >&2
bash "${REPO}/scripts/coverage_rust.sh" --util "$UTIL" --session "$SESSION" \
    --round "$ROUND" || true

# Emit the summary line.
python3 - <<PY
import json, pathlib
rd = pathlib.Path("${ROUND_DIR}")

def count_correct(name):
    p = rd / name
    if not p.is_file():
        return None, None
    rows = [json.loads(l) for l in p.read_text().splitlines() if l.strip()]
    total = len(rows)
    correct = sum(1 for r in rows if r.get("correct") is True)
    if not any("correct" in r for r in rows):
        # Legacy schema: status==pass.
        correct = sum(1 for r in rows if r.get("status") == "pass")
    return correct, total

real_c, real_t = count_correct("results_real-gnu.jsonl")
rust_c, rust_t = count_correct("results_rust.jsonl")

flag_pct = "n/a"
fp = rd / "coverage_flags.json"
if fp.is_file():
    flag_pct = f"{json.loads(fp.read_text()).get('coverage_pct', 'n/a')}%"

line_pct = "n/a"
cp = rd / "coverage_rust.json"
if cp.is_file():
    cov = json.loads(cp.read_text())
    if cov.get("compile_failed"):
        line_pct = "compile_failed"
    elif cov.get("line_coverage_pct") is not None:
        line_pct = f"{cov['line_coverage_pct']}%"

def fmt(c, t):
    if c is None: return "n/a"
    return f"{c}/{t}"

print(
    f"${UTIL} session=${SESSION} round=${ROUND} "
    f"test_real={fmt(real_c, real_t)} test_rust={fmt(rust_c, rust_t)} "
    f"flag_cov={flag_pct} line_cov={line_pct}"
)
PY
