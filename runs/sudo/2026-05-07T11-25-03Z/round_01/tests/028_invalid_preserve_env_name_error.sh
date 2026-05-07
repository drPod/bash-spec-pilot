#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/bad_env.out"
err="$tmpdir/bad_env.err"
set +e
"$UTIL" --preserve-env=BAD=NAME -n /bin/true >"$out" 2>"$err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "invalid preserve-env name unexpectedly succeeded" >&2
  exit 1
fi
