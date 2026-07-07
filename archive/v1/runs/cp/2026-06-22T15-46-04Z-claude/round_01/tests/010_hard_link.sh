#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'linkme\n' > "$src"

# -l, --link: hard link files instead of copying
"$UTIL" -l "$src" "$dst"

src_ino=$(ls -i "$src" | awk '{print $1}')
dst_ino=$(ls -i "$dst" | awk '{print $1}')
if [[ "$src_ino" != "$dst_ino" ]]; then
  echo "FAIL: -l did not hard link (inodes differ)" >&2
  exit 1
fi
