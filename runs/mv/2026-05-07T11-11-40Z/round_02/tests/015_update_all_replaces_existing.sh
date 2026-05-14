#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"
touch -d '2000-01-01 00:00:00' "$tmpdir/src"
touch -d '2030-01-01 00:00:00' "$tmpdir/dst"
"$UTIL" --update=all "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst") == "new" ]]; then
  exit 0
else
  echo "--update=all did not replace existing destination" >&2
  exit 1
fi
