#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

"$UTIL" -n -f "$tmpdir/src" "$tmpdir/dest" </dev/null

actual="$(<"$tmpdir/dest")"
if [[ "$actual" != "new" ]]; then
  echo "-f after -n did not overwrite" >&2
  exit 1
fi
