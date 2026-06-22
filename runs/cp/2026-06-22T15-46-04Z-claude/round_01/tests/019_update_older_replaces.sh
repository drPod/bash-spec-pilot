#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"

# Make destination older than source so the 'older' rule replaces it.
printf 'old\n' > "$dst"
touch -d '2000-01-01 00:00:00' "$dst"
printf 'new\n' > "$src"
touch -d '2020-01-01 00:00:00' "$src"

# -u: equivalent to --update=older; replace if dest is older than source.
"$UTIL" -u "$src" "$dst"

if [[ "$(cat "$dst")" != "new" ]]; then
  echo "FAIL: -u did not replace an older destination file" >&2
  exit 1
fi
