#!/usr/bin/env bash
set -euo pipefail
# -n, --no-clobber : "(deprecated) silently skip existing files"
# Existing DEST must be left unchanged; skip is silent (no failure).
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'NEW' > "$src"
printf 'OLD' > "$dst"

"$UTIL" -n "$src" "$dst"

if [[ "$(cat "$dst")" != "OLD" ]]; then
  echo "FAIL: -n did not silently skip; existing DEST was overwritten" >&2
  exit 1
fi
