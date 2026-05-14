#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -n -l >"$tmpdir/list.out" 2>"$tmpdir/list.err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "list privileges did not succeed" >&2
  exit 1
fi
