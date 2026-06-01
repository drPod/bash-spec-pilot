#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

VERSION_CONTROL=numbered "$UTIL" --backup "$tmpdir/src" "$tmpdir/dest"

actual="$(<"$tmpdir/dest.~1~")"
if [[ "$actual" != "old" ]]; then
  echo "VERSION_CONTROL did not select numbered" >&2
  exit 1
fi
