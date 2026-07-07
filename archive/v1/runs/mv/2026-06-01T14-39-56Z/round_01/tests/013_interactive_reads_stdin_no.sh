#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
dst="$tmpdir/dst"
printf 'new' > "$src"
printf 'old' > "$dst"
printf 'n\n' | "$UTIL" -f -i "$src" "$dst"
if [[ "$(<"$dst")" == "old" ]]; then
  exit 0
else
  echo "interactive no response did not preserve destination" >&2
  exit 1
fi
