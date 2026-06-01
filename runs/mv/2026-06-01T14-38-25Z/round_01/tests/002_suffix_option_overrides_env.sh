#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset VERSION_CONTROL
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
SIMPLE_BACKUP_SUFFIX=.env "$UTIL" --backup -S .cmd "$tmpdir/src" "$tmpdir/dst"
if ! grep -qx 'old' "$tmpdir/dst.cmd"; then
  echo "-S did not override SIMPLE_BACKUP_SUFFIX" >&2
  exit 1
fi
