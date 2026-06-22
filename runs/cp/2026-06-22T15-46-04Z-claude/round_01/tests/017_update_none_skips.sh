#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'incoming\n' > "$src"
printf 'kept\n' > "$dst"

# --update=none: no files in the destination are replaced; skipped files do not induce a failure.
"$UTIL" --update=none "$src" "$dst"

if [[ "$(cat "$dst")" != "kept" ]]; then
  echo "FAIL: --update=none replaced an existing destination file" >&2
  exit 1
fi
