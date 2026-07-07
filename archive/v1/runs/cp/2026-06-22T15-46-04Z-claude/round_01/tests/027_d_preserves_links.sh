#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

target="$tmpdir/target.txt"
link="$tmpdir/link"
dst="$tmpdir/dst"
printf 'real\n' > "$target"
ln -s "$target" "$link"

# -d: same as --no-dereference --preserve=links; SOURCE symlink stays a symlink.
"$UTIL" -d "$link" "$dst"

if [[ ! -L "$dst" ]]; then
  echo "FAIL: -d did not preserve the SOURCE symlink (no-dereference) at DEST" >&2
  exit 1
fi
