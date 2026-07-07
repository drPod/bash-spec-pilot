#!/usr/bin/env bash
set -euo pipefail
# -S, --suffix=SUFFIX : "override the usual backup suffix" with --backup.
# Backup of existing DEST uses the given suffix instead of '~'.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset SIMPLE_BACKUP_SUFFIX VERSION_CONTROL || true

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'NEW' > "$src"
printf 'OLD' > "$dst"

"$UTIL" --backup --suffix=.bak "$src" "$dst"

if [[ "$(cat "$dst.bak" 2>/dev/null)" != "OLD" ]]; then
  echo "FAIL: custom backup suffix not honored; '$dst.bak' missing/wrong" >&2
  exit 1
fi
