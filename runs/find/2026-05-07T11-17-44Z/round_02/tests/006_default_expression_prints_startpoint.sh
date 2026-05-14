#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/file"
out=$("$UTIL" "$tmpdir/file")
expected="$tmpdir/file"
if [[ "$out" != "$expected" ]]; then echo "default expression was not -print" >&2; exit 1; fi
