#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root" "$tmpdir/target"
: > "$tmpdir/target/child"
ln -s "$tmpdir/target" "$tmpdir/root/link"
out=$("$UTIL" -L "$tmpdir/root" -type f -printf '%P\n' | sort)
expected='link/child'
if [[ "$out" != "$expected" ]]; then echo "-L did not recurse into symlinked directory" >&2; exit 1; fi
