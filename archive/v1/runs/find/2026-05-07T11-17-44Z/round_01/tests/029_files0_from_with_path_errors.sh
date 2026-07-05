#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
list="$tmpdir/starts.list"
printf '%s\0' "$tmpdir" > "$list"
set +e
"$UTIL" "$tmpdir" -files0-from "$list" -maxdepth 0 >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "-files0-from with command-line start point did not fail" >&2
  exit 1
fi
