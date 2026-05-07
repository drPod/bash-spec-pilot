#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
out="$tmpdir/target"
printf 'via -t\n' > "$src"
mkdir "$out"
if ! "$UTIL" -t "$out" "$src"; then echo "cp -t failed" >&2; exit 1; fi
if cmp -s "$src" "$out/source.txt"; then exit 0; fi
echo "-t destination content mismatch" >&2
exit 1
