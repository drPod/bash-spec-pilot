#!/usr/bin/env bash
set -euo pipefail
# Documented: "-empty  File is empty and is either a regular file or a directory."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/empty_file"
printf 'x' > "$tmpdir/nonempty_file"
mkdir "$tmpdir/empty_dir"
mkdir "$tmpdir/nonempty_dir"
printf 'data' > "$tmpdir/nonempty_dir/child"

out=$("$UTIL" "$tmpdir" -empty | sort)
expected=$(printf '%s\n%s\n' "$tmpdir/empty_dir" "$tmpdir/empty_file" | sort)
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -empty expected {empty_dir, empty_file}, got: $out" >&2
    exit 1
fi
