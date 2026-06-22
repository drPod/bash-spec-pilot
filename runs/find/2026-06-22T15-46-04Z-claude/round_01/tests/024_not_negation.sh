#!/usr/bin/env bash
set -euo pipefail
# Documented: "! expr  True if expr is false."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/keep.txt"
: > "$tmpdir/drop.log"

# Among regular files, ! -name '*.log' keeps only keep.txt.
out=$("$UTIL" "$tmpdir" -type f ! -name '*.log' | sort)
expected="$tmpdir/keep.txt"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: ! -name '*.log' expected only $expected, got: $out" >&2
    exit 1
fi
