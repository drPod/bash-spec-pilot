#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -b: like --backup but does not accept an argument. Default suffix '~'.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
"$UTIL" -b "$tmpdir/src" "$tmpdir/dst"
if [[ -f "$tmpdir/dst~" && "$(cat "$tmpdir/dst~")" == old && "$(cat "$tmpdir/dst")" == new ]]; then
  exit 0
fi
echo "-b did not create dst~ holding previous contents" >&2
exit 1
