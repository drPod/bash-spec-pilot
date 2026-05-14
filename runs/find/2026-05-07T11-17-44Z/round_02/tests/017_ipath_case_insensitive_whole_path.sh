#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root/sub"
: > "$tmpdir/root/sub/File"
pattern="$tmpdir/ROOT/SUB/FILE"
out=$("$UTIL" "$tmpdir/root" -ipath "$pattern" -printf '%P\n')
expected='sub/File'
if [[ "$out" != "$expected" ]]; then echo "-ipath did not match whole path case-insensitively" >&2; exit 1; fi
