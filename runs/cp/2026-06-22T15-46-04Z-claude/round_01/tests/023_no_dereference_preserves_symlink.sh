#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

target="$tmpdir/target.txt"
link="$tmpdir/link"
dst="$tmpdir/dst"
printf 'real\n' > "$target"
ln -s "$target" "$link"

# -P, --no-dereference: never follow symbolic links in SOURCE.
"$UTIL" -P "$link" "$dst"

if [[ ! -L "$dst" ]]; then
  echo "FAIL: -P did not preserve SOURCE symlink as a symlink at DEST" >&2
  exit 1
fi
