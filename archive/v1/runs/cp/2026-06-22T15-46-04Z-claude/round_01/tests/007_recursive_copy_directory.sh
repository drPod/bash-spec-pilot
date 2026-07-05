#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

srcdir="$tmpdir/srcdir"
dstdir="$tmpdir/dstdir"
mkdir "$srcdir"
printf 'nested\n' > "$srcdir/inner.txt"

"$UTIL" -R "$srcdir" "$dstdir"

if [[ ! -f "$dstdir/inner.txt" ]]; then
  echo "FAIL: -R did not recursively copy directory contents" >&2
  exit 1
fi
