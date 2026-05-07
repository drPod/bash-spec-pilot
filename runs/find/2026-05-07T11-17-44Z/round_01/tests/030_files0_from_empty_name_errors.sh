#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
list="$tmpdir/starts.list"
printf '\0' > "$list"
set +e
"$UTIL" -files0-from "$list" -maxdepth 0 >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "zero-length starting point from -files0-from did not fail" >&2
  exit 1
fi
