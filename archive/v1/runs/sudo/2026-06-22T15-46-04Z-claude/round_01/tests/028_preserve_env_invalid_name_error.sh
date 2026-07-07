#!/usr/bin/env bash
# DIAGNOSTICS: "invalid environment variable name" -- one or more env variable
# names specified via the -E option contained an equal sign. --preserve-env
# arguments must be names without a value; a NAME=value entry is an error.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n --preserve-env=BAD=value true >"$tmpdir/out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "expected --preserve-env with NAME=value to fail, but sudo exited 0" >&2
  exit 1
fi
