#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

f="$tmpdir/same.txt"
printf 'content\n' > "$f"

# Special case: cp makes a backup of SOURCE when the force and backup options
# are given and SOURCE and DEST are the same name for an existing, regular file.
"$UTIL" --force --backup "$f" "$f"

if [[ ! -f "$f~" ]]; then
  echo "FAIL: force+backup with SOURCE==DEST did not create a backup of SOURCE" >&2
  exit 1
fi
