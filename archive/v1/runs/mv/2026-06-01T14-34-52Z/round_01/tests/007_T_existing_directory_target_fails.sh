#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'data' > "$tmpdir/src"
mkdir "$tmpdir/destdir"

set +e
"$UTIL" -T "$tmpdir/src" "$tmpdir/destdir" >/dev/null 2>&1
status=$?
set -e

if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "expected -T with directory target to fail" >&2
  exit 1
fi
