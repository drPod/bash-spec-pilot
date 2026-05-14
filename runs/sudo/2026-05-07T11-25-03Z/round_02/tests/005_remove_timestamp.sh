#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -K >"$tmpdir/remove.out" 2>"$tmpdir/remove.err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "remove timestamp did not succeed" >&2
  exit 1
fi
