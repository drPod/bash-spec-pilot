#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
dst="$tmpdir/dst"
printf 'new' > "$src"
printf 'old' > "$dst"
"$UTIL" -n -f "$src" "$dst"
if [[ "$(<"$dst")" == "new" ]]; then
  exit 0
else
  echo "final -f did not overwrite destination" >&2
  exit 1
fi
