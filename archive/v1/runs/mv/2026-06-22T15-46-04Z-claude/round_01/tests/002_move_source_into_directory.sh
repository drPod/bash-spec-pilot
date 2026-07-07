#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Move SOURCE to DIRECTORY: file lands inside the directory under its basename.
echo data > "$tmpdir/file"
mkdir "$tmpdir/dir"
"$UTIL" "$tmpdir/file" "$tmpdir/dir"
if [[ ! -e "$tmpdir/file" && -f "$tmpdir/dir/file" ]]; then
  exit 0
fi
echo "file was not moved into directory under its basename" >&2
exit 1
