#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'incoming\n' > "$src"
printf 'previous\n' > "$dst"

# -S, --suffix=SUFFIX: override the usual backup suffix
"$UTIL" -b -S .bak "$src" "$dst"

if [[ ! -f "$dst.bak" ]]; then
  echo "FAIL: -S did not override the backup suffix to '.bak'" >&2
  exit 1
fi
