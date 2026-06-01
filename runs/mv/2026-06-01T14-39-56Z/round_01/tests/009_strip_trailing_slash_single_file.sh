#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/file"
dst="$tmpdir/dst"
printf 'payload' > "$src"
"$UTIL" --strip-trailing-slashes "$src/" "$dst"
if [[ -f "$dst" ]] && [[ "$(<"$dst")" == "payload" ]]; then
  exit 0
else
  echo "--strip-trailing-slashes did not rename file source" >&2
  exit 1
fi
