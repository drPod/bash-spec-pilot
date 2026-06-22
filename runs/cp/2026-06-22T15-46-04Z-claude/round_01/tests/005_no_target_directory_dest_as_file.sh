#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst"
printf 'payload\n' > "$src"

# -T treats DEST as a normal file: DEST itself becomes the copy, not DEST/src.txt
"$UTIL" -T "$src" "$dst"

if [[ ! -f "$dst" ]]; then
  echo "FAIL: -T did not create DEST as a normal file" >&2
  exit 1
fi
if [[ "$(cat "$dst")" != "payload" ]]; then
  echo "FAIL: -T DEST content does not match SOURCE" >&2
  exit 1
fi
