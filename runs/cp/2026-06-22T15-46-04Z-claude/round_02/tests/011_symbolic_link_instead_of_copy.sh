#!/usr/bin/env bash
set -euo pipefail
# -s, --symbolic-link : "make symbolic links instead of copying"
# DEST must be a symbolic link (not a regular-file copy).
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'data' > "$src"

"$UTIL" -s "$src" "$dst"

if [[ ! -L "$dst" ]]; then
  echo "FAIL: -s did not create a symbolic link at DEST" >&2
  exit 1
fi
