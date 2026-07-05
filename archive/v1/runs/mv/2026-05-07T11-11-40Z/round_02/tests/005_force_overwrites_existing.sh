#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"
"$UTIL" -f "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst") == "new" ]]; then
  exit 0
else
  echo "-f did not overwrite existing destination" >&2
  exit 1
fi
