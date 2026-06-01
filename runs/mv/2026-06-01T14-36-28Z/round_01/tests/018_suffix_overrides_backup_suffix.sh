#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

"$UTIL" --backup=simple --suffix=.bak "$tmpdir/src" "$tmpdir/dest"

actual="$(<"$tmpdir/dest.bak")"
if [[ "$actual" != "old" ]]; then
  echo "--suffix did not override backup suffix" >&2
  exit 1
fi
