#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/a"
: > "$tmpdir/b"
printf '%s\0%s\0' "$tmpdir/a" "$tmpdir/b" > "$tmpdir/list"
out=$("$UTIL" -files0-from "$tmpdir/list" -maxdepth 0 -printf '%f\n' | sort)
expected=$'a\nb'
if [[ "$out" != "$expected" ]]; then echo "-files0-from did not read NUL-separated start points" >&2; exit 1; fi
