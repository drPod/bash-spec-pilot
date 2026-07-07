#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'newer source' > "$src"
printf 'older dest' > "$dst"
touch -d '2001-01-01 00:00:00 UTC' "$dst"
touch -d '2002-01-01 00:00:00 UTC' "$src"
if ! "$UTIL" --update=older "$src" "$dst"; then
  echo "cp --update=older failed" >&2
  exit 1
fi
if [[ $(cat "$dst") == 'newer source' ]]; then
  exit 0
else
  echo "--update=older did not replace older destination" >&2
  exit 1
fi
