#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/root/foo123"
: > "$tmpdir/root/fooX"
out=$("$UTIL" "$tmpdir/root" -regextype posix-extended -regex '.*/foo[0-9]+' -printf '%f\n')
expected='foo123'
if [[ "$out" != "$expected" ]]; then echo "-regextype posix-extended regex did not match expected file" >&2; exit 1; fi
