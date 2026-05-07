#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" "$tmpdir/missing" "$tmpdir/dst" >/dev/null 2>&1
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "missing source unexpectedly succeeded" >&2
  exit 1
fi
