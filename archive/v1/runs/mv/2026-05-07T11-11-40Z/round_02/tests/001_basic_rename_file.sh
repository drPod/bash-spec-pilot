#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'hello\n' > "$tmpdir/src"
"$UTIL" "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst") == "hello" ]]; then
  exit 0
else
  echo "destination content after rename is wrong" >&2
  exit 1
fi
