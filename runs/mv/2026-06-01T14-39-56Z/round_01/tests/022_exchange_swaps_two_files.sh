#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
left="$tmpdir/left"
right="$tmpdir/right"
printf 'left-data' > "$left"
printf 'right-data' > "$right"
"$UTIL" --exchange "$left" "$right"
if [[ "$(<"$left")" == "right-data" ]]; then
  exit 0
else
  echo "--exchange did not swap file contents" >&2
  exit 1
fi
