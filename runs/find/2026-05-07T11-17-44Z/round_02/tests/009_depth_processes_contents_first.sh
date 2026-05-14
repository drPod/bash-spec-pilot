#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root/sub"
: > "$tmpdir/root/sub/file"
out=$("$UTIL" "$tmpdir/root" -depth -printf '%P\n')
expected=$'sub/file\nsub'
if [[ "$out" != "$expected" ]]; then echo "-depth did not process contents before directories" >&2; exit 1; fi
