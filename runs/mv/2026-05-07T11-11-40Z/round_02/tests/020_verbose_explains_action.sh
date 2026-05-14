#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'payload' > "$tmpdir/src"
out=$("$UTIL" -v "$tmpdir/src" "$tmpdir/dst" 2>&1)
if [[ -n "$out" ]]; then
  exit 0
else
  echo "-v produced no explanation" >&2
  exit 1
fi
