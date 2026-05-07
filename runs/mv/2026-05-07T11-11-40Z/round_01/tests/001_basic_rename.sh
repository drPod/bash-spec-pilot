#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'alpha\n' > "$tmpdir/src"
"$UTIL" "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == "alpha" ]]; then
  exit 0
else
  echo "destination content was not moved source content" >&2
  exit 1
fi
