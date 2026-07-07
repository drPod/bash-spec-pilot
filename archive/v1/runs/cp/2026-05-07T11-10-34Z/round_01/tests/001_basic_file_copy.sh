#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'hello world\n' > "$src"
if ! "$UTIL" "$src" "$dst"; then echo "cp failed" >&2; exit 1; fi
if cmp -s "$src" "$dst"; then exit 0; fi
echo "destination content mismatch" >&2
exit 1
