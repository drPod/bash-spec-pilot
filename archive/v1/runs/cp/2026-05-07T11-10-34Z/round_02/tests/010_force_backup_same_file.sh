#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
file="$tmpdir/file.txt"
printf 'same-name data' > "$file"
if ! VERSION_CONTROL=simple "$UTIL" -f -b "$file" "$file"; then
  echo "cp -f -b same file failed" >&2
  exit 1
fi
if [[ $(cat "$file~") == 'same-name data' ]]; then
  exit 0
else
  echo "same-file force backup missing source data" >&2
  exit 1
fi
