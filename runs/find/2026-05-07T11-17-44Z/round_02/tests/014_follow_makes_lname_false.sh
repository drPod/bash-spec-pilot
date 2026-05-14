#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/target"
ln -s "$tmpdir/target" "$tmpdir/root/link"
out=$("$UTIL" "$tmpdir/root" -follow -lname '*' -printf '%P\n')
expected=''
if [[ "$out" != "$expected" ]]; then echo "-follow did not make -lname false for resolved symlink" >&2; exit 1; fi
