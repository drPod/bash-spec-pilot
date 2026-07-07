#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --exchange: exchange source and destination. Both must exist; contents swap.
echo srcdata > "$tmpdir/src"
echo dstdata > "$tmpdir/dst"
"$UTIL" --exchange "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/src")" == dstdata && "$(cat "$tmpdir/dst")" == srcdata ]]; then
  exit 0
fi
echo "--exchange did not swap source and destination contents" >&2
exit 1
