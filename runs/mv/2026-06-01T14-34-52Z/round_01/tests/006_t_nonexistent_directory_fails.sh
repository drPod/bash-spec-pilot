#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'data' > "$tmpdir/src"

set +e
"$UTIL" -t "$tmpdir/no_such_directory" "$tmpdir/src" >/dev/null 2>&1
status=$?
set -e

if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "expected nonexistent target directory to fail" >&2
  exit 1
fi
