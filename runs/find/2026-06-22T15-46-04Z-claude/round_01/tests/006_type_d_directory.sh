#!/usr/bin/env bash
set -euo pipefail
# Documented: "-type c ... d  directory".
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir "$tmpdir/dir"
: > "$tmpdir/reg"

# Starting point itself is a directory, so it is also -type d.
out=$("$UTIL" "$tmpdir" -type d | sort)
expected=$(printf '%s\n%s\n' "$tmpdir" "$tmpdir/dir" | sort)
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -type d expected {$tmpdir, $tmpdir/dir}, got: $out" >&2
    exit 1
fi
