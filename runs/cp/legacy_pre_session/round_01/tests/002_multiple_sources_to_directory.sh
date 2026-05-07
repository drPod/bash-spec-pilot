#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src1="$tmpdir/one.txt"
src2="$tmpdir/two.txt"
out="$tmpdir/out"
printf 'one\n' > "$src1"
printf 'two\n' > "$src2"
mkdir -p "$out"
if ! "$UTIL" "$src1" "$src2" "$out"; then echo "multi-source copy failed" >&2; exit 1; fi
if [[ "$(cat "$out/two.txt")" == "two" ]]; then exit 0; else echo "second source was not copied into directory" >&2; exit 1; fi
