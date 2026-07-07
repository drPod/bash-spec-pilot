#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir "$tmpdir/dir"
printf 'a\n' > "$tmpdir/a"
printf 'b\n' > "$tmpdir/b"
"$UTIL" "$tmpdir/a" "$tmpdir/b" "$tmpdir/dir"
actual=$(find "$tmpdir/dir" -maxdepth 1 -type f -printf '%f\n' | sort | paste -sd, -)
if [[ "$actual" == "a,b" ]]; then
  exit 0
else
  echo "sources were not moved into destination directory" >&2
  exit 1
fi
