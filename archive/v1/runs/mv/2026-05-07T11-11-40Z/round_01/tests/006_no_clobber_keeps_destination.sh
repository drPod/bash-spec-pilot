#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
"$UTIL" -n "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == "old" ]]; then
  exit 0
else
  echo "-n overwrote an existing destination" >&2
  exit 1
fi
