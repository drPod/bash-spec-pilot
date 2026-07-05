#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/input"
printf oldcontent > "$tmpdir/out"
"$UTIL" "$tmpdir/input" -maxdepth 0 -fprint "$tmpdir/out" > "$tmpdir/stdout"
out=$(cat "$tmpdir/out")
expected="$tmpdir/input"
if [[ "$out" != "$expected" ]]; then echo "-fprint did not truncate and write output file" >&2; exit 1; fi
