#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --backup: make a backup of each existing destination file. Default suffix '~'.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
"$UTIL" --backup "$tmpdir/src" "$tmpdir/dst"
if [[ -f "$tmpdir/dst~" && "$(cat "$tmpdir/dst~")" == old && "$(cat "$tmpdir/dst")" == new ]]; then
  exit 0
fi
echo "--backup did not create dst~ holding previous contents" >&2
exit 1
