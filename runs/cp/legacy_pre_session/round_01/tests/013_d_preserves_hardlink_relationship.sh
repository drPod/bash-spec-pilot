#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src1="$tmpdir/a.txt"
src2="$tmpdir/b.txt"
out="$tmpdir/out"
printf 'linked pair\n' > "$src1"
ln "$src1" "$src2"
mkdir -p "$out"
if ! "$UTIL" -d "$src1" "$src2" "$out"; then echo "-d copy failed" >&2; exit 1; fi
if [[ "$(stat -c %i "$out/a.txt")" == "$(stat -c %i "$out/b.txt")" ]]; then exit 0; else echo "hard-link relationship was not preserved" >&2; exit 1; fi
