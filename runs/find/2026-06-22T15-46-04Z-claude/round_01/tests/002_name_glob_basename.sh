#!/usr/bin/env bash
set -euo pipefail
# Documented: "-name pattern  Base of file name ... matches shell pattern pattern".
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/alpha.txt"
: > "$tmpdir/beta.log"

out=$("$UTIL" "$tmpdir" -name '*.txt' | sort)
expected="$tmpdir/alpha.txt"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -name '*.txt' expected only $expected, got: $out" >&2
    exit 1
fi
