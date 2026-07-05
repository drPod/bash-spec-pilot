#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
target="$tmpdir/target.txt"
link="$tmpdir/link.txt"
dst="$tmpdir/dest.txt"
printf 'stripped\n' > "$target"
ln -s "$target" "$link"
if ! "$UTIL" --strip-trailing-slashes "$link/" "$dst"; then echo "cp --strip-trailing-slashes failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "stripped" ]]; then exit 0; fi
echo "trailing slash was not stripped from source" >&2
exit 1
