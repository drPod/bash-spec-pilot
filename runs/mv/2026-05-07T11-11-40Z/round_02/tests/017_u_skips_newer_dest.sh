#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'oldsrc' > "$tmpdir/src"
printf 'newdst' > "$tmpdir/dst"
touch -d '2000-01-01 00:00:00' "$tmpdir/src"
touch -d '2030-01-01 00:00:00' "$tmpdir/dst"
"$UTIL" -u "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst") == "newdst" ]]; then
  exit 0
else
  echo "-u replaced a newer destination" >&2
  exit 1
fi
