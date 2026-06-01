#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
dst="$tmpdir/dst"
printf 'new' > "$src"
printf 'old' > "$dst"
"$UTIL" --backup=none "$src" "$dst"
count=$(find "$tmpdir" -maxdepth 1 -name 'dst*~' | wc -l | tr -d ' ')
if [[ "$count" == "0" ]]; then
  exit 0
else
  echo "--backup=none created a backup" >&2
  exit 1
fi
