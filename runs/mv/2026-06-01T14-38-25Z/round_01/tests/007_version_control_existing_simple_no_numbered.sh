#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset SIMPLE_BACKUP_SUFFIX
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
VERSION_CONTROL=existing "$UTIL" --backup "$tmpdir/src" "$tmpdir/dst"
if ! grep -qx 'old' "$tmpdir/dst~"; then
  echo "VERSION_CONTROL=existing without numbered backups did not make simple backup" >&2
  exit 1
fi
