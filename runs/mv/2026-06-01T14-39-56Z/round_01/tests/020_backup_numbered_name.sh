#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
dst="$tmpdir/dst"
printf 'new' > "$src"
printf 'old' > "$dst"
"$UTIL" --backup=numbered "$src" "$dst"
if [[ -f "$dst.~1~" ]]; then
  exit 0
else
  echo "numbered backup was not created" >&2
  exit 1
fi
