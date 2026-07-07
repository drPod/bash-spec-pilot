#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
printf data > "$tmpdir/root/original"
ln "$tmpdir/root/original" "$tmpdir/root/link"
: > "$tmpdir/root/other"
out=$("$UTIL" "$tmpdir/root" -samefile "$tmpdir/root/original" -printf '%f\n' | sort)
expected=$'link\noriginal'
if [[ "$out" != "$expected" ]]; then echo "-samefile did not match hard links to same inode" >&2; exit 1; fi
