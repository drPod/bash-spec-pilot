#!/usr/bin/env bash
# "Options that take a value may only be specified once unless otherwise
# indicated in the description." -u takes a value and is not flagged as
# repeatable, so specifying it twice is a documented error.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n -u root -u daemon true >"$tmpdir/out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "expected duplicate -u to fail, but sudo exited 0" >&2
  exit 1
fi
