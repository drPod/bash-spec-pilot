#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'time\n' > "$src"
touch -d '2001-02-03 04:05:06 UTC' "$src"
if ! "$UTIL" --no-preserve=timestamps "$src" "$dst"; then echo "cp --no-preserve=timestamps failed" >&2; exit 1; fi
if [[ "$(stat -c '%Y' "$dst")" != "$(stat -c '%Y' "$src")" ]]; then exit 0; fi
echo "timestamp was unexpectedly preserved" >&2
exit 1
