#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'timestamped' > "$src"
touch -d '2001-02-03 04:05:06 UTC' "$src"
if ! "$UTIL" --preserve=timestamps "$src" "$dst"; then
  echo "cp --preserve=timestamps failed" >&2
  exit 1
fi
if [[ $(stat -c '%Y' "$dst") == $(stat -c '%Y' "$src") ]]; then
  exit 0
else
  echo "timestamp was not preserved" >&2
  exit 1
fi
