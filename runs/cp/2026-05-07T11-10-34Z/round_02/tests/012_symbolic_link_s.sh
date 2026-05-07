#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'symlink target' > "$src"
if ! "$UTIL" -s "$src" "$dst"; then
  echo "cp -s failed" >&2
  exit 1
fi
if [[ -L "$dst" && $(readlink "$dst") == "$src" ]]; then
  exit 0
else
  echo "destination is not a symlink to source" >&2
  exit 1
fi
