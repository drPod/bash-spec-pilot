#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'older source\n' > "$src"
printf 'newer dest\n' > "$dst"
touch -t 200001010000.00 "$src"
touch -t 200101010000.00 "$dst"
if ! "$UTIL" -u "$src" "$dst"; then echo "-u invocation failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "newer dest" ]]; then exit 0; else echo "newer destination was replaced" >&2; exit 1; fi
