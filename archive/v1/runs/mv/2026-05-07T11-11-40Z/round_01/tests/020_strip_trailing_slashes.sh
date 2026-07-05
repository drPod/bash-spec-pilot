#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir "$tmpdir/real"
ln -s "$tmpdir/real" "$tmpdir/link"
"$UTIL" --strip-trailing-slashes "$tmpdir/link/" "$tmpdir/movedlink"
if [[ -L "$tmpdir/movedlink" ]]; then
  exit 0
else
  echo "--strip-trailing-slashes did not move the symlink source" >&2
  exit 1
fi
