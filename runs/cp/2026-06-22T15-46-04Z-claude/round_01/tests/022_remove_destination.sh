#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'replacement\n' > "$src"
printf 'old\n' > "$dst"

# --remove-destination: remove each existing destination file before attempting to open it.
"$UTIL" --remove-destination "$src" "$dst"

if [[ "$(cat "$dst")" != "replacement" ]]; then
  echo "FAIL: --remove-destination did not replace existing destination contents" >&2
  exit 1
fi
