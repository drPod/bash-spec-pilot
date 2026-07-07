#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
target="$tmpdir/target.txt"
dst="$tmpdir/dstlink"
printf 'new data' > "$src"
printf 'old target' > "$target"
ln -s "$target" "$dst"
if ! "$UTIL" --remove-destination "$src" "$dst"; then
  echo "cp --remove-destination failed" >&2
  exit 1
fi
if [[ ! -L "$dst" && $(cat "$dst") == 'new data' ]]; then
  exit 0
else
  echo "destination symlink was not removed before copy" >&2
  exit 1
fi
