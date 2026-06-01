#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset VERSION_CONTROL
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
SIMPLE_BACKUP_SUFFIX=.bak "$UTIL" --backup "$tmpdir/src" "$tmpdir/dst"
if ! grep -qx 'old' "$tmpdir/dst.bak"; then
  echo "SIMPLE_BACKUP_SUFFIX backup not created with old contents" >&2
  exit 1
fi
