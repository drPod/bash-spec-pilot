#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
"$UTIL" -n -f "$tmpdir/src" "$tmpdir/dst" </dev/null
if [[ "$(cat "$tmpdir/dst")" == "new" ]]; then
  exit 0
else
  echo "final -f did not override earlier -n" >&2
  exit 1
fi
