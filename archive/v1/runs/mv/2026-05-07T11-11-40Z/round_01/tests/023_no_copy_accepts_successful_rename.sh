#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'data\n' > "$tmpdir/src"
"$UTIL" --no-copy "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == "data" ]]; then
  exit 0
else
  echo "--no-copy did not allow a successful rename" >&2
  exit 1
fi
