#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

srcdir="$tmpdir/srcdir"
dstdir="$tmpdir/dstdir"
mkdir "$srcdir"
mkdir "$srcdir/sub"
printf 'deep\n' > "$srcdir/sub/deep.txt"

# -r is documented as same as -R
"$UTIL" -r "$srcdir" "$dstdir"

if [[ ! -f "$dstdir/sub/deep.txt" ]]; then
  echo "FAIL: -r did not recursively copy nested subdirectory" >&2
  exit 1
fi
