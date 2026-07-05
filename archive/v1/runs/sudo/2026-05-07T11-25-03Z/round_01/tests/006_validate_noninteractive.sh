#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/validate.out"
err="$tmpdir/validate.err"
set +e
"$UTIL" -n -v >"$out" 2>"$err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "sudo -n -v exited nonzero" >&2
  exit 1
fi
