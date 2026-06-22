#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

srcdir="$tmpdir/srcdir"
dstdir="$tmpdir/dstdir"
mkdir "$srcdir"
mkdir "$srcdir/sub"
printf 'leaf\n' > "$srcdir/sub/leaf.txt"

# -a, --archive: same as -dR --preserve=all; -R implies recursive directory copy.
"$UTIL" -a "$srcdir" "$dstdir"

if [[ ! -f "$dstdir/sub/leaf.txt" ]]; then
  echo "FAIL: -a (archive, includes -R) did not recursively copy directory tree" >&2
  exit 1
fi
