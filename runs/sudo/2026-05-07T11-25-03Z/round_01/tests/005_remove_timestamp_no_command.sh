#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/remove.out"
err="$tmpdir/remove.err"
set +e
"$UTIL" -K >"$out" 2>"$err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "sudo -K exited nonzero" >&2
  exit 1
fi
