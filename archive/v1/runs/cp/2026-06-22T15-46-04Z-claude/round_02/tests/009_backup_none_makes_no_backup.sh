#!/usr/bin/env bash
set -euo pipefail
# VERSION_CONTROL value "none, off : never make backups (even if --backup is given)"
# With --backup=none, no backup file is created.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset SIMPLE_BACKUP_SUFFIX VERSION_CONTROL || true

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'NEW' > "$src"
printf 'OLD' > "$dst"

"$UTIL" --backup=none "$src" "$dst"

if [[ -e "${dst}~" ]]; then
  echo "FAIL: --backup=none created a backup file '${dst}~'" >&2
  exit 1
fi
