#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'new' > "$src"
printf 'old' > "$dst"
if ! VERSION_CONTROL=simple "$UTIL" --backup "$src" "$dst"; then
  echo "cp --backup failed" >&2
  exit 1
fi
if [[ $(cat "$dst~") == 'old' ]]; then
  exit 0
else
  echo "simple backup does not contain old destination" >&2
  exit 1
fi
