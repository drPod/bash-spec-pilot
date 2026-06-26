#!/usr/bin/env bash
set -euo pipefail
# "Copy SOURCE to DEST, or multiple SOURCE(s) to DIRECTORY."
# A single SOURCE with an existing DIRECTORY dest lands at DIRECTORY/basename.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/file.txt"
dir="$tmpdir/into"
printf 'X' > "$src"
mkdir -p "$dir"

"$UTIL" "$src" "$dir"

if [[ "$(cat "$dir/file.txt" 2>/dev/null)" != "X" ]]; then
  echo "FAIL: SOURCE not placed at DIRECTORY/basename" >&2
  exit 1
fi
