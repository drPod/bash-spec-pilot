#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"
"$UTIL" -n -i -f "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst") == "new" ]]; then
  exit 0
else
  echo "final -f did not take effect over earlier -n/-i" >&2
  exit 1
fi
