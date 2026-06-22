#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'fresh\n' > "$src"
printf 'stale\n' > "$dst"

# --backup makes a backup of each existing destination file; default suffix is '~'
"$UTIL" --backup "$src" "$dst"

if [[ ! -f "$dst~" ]]; then
  echo "FAIL: --backup did not create backup with default '~' suffix" >&2
  exit 1
fi
if [[ "$(cat "$dst~")" != "stale" ]]; then
  echo "FAIL: backup file does not contain previous destination contents" >&2
  exit 1
fi
