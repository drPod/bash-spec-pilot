#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'new' > "$src"
printf 'old' > "$dst"
if ! VERSION_CONTROL=simple "$UTIL" --backup -S .bak "$src" "$dst"; then
  echo "cp --backup -S failed" >&2
  exit 1
fi
if [[ $(cat "$dst.bak") == 'old' ]]; then
  exit 0
else
  echo "custom suffix backup missing old data" >&2
  exit 1
fi
