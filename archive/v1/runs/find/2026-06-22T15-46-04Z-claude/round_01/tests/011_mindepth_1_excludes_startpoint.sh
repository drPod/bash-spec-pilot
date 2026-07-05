#!/usr/bin/env bash
set -euo pipefail
# Documented: "Using -mindepth 1 means process all files except the
# starting-points."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/a"
: > "$tmpdir/b"

out=$("$UTIL" "$tmpdir" -mindepth 1 | sort)
expected=$(printf '%s\n%s\n' "$tmpdir/a" "$tmpdir/b" | sort)
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -mindepth 1 should exclude start point, got: $out" >&2
    exit 1
fi
