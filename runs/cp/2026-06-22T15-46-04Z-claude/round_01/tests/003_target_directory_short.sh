#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

a="$tmpdir/a.txt"
b="$tmpdir/b.txt"
destdir="$tmpdir/dest"
printf 'aaa\n' > "$a"
printf 'bbb\n' > "$b"
mkdir "$destdir"

"$UTIL" -t "$destdir" "$a" "$b"

if [[ ! -f "$destdir/a.txt" || ! -f "$destdir/b.txt" ]]; then
  echo "FAIL: -t DIRECTORY did not receive all SOURCE arguments" >&2
  exit 1
fi
