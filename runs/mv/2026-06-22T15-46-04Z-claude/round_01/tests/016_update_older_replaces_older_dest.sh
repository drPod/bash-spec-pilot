#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --update=older (also -u default): replace dest if it is older than source.
echo old > "$tmpdir/dst"
touch -d '2020-01-01' "$tmpdir/dst"
echo new > "$tmpdir/src"
touch -d '2024-01-01' "$tmpdir/src"
"$UTIL" --update=older "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == new ]]; then
  exit 0
fi
echo "--update=older did not replace an older destination" >&2
exit 1
