#!/usr/bin/env bash
# Run hand-written metamorphic invariant tests for a utility against the
# real GNU binary in the canonical trixie container.
#
# Usage:
#   scripts/eval/run_metamorphic.sh <util>            # run as root
#   scripts/eval/run_metamorphic.sh <util> --as-user  # run as non-root (sudo)
#
# Writes runs/<util>/_metamorphic/results.jsonl with one row per invariant.
# Tests live in tests/properties/<util>/*.sh and invoke the utility via the
# $UTIL env var per wave-3 convention.

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "usage: $0 <util> [--as-user]" >&2
    exit 2
fi
UTIL="$1"
shift || true

AS_USER=0
if [[ "${1:-}" == "--as-user" ]]; then
    AS_USER=1
fi

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
TESTS_DIR="${REPO}/tests/properties/${UTIL}"
OUT_DIR="${REPO}/runs/${UTIL}/_metamorphic"
OUT="${OUT_DIR}/results.jsonl"

if [[ ! -d "$TESTS_DIR" ]]; then
    echo "no metamorphic tests dir at $TESTS_DIR" >&2
    exit 1
fi
mkdir -p "$OUT_DIR"
: > "$OUT"

IMAGE="debian:trixie-slim"
docker pull "$IMAGE" >/dev/null 2>&1 || true

# Map host tests dir into the container; invoke each .sh once with $UTIL set
# to the canonical binary name. For sudo we need a non-root user with
# NOPASSWD; the matching worker (W-sudo) already documented this setup.
SETUP_ROOT='
apt-get update -qq >/dev/null
apt-get install -y -qq coreutils findutils sudo >/dev/null
'
SETUP_USER='
apt-get update -qq >/dev/null
apt-get install -y -qq coreutils findutils sudo >/dev/null
useradd -m -s /bin/bash tester
echo "tester ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/tester
chmod 0440 /etc/sudoers.d/tester
'

for path in "${TESTS_DIR}"/*.sh; do
    name="$(basename "$path")"
    # Skip README.md and other non-script artifacts; shell glob already filters.
    if [[ "$AS_USER" -eq 1 ]]; then
        cmd_setup="$SETUP_USER"
        cmd_run="su - tester -c 'UTIL=$UTIL bash /tests/$name'"
    else
        cmd_setup="$SETUP_ROOT"
        cmd_run="UTIL=$UTIL bash /tests/$name"
    fi
    full="set -euo pipefail; $cmd_setup $cmd_run"
    set +e
    out="$(docker run --rm -v "${TESTS_DIR}:/tests:ro" "$IMAGE" \
        bash -c "$full" 2>&1)"
    rc=$?
    set -e
    python3 - "$OUT" "$UTIL" "$name" "$rc" "$out" <<'PY'
import json, sys
out_path, util, name, rc, captured = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), sys.argv[5]
row = {
    "util": util,
    "name": name,
    "rc": rc,
    "pass": rc == 0,
    "captured": captured[-4000:],  # tail cap
}
with open(out_path, "a") as f:
    f.write(json.dumps(row) + "\n")
PY
done

python3 - "$OUT" <<'PY'
import json, sys
rows = [json.loads(l) for l in open(sys.argv[1]) if l.strip()]
p = sum(1 for r in rows if r["pass"])
print(f"metamorphic: {p}/{len(rows)} pass -> {sys.argv[1]}")
PY
