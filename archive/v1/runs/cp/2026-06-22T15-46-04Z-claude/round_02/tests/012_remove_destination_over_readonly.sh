#!/usr/bin/env bash
set -euo pipefail
# --remove-destination : "remove each existing destination file before
# attempting to open it (contrast with --force)".
# A read-only existing DEST cannot be opened for write; removing it first
# lets the copy succeed and replace the content.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'NEW' > "$src"
printf 'OLD' > "$dst"
chmod 0444 "$dst"

"$UTIL" --remove-destination "$src" "$dst"

if [[ "$(cat "$dst")" != "NEW" ]]; then
  echo "FAIL: --remove-destination did not replace read-only DEST content" >&2
  exit 1
fi
