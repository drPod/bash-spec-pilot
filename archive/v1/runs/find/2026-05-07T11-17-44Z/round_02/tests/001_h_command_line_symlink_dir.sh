#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/target"
: > "$tmpdir/target/file"
ln -s "$tmpdir/target" "$tmpdir/linkdir"
out=$("$UTIL" -H "$tmpdir/linkdir" -maxdepth 1 -type f -printf '%f\n' | sort)
expected='file'
if [[ "$out" != "$expected" ]]; then echo "-H did not examine command-line symlink directory" >&2; exit 1; fi
