#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"
"$UTIL" -b -S .bak "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst.bak") == "old" ]]; then
  exit 0
else
  echo "-b with -S did not create backup using custom suffix" >&2
  exit 1
fi
