#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -n -U root -l >"$tmpdir/other_list.out" 2>"$tmpdir/other_list.err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "other-user privilege listing did not succeed" >&2
  exit 1
fi
