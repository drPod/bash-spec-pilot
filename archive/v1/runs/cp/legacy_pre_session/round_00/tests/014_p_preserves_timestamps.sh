#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'timestamped\n' > "$src"
touch -t 200001020304.05 "$src"
if ! "$UTIL" -p "$src" "$dst"; then echo "preserving copy failed" >&2; exit 1; fi
if [[ "$(stat -c %Y "$dst")" == "$(stat -c %Y "$src")" ]]; then exit 0; else echo "timestamp was not preserved" >&2; exit 1; fi
