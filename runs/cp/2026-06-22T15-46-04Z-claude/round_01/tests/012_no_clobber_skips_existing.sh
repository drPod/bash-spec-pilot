#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'new\n' > "$src"
printf 'original\n' > "$dst"

# -n, --no-clobber: silently skip existing files
"$UTIL" -n "$src" "$dst"

if [[ "$(cat "$dst")" != "original" ]]; then
  echo "FAIL: -n did not skip existing destination file" >&2
  exit 1
fi
