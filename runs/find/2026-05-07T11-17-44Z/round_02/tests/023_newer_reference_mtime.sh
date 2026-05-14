#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/ref"
: > "$tmpdir/root/old"
: > "$tmpdir/root/new"
touch -d '2000-01-01 UTC' "$tmpdir/ref" "$tmpdir/root/old"
touch -d '2001-01-01 UTC' "$tmpdir/root/new"
out=$("$UTIL" "$tmpdir/root" -type f -newer "$tmpdir/ref" -printf '%f\n')
expected='new'
if [[ "$out" != "$expected" ]]; then echo "-newer did not compare modification time to reference" >&2; exit 1; fi
