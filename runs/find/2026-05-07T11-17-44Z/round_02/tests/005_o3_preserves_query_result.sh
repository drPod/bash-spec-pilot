#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root/sub"
: > "$tmpdir/root/a.txt"
: > "$tmpdir/root/sub/b.txt"
: > "$tmpdir/root/c.log"
out=$("$UTIL" -O3 "$tmpdir/root" -name '*.txt' -type f -printf '%P\n' | sort)
expected=$'a.txt\nsub/b.txt'
if [[ "$out" != "$expected" ]]; then echo "-O3 changed matching result" >&2; exit 1; fi
