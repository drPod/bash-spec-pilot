#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'hello world\n' > "$src"

"$UTIL" "$src" "$dst"

if [[ ! -f "$dst" ]]; then
  echo "FAIL: DEST was not created by basic copy" >&2
  exit 1
fi
if [[ "$(cat "$dst")" != "hello world" ]]; then
  echo "FAIL: DEST content does not match SOURCE" >&2
  exit 1
fi
