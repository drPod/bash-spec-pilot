#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -n --preserve-env=BAD=NAME /bin/true >"$tmpdir/bad_env.out" 2>"$tmpdir/bad_env.err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "invalid preserve-env name unexpectedly succeeded" >&2
  exit 1
fi
