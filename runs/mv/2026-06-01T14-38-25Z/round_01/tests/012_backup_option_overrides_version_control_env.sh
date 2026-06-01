#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset SIMPLE_BACKUP_SUFFIX
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
VERSION_CONTROL=numbered "$UTIL" --backup=simple "$tmpdir/src" "$tmpdir/dst"
if ! grep -qx 'old' "$tmpdir/dst~"; then
  echo "--backup=simple did not override VERSION_CONTROL=numbered" >&2
  exit 1
fi
