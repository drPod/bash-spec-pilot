#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/preserve_list.out"
set +e
KEEP_LIST_123=list "$UTIL" -n --preserve-env=KEEP_LIST_123 /usr/bin/env >"$out" 2>"$tmpdir/preserve_list.err"
set -e
if ! grep -qx 'KEEP_LIST_123=list' "$out"; then
  echo "preserve-env list did not preserve named variable" >&2
  exit 1
fi
