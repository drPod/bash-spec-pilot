#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" "$tmpdir/no_such_start" -print >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "missing starting point did not cause nonzero exit" >&2
  exit 1
fi
