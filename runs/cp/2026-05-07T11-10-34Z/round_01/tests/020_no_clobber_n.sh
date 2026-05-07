#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
if ! "$UTIL" -n "$src" "$dst"; then echo "cp -n failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "old" ]]; then exit 0; fi
echo "-n overwrote existing destination" >&2
exit 1
