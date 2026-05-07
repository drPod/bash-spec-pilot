#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
if ! printf 'n\n' | "$UTIL" -i "$src" "$dst" >/dev/null 2>&1; then echo "cp -i failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "old" ]]; then exit 0; fi
echo "-i overwrote destination after negative response" >&2
exit 1
