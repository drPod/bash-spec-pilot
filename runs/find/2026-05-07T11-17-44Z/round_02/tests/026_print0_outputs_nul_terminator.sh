#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
file="$tmpdir/name with spaces"
: > "$file"
got=$("$UTIL" "$file" -maxdepth 0 -print0 | od -An -tx1 | tr -d ' \n')
expected=$(printf '%s\0' "$file" | od -An -tx1 | tr -d ' \n')
if [[ "$got" != "$expected" ]]; then echo "-print0 did not output exact NUL-terminated path" >&2; exit 1; fi
