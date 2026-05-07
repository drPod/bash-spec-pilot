#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
touch -d '2001-01-01 00:00:00' "$tmpdir/src"
touch -d '2000-01-01 00:00:00' "$tmpdir/dst"
"$UTIL" --update=older "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == "new" ]]; then
  exit 0
else
  echo "--update=older did not replace older destination" >&2
  exit 1
fi
