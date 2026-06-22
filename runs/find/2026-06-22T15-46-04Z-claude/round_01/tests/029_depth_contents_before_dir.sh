#!/usr/bin/env bash
set -euo pipefail
# Documented: "-depth  Process each directory's contents before the directory
# itself." The page documents this ordering, so we assert order (not set).
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir "$tmpdir/d"
: > "$tmpdir/d/child"

# With -depth, the child must be printed before its containing directory d.
out=$("$UTIL" "$tmpdir/d" -depth)
child_line=$(printf '%s\n' "$out" | grep -nxF "$tmpdir/d/child" | cut -d: -f1)
dir_line=$(printf '%s\n' "$out" | grep -nxF "$tmpdir/d" | cut -d: -f1)
if [[ -z "$child_line" || -z "$dir_line" || "$child_line" -ge "$dir_line" ]]; then
    echo "FAIL: -depth should print child before its directory; child@$child_line dir@$dir_line" >&2
    exit 1
fi
