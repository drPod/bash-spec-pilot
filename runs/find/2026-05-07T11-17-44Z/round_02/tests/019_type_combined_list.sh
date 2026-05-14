#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root/sub"
: > "$tmpdir/root/file"
: > "$tmpdir/target"
ln -s "$tmpdir/target" "$tmpdir/root/link"
out=$("$UTIL" "$tmpdir/root" -maxdepth 1 -type f,d,l -printf '%y:%P\n' | sort)
expected=$'d:\nd:sub\nf:file\nl:link'
if [[ "$out" != "$expected" ]]; then echo "combined -type list did not match files directories and symlinks" >&2; exit 1; fi
