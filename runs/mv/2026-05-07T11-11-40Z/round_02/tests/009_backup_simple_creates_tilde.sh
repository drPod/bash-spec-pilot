#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"
VERSION_CONTROL=simple "$UTIL" --backup "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst~") == "old" ]]; then
  exit 0
else
  echo "simple backup does not contain old destination" >&2
  exit 1
fi
