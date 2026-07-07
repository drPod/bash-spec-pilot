#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
destdir="$tmpdir/dest"
printf 'data\n' > "$src"
mkdir "$destdir"

# --strip-trailing-slashes: remove any trailing slashes from each SOURCE argument.
# A trailing slash on a regular-file SOURCE is stripped, so the copy succeeds.
"$UTIL" --strip-trailing-slashes "$src/" "$destdir"

if [[ ! -f "$destdir/src.txt" ]]; then
  echo "FAIL: --strip-trailing-slashes did not allow copy of SOURCE given with trailing slash" >&2
  exit 1
fi
