#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root/child"
out=$("$UTIL" "$tmpdir/root" -mindepth 1 -maxdepth 1 -printf '%P\n' | sort)
expected='child'
if [[ "$out" != "$expected" ]]; then echo "-mindepth 1 did not skip starting point" >&2; exit 1; fi
