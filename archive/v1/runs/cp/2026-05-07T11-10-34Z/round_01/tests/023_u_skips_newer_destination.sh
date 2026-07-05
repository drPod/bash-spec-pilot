#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'old-source\n' > "$src"
printf 'new-dest\n' > "$dst"
touch -d '2020-01-01 00:00:00 UTC' "$src"
touch -d '2021-01-01 00:00:00 UTC' "$dst"
if ! "$UTIL" -u "$src" "$dst"; then echo "cp -u failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "new-dest" ]]; then exit 0; fi
echo "-u replaced a newer destination" >&2
exit 1
