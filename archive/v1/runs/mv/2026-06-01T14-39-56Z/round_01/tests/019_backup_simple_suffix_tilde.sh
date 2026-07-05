#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
dst="$tmpdir/dst"
printf 'new' > "$src"
printf 'old' > "$dst"
"$UTIL" --backup=simple "$src" "$dst"
if [[ -f "$dst~" ]]; then
  exit 0
else
  echo "simple backup with default tilde suffix was not created" >&2
  exit 1
fi
