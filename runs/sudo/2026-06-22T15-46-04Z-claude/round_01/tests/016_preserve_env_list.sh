#!/usr/bin/env bash
# --preserve-env=list: add the comma-separated list of variables to those
# preserved from the user's environment. Name PRESERVE_ONE in the list.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

export PRESERVE_ONE="listed_$$"
out="$tmpdir/out"
set +e
"$UTIL" -n --preserve-env=PRESERVE_ONE sh -c 'printf %s "${PRESERVE_ONE:-MISSING}"' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo --preserve-env=list to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "$PRESERVE_ONE" ]]; then
  echo "expected PRESERVE_ONE preserved via --preserve-env=list, got '$(cat "$out")'" >&2
  exit 1
fi
