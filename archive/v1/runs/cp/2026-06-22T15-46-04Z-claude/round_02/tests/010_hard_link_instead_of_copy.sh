#!/usr/bin/env bash
set -euo pipefail
# -l, --link : "hard link files instead of copying"
# DEST must be a hard link to SOURCE (same inode/device).
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'data' > "$src"

"$UTIL" -l "$src" "$dst"

if [[ ! "$dst" -ef "$src" ]]; then
  echo "FAIL: -l did not hard link DEST to SOURCE (not same inode)" >&2
  exit 1
fi
