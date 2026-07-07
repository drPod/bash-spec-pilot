#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
VERSION_CONTROL=simple SIMPLE_BACKUP_SUFFIX='~' "$UTIL" -b "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst~")" == "old" ]]; then
  exit 0
else
  echo "-b did not create a simple backup of destination" >&2
  exit 1
fi
