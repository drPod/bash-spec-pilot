#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"
"$UTIL" -f -i -n "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst") == "old" ]]; then
  exit 0
else
  echo "final -n did not take effect over earlier -f/-i" >&2
  exit 1
fi
