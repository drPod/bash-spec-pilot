#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/root/old"
: > "$tmpdir/root/new"
touch -d '2000-01-01 UTC' "$tmpdir/root/old"
touch -d '2001-01-01 UTC' "$tmpdir/root/new"
out=$("$UTIL" "$tmpdir/root" -type f -newermt '2000-06-01 UTC' -printf '%f\n')
expected='new'
if [[ "$out" != "$expected" ]]; then echo "-newermt did not interpret direct time threshold" >&2; exit 1; fi
