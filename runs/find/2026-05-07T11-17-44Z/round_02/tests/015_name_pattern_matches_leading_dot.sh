#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/root/.hidden.c"
: > "$tmpdir/root/plain.c"
: > "$tmpdir/root/plain.h"
out=$("$UTIL" "$tmpdir/root" -maxdepth 1 -name '*.c' -printf '%f\n' | sort)
expected=$'.hidden.c\nplain.c'
if [[ "$out" != "$expected" ]]; then echo "-name pattern did not match expected basenames" >&2; exit 1; fi
