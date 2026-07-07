#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'incoming\n' > "$src"
printf 'previous\n' > "$dst"

# -b: like --backup but does not accept an argument; default suffix '~'
"$UTIL" -b "$src" "$dst"

if [[ ! -f "$dst~" ]]; then
  echo "FAIL: -b did not create a backup file" >&2
  exit 1
fi
