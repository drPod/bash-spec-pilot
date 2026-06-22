#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
destdir="$tmpdir/dest"
printf 'data\n' > "$src"
mkdir "$destdir"

"$UTIL" --target-directory="$destdir" "$src"

if [[ ! -f "$destdir/src.txt" ]]; then
  echo "FAIL: --target-directory did not copy SOURCE into DIRECTORY" >&2
  exit 1
fi
