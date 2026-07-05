#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'payload' > "$src"
"$UTIL" "$src" "$dst"
if [[ -f "$dst" ]] && [[ "$(<"$dst")" == "payload" ]]; then
  exit 0
else
  echo "destination does not contain renamed file" >&2
  exit 1
fi
