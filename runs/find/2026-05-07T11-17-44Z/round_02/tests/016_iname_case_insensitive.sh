#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/root/Foo"
: > "$tmpdir/root/foo"
: > "$tmpdir/root/bar"
out=$("$UTIL" "$tmpdir/root" -maxdepth 1 -iname 'foo' -printf '%f\n' | sort)
expected=$'Foo\nfoo'
if [[ "$out" != "$expected" ]]; then echo "-iname was not case-insensitive" >&2; exit 1; fi
