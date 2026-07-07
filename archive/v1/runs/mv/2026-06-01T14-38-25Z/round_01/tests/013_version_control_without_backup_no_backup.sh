#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset SIMPLE_BACKUP_SUFFIX
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
VERSION_CONTROL=numbered "$UTIL" "$tmpdir/src" "$tmpdir/dst"
if [[ -e "$tmpdir/dst~" || -e "$tmpdir/dst.~1~" ]]; then
  echo "VERSION_CONTROL alone caused a backup without --backup" >&2
  exit 1
fi
