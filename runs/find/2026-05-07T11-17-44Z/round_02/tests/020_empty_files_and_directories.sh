#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root/emptydir" "$tmpdir/root/nonemptydir"
: > "$tmpdir/root/emptyfile"
printf x > "$tmpdir/root/nonemptyfile"
: > "$tmpdir/root/nonemptydir/child"
out=$("$UTIL" "$tmpdir/root" -empty -printf '%P\n' | sort)
expected=$'emptydir\nemptyfile'
if [[ "$out" != "$expected" ]]; then echo "-empty did not match exactly empty files and directories" >&2; exit 1; fi
