#!/usr/bin/env bash
set -euo pipefail
# cp [OPTION]... SOURCE... DIRECTORY : "multiple SOURCE(s) to DIRECTORY"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

a="$tmpdir/a.txt"
b="$tmpdir/b.txt"
d="$tmpdir/d"
printf 'A' > "$a"
printf 'B' > "$b"
mkdir -p "$d"

"$UTIL" "$a" "$b" "$d"

if [[ "$(cat "$d/a.txt" 2>/dev/null)" != "A" || "$(cat "$d/b.txt" 2>/dev/null)" != "B" ]]; then
  echo "FAIL: both sources not present by basename inside DIRECTORY" >&2
  exit 1
fi
