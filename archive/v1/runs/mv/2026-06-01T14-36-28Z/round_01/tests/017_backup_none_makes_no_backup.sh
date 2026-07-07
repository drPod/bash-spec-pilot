#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

"$UTIL" --backup=none "$tmpdir/src" "$tmpdir/dest"

if [[ -e "$tmpdir/dest~" ]]; then
  echo "--backup=none created a backup" >&2
  exit 1
fi
