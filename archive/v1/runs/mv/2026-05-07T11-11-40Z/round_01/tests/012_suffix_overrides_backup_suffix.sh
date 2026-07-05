#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
"$UTIL" --backup=simple --suffix=.bak "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst.bak")" == "old" ]]; then
  exit 0
else
  echo "--suffix did not set backup suffix" >&2
  exit 1
fi
