#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'data\n' > "$src"

# -v, --verbose: explain what is being done (prints something to stdout).
out=$("$UTIL" -v "$src" "$dst")

if [[ -z "$out" ]]; then
  echo "FAIL: -v produced no output explaining what was being done" >&2
  exit 1
fi
