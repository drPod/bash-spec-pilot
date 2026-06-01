#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'payload\n' > "$tmpdir/src"

"$UTIL" --strip-trailing-slashes "$tmpdir/src/" "$tmpdir/dest"

actual="$(<"$tmpdir/dest")"
if [[ "$actual" != "payload" ]]; then
  echo "trailing slash was not stripped from source" >&2
  exit 1
fi
