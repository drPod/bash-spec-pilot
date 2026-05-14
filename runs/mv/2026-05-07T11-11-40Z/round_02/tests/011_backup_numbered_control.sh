#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"
"$UTIL" --backup=numbered "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst.~1~") == "old" ]]; then
  exit 0
else
  echo "numbered backup was not created as .~1~" >&2
  exit 1
fi
