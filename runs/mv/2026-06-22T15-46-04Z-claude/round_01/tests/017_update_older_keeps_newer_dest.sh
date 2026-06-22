#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# 'older' results in files being replaced if they're older than the source;
# a newer destination is therefore NOT replaced.
echo keep > "$tmpdir/dst"
touch -d '2024-01-01' "$tmpdir/dst"
echo new > "$tmpdir/src"
touch -d '2020-01-01' "$tmpdir/src"
"$UTIL" --update=older "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == keep ]]; then
  exit 0
fi
echo "--update=older replaced a destination newer than the source" >&2
exit 1
