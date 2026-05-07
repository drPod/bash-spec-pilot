#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
targetdir="$tmpdir/targetdir"
linkdir="$tmpdir/linkdir"
dst="$tmpdir/copied_link"
mkdir "$targetdir"
ln -s "$targetdir" "$linkdir"
if ! "$UTIL" -P --strip-trailing-slashes "$linkdir/" "$dst"; then
  echo "cp --strip-trailing-slashes failed" >&2
  exit 1
fi
if [[ -L "$dst" ]]; then
  exit 0
else
  echo "trailing slash was not stripped before copying symlink" >&2
  exit 1
fi
