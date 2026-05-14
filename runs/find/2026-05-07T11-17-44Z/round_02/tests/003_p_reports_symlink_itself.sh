#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/target"
ln -s "$tmpdir/target" "$tmpdir/root/link"
out=$("$UTIL" -P "$tmpdir/root" -maxdepth 1 -type l -printf '%P\n' | sort)
expected='link'
if [[ "$out" != "$expected" ]]; then echo "-P did not test symlink itself" >&2; exit 1; fi
