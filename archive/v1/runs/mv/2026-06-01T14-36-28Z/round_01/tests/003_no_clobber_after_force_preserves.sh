#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

"$UTIL" -f -n "$tmpdir/src" "$tmpdir/dest"

actual="$(<"$tmpdir/dest")"
if [[ "$actual" != "old" ]]; then
  echo "-n after -f clobbered destination" >&2
  exit 1
fi
