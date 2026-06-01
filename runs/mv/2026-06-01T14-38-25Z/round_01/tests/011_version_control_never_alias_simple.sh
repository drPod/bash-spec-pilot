#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset SIMPLE_BACKUP_SUFFIX
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
printf 'prior\n' > "$tmpdir/dst.~1~"
VERSION_CONTROL=never "$UTIL" --backup "$tmpdir/src" "$tmpdir/dst"
if ! grep -qx 'old' "$tmpdir/dst~"; then
  echo "VERSION_CONTROL=never did not behave like simple" >&2
  exit 1
fi
