#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# mv SOURCE... DIRECTORY: all sources land inside the directory.
echo a > "$tmpdir/a"
echo b > "$tmpdir/b"
mkdir "$tmpdir/dir"
"$UTIL" "$tmpdir/a" "$tmpdir/b" "$tmpdir/dir"
if [[ ! -e "$tmpdir/a" && ! -e "$tmpdir/b" && -f "$tmpdir/dir/a" && -f "$tmpdir/dir/b" ]]; then
  exit 0
fi
echo "both sources were not moved into directory" >&2
exit 1
