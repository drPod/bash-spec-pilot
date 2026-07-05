#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'incoming\n' > "$src"
printf 'old\n' > "$dst"
# Make the existing destination unopenable for writing.
chmod 0000 "$dst"

# -f, --force: if an existing destination file cannot be opened, remove it and try again.
"$UTIL" -f "$src" "$dst"

if [[ "$(cat "$dst")" != "incoming" ]]; then
  echo "FAIL: -f did not remove-and-replace an unopenable destination file" >&2
  exit 1
fi
