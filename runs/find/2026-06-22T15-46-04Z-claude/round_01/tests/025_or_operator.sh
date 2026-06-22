#!/usr/bin/env bash
set -euo pipefail
# Documented: "expr1 -o expr2  Or; expr2 is not evaluated if expr1 is true."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/a.txt"
: > "$tmpdir/b.log"
: > "$tmpdir/c.dat"

# Parenthesised OR keeps the default -print acting on the whole expression.
out=$("$UTIL" "$tmpdir" -type f \( -name '*.txt' -o -name '*.log' \) | sort)
expected=$(printf '%s\n%s\n' "$tmpdir/a.txt" "$tmpdir/b.log" | sort)
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -name '*.txt' -o -name '*.log' expected {a.txt, b.log}, got: $out" >&2
    exit 1
fi
