#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'data\n' > "$tmpdir/src"
"$UTIL" -T "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == "data" ]]; then
  exit 0
else
  echo "-T rename did not create destination file" >&2
  exit 1
fi
