#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -n -C 2 /bin/true >"$tmpdir/closefrom.out" 2>"$tmpdir/closefrom.err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "close-from value less than three unexpectedly succeeded" >&2
  exit 1
fi
