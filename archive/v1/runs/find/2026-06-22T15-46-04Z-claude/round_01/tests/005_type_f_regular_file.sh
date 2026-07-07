#!/usr/bin/env bash
set -euo pipefail
# Documented: "-type c  File is of type c: ... f  regular file".
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/reg"
mkdir "$tmpdir/dir"

out=$("$UTIL" "$tmpdir" -type f | sort)
expected="$tmpdir/reg"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -type f expected only $expected, got: $out" >&2
    exit 1
fi
