#!/usr/bin/env bash
set -euo pipefail
# -u / --update[=older] : 'older' "results in files being replaced if they're
# older than the corresponding source file."
# DEST newer than SOURCE => DEST is NOT replaced.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'NEW' > "$src"
printf 'OLD' > "$dst"
touch -d '2020-01-01 00:00:00' "$src"
touch -d '2025-01-01 00:00:00' "$dst"

"$UTIL" -u "$src" "$dst"

if [[ "$(cat "$dst")" != "OLD" ]]; then
  echo "FAIL: -u replaced a DEST that is newer than SOURCE" >&2
  exit 1
fi
