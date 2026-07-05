#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
target="$tmpdir/target.txt"
link="$tmpdir/link.txt"
dst="$tmpdir/copied_link.txt"
printf 'target data' > "$target"
ln -s "$target" "$link"
if ! "$UTIL" -P "$link" "$dst"; then
  echo "cp -P failed" >&2
  exit 1
fi
if [[ -L "$dst" ]]; then
  exit 0
else
  echo "-P did not copy symlink itself" >&2
  exit 1
fi
