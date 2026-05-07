#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'older source' > "$src"
printf 'newer dest' > "$dst"
touch -d '2001-01-01 00:00:00 UTC' "$src"
touch -d '2002-01-01 00:00:00 UTC' "$dst"
if ! "$UTIL" -u "$src" "$dst"; then
  echo "cp -u failed" >&2
  exit 1
fi
if [[ $(cat "$dst") == 'newer dest' ]]; then
  exit 0
else
  echo "-u replaced a newer destination" >&2
  exit 1
fi
