#!/usr/bin/env bash
# -C num / --close-from: "Values less than three are not permitted." Passing
# -C 2 is a documented error; sudo must exit nonzero.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n -C 2 true >"$tmpdir/out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "expected sudo -C 2 (value < 3) to fail, but it exited 0" >&2
  exit 1
fi
