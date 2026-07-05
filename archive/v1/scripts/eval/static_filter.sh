#!/usr/bin/env bash
# Wave-4 static pre-filter for generated test scripts.
#
# Runs `bash -n` (syntactic) + `shellcheck -s bash -S error` (error-level lint)
# over each test file in a round dir's tests/ subdir and writes
# static_filter.json next to the manifest. Failing tests are NOT deleted —
# they are research artifacts. They are tagged in static_filter.json so the
# downstream classifier (classify_divergence.py) can exclude them from the
# mut@k headline metric per the SLMFix-style deterministic pre-filter rule
# (§15 of docs/research/adversarial_prior_art.md).
#
# Usage:
#   scripts/eval/static_filter.sh <util> <session> <round>

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
TESTS_DIR="${REPO}/runs/${UTIL}/${SESSION}/round_${RR}/tests"
OUT="${REPO}/runs/${UTIL}/${SESSION}/round_${RR}/static_filter.json"

if [[ ! -d "$TESTS_DIR" ]]; then
    echo "no tests dir at $TESTS_DIR" >&2
    exit 1
fi

have_shellcheck=1
if ! command -v shellcheck >/dev/null 2>&1; then
    echo "WARNING: shellcheck not on PATH; only bash -n will run." >&2
    have_shellcheck=0
fi

python3 - "$TESTS_DIR" "$OUT" "$have_shellcheck" <<'PY'
import json, pathlib, subprocess, sys

tests_dir = pathlib.Path(sys.argv[1])
out_path  = pathlib.Path(sys.argv[2])
have_sc   = sys.argv[3] == "1"

kept, dropped = [], []
per_file = {}

for path in sorted(tests_dir.glob("*.sh")):
    name = path.name
    issues = {"bash_n": None, "shellcheck": None}

    p1 = subprocess.run(["bash", "-n", str(path)], capture_output=True, text=True)
    issues["bash_n"] = {"rc": p1.returncode, "stderr": p1.stderr.strip()}

    if have_sc:
        p2 = subprocess.run(
            ["shellcheck", "-s", "bash", "-S", "error", "-f", "gcc", str(path)],
            capture_output=True, text=True,
        )
        issues["shellcheck"] = {
            "rc": p2.returncode,
            "n_error_lines": sum(1 for l in p2.stdout.splitlines() if l.strip()),
            "stdout": p2.stdout.strip(),
        }

    per_file[name] = issues
    bn_ok = issues["bash_n"]["rc"] == 0
    sc_ok = (not have_sc) or issues["shellcheck"]["rc"] == 0
    if bn_ok and sc_ok:
        kept.append(name)
    else:
        dropped.append(name)

out_path.write_text(json.dumps({
    "kept": kept,
    "dropped": dropped,
    "per_file": per_file,
    "shellcheck_available": have_sc,
}, indent=2))

print(f"static_filter: kept={len(kept)} dropped={len(dropped)} -> {out_path}")
PY
