#!/usr/bin/env bash
set -euo pipefail
# cp [OPTION]... [-T] SOURCE DEST -> "Copy SOURCE to DEST"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'hello' > "$src"

"$UTIL" "$src" "$dst"

if [[ "$(cat "$dst")" != "hello" ]]; then
  echo "FAIL: DEST content does not match SOURCE after basic copy" >&2
  exit 1
fi
