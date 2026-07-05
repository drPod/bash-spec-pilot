#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

"$UTIL" --backup=numbered "$tmpdir/src" "$tmpdir/dest"

actual="$(<"$tmpdir/dest.~1~")"
if [[ "$actual" != "old" ]]; then
  echo "numbered backup did not contain old dest" >&2
  exit 1
fi
