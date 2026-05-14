#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root/sub"
: > "$tmpdir/root/sub/file"
out=$("$UTIL" "$tmpdir/root" -maxdepth 0 -printf '%p\n')
expected="$tmpdir/root"
if [[ "$out" != "$expected" ]]; then echo "-maxdepth 0 processed below starting point" >&2; exit 1; fi
