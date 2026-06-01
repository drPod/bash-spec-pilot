#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"

"$UTIL" -n -f "$tmpdir/src" "$tmpdir/dst"
content="$(cat "$tmpdir/dst" 2>/dev/null || true)"

if [[ $content == "new" ]]; then
  exit 0
else
  echo "expected final -f to override -n" >&2
  exit 1
fi
