#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -k >"$tmpdir/reset.out" 2>"$tmpdir/reset.err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "reset timestamp did not succeed" >&2
  exit 1
fi
