#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --update=all: all existing files in the destination are replaced.
echo old > "$tmpdir/dst"
touch -d '2024-01-01' "$tmpdir/dst"
echo new > "$tmpdir/src"
touch -d '2020-01-01' "$tmpdir/src"
"$UTIL" --update=all "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == new ]]; then
  exit 0
fi
echo "--update=all did not replace the existing destination" >&2
exit 1
