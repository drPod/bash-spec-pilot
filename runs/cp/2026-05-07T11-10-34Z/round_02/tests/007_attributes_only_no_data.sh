#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'payload data' > "$src"
if ! "$UTIL" --attributes-only "$src" "$dst"; then
  echo "cp --attributes-only failed" >&2
  exit 1
fi
if [[ -e "$dst" && ! -s "$dst" ]]; then
  exit 0
else
  echo "attributes-only destination contains data or is missing" >&2
  exit 1
fi
