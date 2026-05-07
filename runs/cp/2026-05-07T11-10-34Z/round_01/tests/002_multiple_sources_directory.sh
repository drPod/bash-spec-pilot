#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
a="$tmpdir/a.txt"
b="$tmpdir/b.txt"
out="$tmpdir/out"
printf 'a\n' > "$a"
printf 'b\n' > "$b"
mkdir "$out"
if ! "$UTIL" "$a" "$b" "$out"; then echo "cp failed" >&2; exit 1; fi
count=$(find "$out" -maxdepth 1 -type f | wc -l)
if [[ "$count" -eq 2 ]]; then exit 0; fi
echo "expected two files in target directory" >&2
exit 1
