#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'data\n' > "$tmpdir/src"
out=$("$UTIL" -v "$tmpdir/src" "$tmpdir/dst")
if [[ -n "$out" ]]; then
  exit 0
else
  echo "-v produced no explanation" >&2
  exit 1
fi
