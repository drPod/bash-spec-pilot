#!/usr/bin/env bash
set -euo pipefail
# -i : "prompt before overwrite (overrides a previous -n option)"
# With "-n -i", -i wins; answering the overwrite prompt yes overwrites DEST.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'NEW' > "$src"
printf 'OLD' > "$dst"

set +e
printf 'y\n' | "$UTIL" -n -i "$src" "$dst"
set -e

if [[ "$(cat "$dst")" != "NEW" ]]; then
  echo "FAIL: -i did not override previous -n (DEST not overwritten on yes)" >&2
  exit 1
fi
