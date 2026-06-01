#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
dst="$tmpdir/dst"
printf 'new' > "$src"
printf 'old' > "$dst"
"$UTIL" -f -n "$src" "$dst"
if [[ "$(<"$dst")" == "old" ]]; then
  exit 0
else
  echo "final -n did not prevent overwrite" >&2
  exit 1
fi
