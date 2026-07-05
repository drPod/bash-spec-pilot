#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
target="$tmpdir/target.txt"
link="$tmpdir/link.txt"
dst="$tmpdir/dst.txt"
printf 'dereferenced data' > "$target"
ln -s "$target" "$link"
if ! "$UTIL" -L "$link" "$dst"; then
  echo "cp -L failed" >&2
  exit 1
fi
if [[ ! -L "$dst" && $(cat "$dst") == 'dereferenced data' ]]; then
  exit 0
else
  echo "-L did not copy symlink referent data" >&2
  exit 1
fi
