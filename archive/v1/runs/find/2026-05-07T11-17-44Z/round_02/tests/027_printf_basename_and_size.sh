#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf abcd > "$tmpdir/data"
out=$("$UTIL" "$tmpdir/data" -maxdepth 0 -printf '%f:%s')
expected='data:4'
if [[ "$out" != "$expected" ]]; then echo "-printf %f:%s produced unexpected output" >&2; exit 1; fi
