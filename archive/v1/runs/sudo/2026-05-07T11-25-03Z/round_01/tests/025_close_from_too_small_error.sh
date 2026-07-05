#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/closefrom.out"
err="$tmpdir/closefrom.err"
set +e
"$UTIL" -C 2 /bin/true >"$out" 2>"$err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "sudo -C 2 unexpectedly succeeded" >&2
  exit 1
fi
