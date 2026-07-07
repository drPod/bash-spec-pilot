#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --exchange: exchange source and destination. Exchanging with a nonexistent
# destination has nothing to swap, so mv must fail.
echo srcdata > "$tmpdir/src"
set +e
"$UTIL" --exchange "$tmpdir/src" "$tmpdir/dst"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
fi
echo "--exchange against a nonexistent destination did not fail" >&2
exit 1
