#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
a="$tmpdir/a"
b="$tmpdir/b"
dir="$tmpdir/dir"
mkdir "$dir"
printf 'a' > "$a"
printf 'b' > "$b"
"$UTIL" "$a" "$b" "$dir"
count=$(find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' ')
if [[ "$count" == "2" ]]; then
  exit 0
else
  echo "multi-source move did not place both files in directory" >&2
  exit 1
fi
