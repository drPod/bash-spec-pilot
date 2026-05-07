#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/realdir"
: > "$tmpdir/realdir/inside"
ln -s "$tmpdir/realdir" "$tmpdir/linkdir"
if ! actual=$("$UTIL" -L "$tmpdir/linkdir" -type f -printf '%P\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "inside" ]]; then
  echo "-L did not descend into a symlinked directory" >&2
  exit 1
fi
