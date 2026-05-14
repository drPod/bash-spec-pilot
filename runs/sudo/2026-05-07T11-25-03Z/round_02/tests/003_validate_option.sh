#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -n -v >"$tmpdir/validate.out" 2>"$tmpdir/validate.err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "validate option did not succeed" >&2
  exit 1
fi
