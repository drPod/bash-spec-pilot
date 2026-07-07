#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
if ! "$UTIL" --backup=simple --suffix=.bak "$src" "$dst"; then echo "cp --backup --suffix failed" >&2; exit 1; fi
if [[ "$(cat "$dst.bak")" == "old" ]]; then exit 0; fi
echo "backup with custom suffix does not contain old destination" >&2
exit 1
