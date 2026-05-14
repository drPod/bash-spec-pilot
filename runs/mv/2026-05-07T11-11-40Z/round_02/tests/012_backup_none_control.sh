#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"
"$UTIL" --backup=none "$tmpdir/src" "$tmpdir/dst"
if [[ ! -e "$tmpdir/dst~" ]]; then
  exit 0
else
  echo "--backup=none created a backup" >&2
  exit 1
fi
