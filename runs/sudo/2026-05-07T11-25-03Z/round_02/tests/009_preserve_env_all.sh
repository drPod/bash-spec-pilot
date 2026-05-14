#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/preserve_all.out"
set +e
KEEP_ME_123=all "$UTIL" -n -E /usr/bin/env >"$out" 2>"$tmpdir/preserve_all.err"
set -e
if ! grep -qx 'KEEP_ME_123=all' "$out"; then
  echo "preserve-env did not preserve existing variable" >&2
  exit 1
fi
