#!/usr/bin/env bash
set -euo pipefail
# -R, -r, --recursive : "copy directories recursively"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

srcdir="$tmpdir/srcdir"
dstdir="$tmpdir/dstdir"
mkdir -p "$srcdir/sub"
printf 'deep' > "$srcdir/sub/leaf.txt"

"$UTIL" -r "$srcdir" "$dstdir"

if [[ "$(cat "$dstdir/sub/leaf.txt" 2>/dev/null)" != "deep" ]]; then
  echo "FAIL: nested file not present in DEST after recursive copy" >&2
  exit 1
fi
