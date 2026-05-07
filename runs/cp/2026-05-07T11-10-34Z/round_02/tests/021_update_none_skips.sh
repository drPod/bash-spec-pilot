#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'new' > "$src"
printf 'old' > "$dst"
if ! "$UTIL" --update=none "$src" "$dst"; then
  echo "cp --update=none failed" >&2
  exit 1
fi
if [[ $(cat "$dst") == 'old' ]]; then
  exit 0
else
  echo "--update=none replaced existing destination" >&2
  exit 1
fi
