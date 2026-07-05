#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
printf abc > "$tmpdir/root/three"
printf abcd > "$tmpdir/root/four"
: > "$tmpdir/root/zero"
out=$("$UTIL" "$tmpdir/root" -type f -size 3c -printf '%f\n')
expected='three'
if [[ "$out" != "$expected" ]]; then echo "-size 3c did not match exact byte size" >&2; exit 1; fi
