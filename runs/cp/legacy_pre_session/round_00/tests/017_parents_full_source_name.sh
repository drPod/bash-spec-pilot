#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
srcdir="$tmpdir/a/b"
src="$srcdir/file.txt"
out="$tmpdir/out"
mkdir -p "$srcdir" "$out"
printf 'parents\n' > "$src"
if ! "$UTIL" --parents "$src" "$out"; then echo "parents copy failed" >&2; exit 1; fi
expected="$out/${src#/}"
if [[ "$(cat "$expected")" == "parents" ]]; then exit 0; else echo "full source path was not created under destination" >&2; exit 1; fi
