#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
SIMPLE_BACKUP_SUFFIX='~' "$UTIL" --backup=simple "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst~")" == "old" ]]; then
  exit 0
else
  echo "--backup=simple did not preserve old destination backup" >&2
  exit 1
fi
