#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
if ! SIMPLE_BACKUP_SUFFIX=.save "$UTIL" -b "$src" "$dst"; then echo "cp -b failed" >&2; exit 1; fi
if [[ "$(cat "$dst.save")" == "old" ]]; then exit 0; fi
echo "-b backup with SIMPLE_BACKUP_SUFFIX missing old data" >&2
exit 1
