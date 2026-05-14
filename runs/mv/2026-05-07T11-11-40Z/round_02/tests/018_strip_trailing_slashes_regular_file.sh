#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'payload' > "$tmpdir/src"
"$UTIL" --strip-trailing-slashes "$tmpdir/src/" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst") == "payload" ]]; then
  exit 0
else
  echo "--strip-trailing-slashes did not move stripped source" >&2
  exit 1
fi
