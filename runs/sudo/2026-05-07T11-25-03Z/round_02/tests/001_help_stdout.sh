#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/help.out"
set +e
"$UTIL" -h >"$out" 2>"$tmpdir/help.err"
set -e
if ! grep -qi 'usage' "$out"; then
  echo "help output did not contain usage" >&2
  exit 1
fi
