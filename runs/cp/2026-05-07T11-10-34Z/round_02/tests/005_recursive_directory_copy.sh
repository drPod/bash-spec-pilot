#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
srcdir="$tmpdir/srcdir"
dstdir="$tmpdir/dstdir"
mkdir -p "$srcdir/sub"
printf 'nested' > "$srcdir/sub/file.txt"
if ! "$UTIL" -R "$srcdir" "$dstdir"; then
  echo "cp -R failed" >&2
  exit 1
fi
if [[ $(cat "$dstdir/sub/file.txt") == 'nested' ]]; then
  exit 0
else
  echo "recursive copy missing nested content" >&2
  exit 1
fi
