#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

target="$tmpdir/target.txt"
link="$tmpdir/link"
dst="$tmpdir/dst"
printf 'real\n' > "$target"
ln -s "$target" "$link"

# -L, --dereference: always follow symbolic links in SOURCE.
"$UTIL" -L "$link" "$dst"

if [[ -L "$dst" ]]; then
  echo "FAIL: -L produced a symlink instead of following the link to copy the file" >&2
  exit 1
fi
if [[ ! -f "$dst" ]]; then
  echo "FAIL: -L did not produce a regular file at DEST" >&2
  exit 1
fi
