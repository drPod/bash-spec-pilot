#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
"$UTIL" --backup=numbered "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst.~1~")" == "old" ]]; then
  exit 0
else
  echo "--backup=numbered did not create numbered backup" >&2
  exit 1
fi
