#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Rename SOURCE to DEST.
echo hello > "$tmpdir/src"
"$UTIL" "$tmpdir/src" "$tmpdir/dst"
if [[ ! -e "$tmpdir/src" && -f "$tmpdir/dst" && "$(cat "$tmpdir/dst")" == hello ]]; then
  exit 0
fi
echo "rename did not move src->dst with content preserved" >&2
exit 1
