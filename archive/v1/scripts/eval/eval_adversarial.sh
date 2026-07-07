#!/usr/bin/env bash
# Wave-4 adversarial-round orchestrator.
#
# Same shape as eval_round.sh, but:
#   - Adds a static pre-filter pass (bash -n + shellcheck -S error).
#   - Skips the rust-only metrics (flag coverage, line coverage). Those are
#     baseline-iteration metrics; adversarial cares about divergences.
#   - Adds classify_divergence.py emitting mut@k, DEPC, effective-test rate.
#
# Usage:
#   scripts/eval/eval_adversarial.sh <util> <session> <round>

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <util> <session> <round>" >&2
    exit 2
fi
UTIL="$1"
SESSION="$2"
ROUND="$3"
RR=$(printf '%02d' "$ROUND")

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
ROUND_DIR="${REPO}/runs/${UTIL}/${SESSION}/round_${RR}"

if [[ ! -d "$ROUND_DIR" ]]; then
    echo "no round dir at $ROUND_DIR" >&2
    exit 1
fi

echo "==> static pre-filter (bash -n + shellcheck -S error)" >&2
bash "${REPO}/scripts/eval/static_filter.sh" "$UTIL" "$SESSION" "$ROUND" || true

echo "==> real-gnu tests" >&2
python3 "${REPO}/scripts/pipeline/run_tests.py" --util "$UTIL" --session "$SESSION" \
    --round "$ROUND" --target real-gnu || true

echo "==> rust tests (in docker)" >&2
python3 "${REPO}/scripts/pipeline/run_tests.py" --util "$UTIL" --session "$SESSION" \
    --round "$ROUND" --target rust --in-docker || true

echo "==> classify divergences" >&2
python3 "${REPO}/scripts/eval/classify_divergence.py" "$UTIL" "$SESSION" "$ROUND" || true

# One-line summary keyed for adversarial output.
python3 - <<PY
import json, pathlib
rd = pathlib.Path("${ROUND_DIR}")
cls = rd / "classification.json"
if not cls.is_file():
    print("${UTIL} session=${SESSION} round=${ROUND} classification=missing")
    raise SystemExit(0)
c = json.loads(cls.read_text())
b = c["buckets"]
print(
    f"${UTIL} session=${SESSION} round=${ROUND} "
    f"scored={c['n_total_scored']} mut@k={c['mut_at_k']:.3f} "
    f"depc={c['depc']} effective={c['effective_test_rate']:.3f} "
    f"buckets=(baseline:{b['baseline']},divergence:{b['divergence']},"
    f"shared_bug:{b['shared_bug']},hallucinated_spec:{b['hallucinated_spec']},"
    f"incomplete:{b['incomplete']}) dropped={c['n_static_dropped_excluded']}"
)
PY
