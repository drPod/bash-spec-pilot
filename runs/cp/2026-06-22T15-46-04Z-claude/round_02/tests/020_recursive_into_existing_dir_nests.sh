#!/usr/bin/env bash
set -euo pipefail
# "multiple SOURCE(s) to DIRECTORY" + -r "copy directories recursively".
# A directory SOURCE copied into an existing DIRECTORY is placed as a child
# named after the source (DIRECTORY/srcdir/...), not merged into DIRECTORY root.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

srcdir="$tmpdir/srcdir"
existing="$tmpdir/existing"
mkdir -p "$srcdir"
mkdir -p "$existing"
printf 'L' > "$srcdir/leaf.txt"

"$UTIL" -r "$srcdir" "$existing"

if [[ "$(cat "$existing/srcdir/leaf.txt" 2>/dev/null)" != "L" ]]; then
  echo "FAIL: -r into existing DIRECTORY did not nest source dir as a child" >&2
  exit 1
fi
