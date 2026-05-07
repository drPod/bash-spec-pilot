#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/link_to_source"
printf 'data\n' > "$src"
if ! "$UTIL" -s "$src" "$dst"; then echo "cp -s failed" >&2; exit 1; fi
if [[ "$(readlink "$dst")" == "$src" ]]; then exit 0; fi
echo "symbolic link target mismatch" >&2
exit 1
