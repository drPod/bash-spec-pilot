#!/usr/bin/env bash
set -euo pipefail
# Documented: "-path pattern  File name matches shell pattern pattern. The
# metacharacters do not treat `/' or `.' specially". Match is on the whole name
# starting from the start point.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/src/misc"
: > "$tmpdir/src/misc/file"
mkdir -p "$tmpdir/other"
: > "$tmpdir/other/file"

# Pattern with '*' spanning a slash matches the whole path under start point.
out=$("$UTIL" "$tmpdir" -path "$tmpdir/src*misc" | sort)
expected="$tmpdir/src/misc"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -path '$tmpdir/src*misc' expected $expected, got: $out" >&2
    exit 1
fi
