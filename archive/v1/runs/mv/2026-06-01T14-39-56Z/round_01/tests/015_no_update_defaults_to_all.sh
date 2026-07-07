#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
dst="$tmpdir/dst"
printf 'new' > "$src"
printf 'old' > "$dst"
touch -t 200001010000 "$src"
touch -t 200101010000 "$dst"
"$UTIL" "$src" "$dst"
if [[ "$(<"$dst")" == "new" ]]; then
  exit 0
else
  echo "default update mode did not replace destination" >&2
  exit 1
fi
