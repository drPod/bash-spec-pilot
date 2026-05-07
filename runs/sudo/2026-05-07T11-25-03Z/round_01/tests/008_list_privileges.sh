#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/list.out"
err="$tmpdir/list.err"
set +e
"$UTIL" -n -l >"$out" 2>"$err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "sudo -n -l exited nonzero" >&2
  exit 1
fi
