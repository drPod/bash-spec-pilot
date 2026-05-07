#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'linked' > "$src"
if ! "$UTIL" -l "$src" "$dst"; then
  echo "cp -l failed" >&2
  exit 1
fi
if [[ $(stat -c '%d:%i' "$src") == $(stat -c '%d:%i' "$dst") ]]; then
  exit 0
else
  echo "destination is not a hard link to source" >&2
  exit 1
fi
