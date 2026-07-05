#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
missing="$tmpdir/does_not_exist.txt"
dst="$tmpdir/dst.txt"
set +e
"$UTIL" "$missing" "$dst" >/dev/null 2>&1
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "copying nonexistent source unexpectedly succeeded" >&2
  exit 1
fi
