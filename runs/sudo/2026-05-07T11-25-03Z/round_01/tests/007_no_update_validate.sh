#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/no_update.out"
err="$tmpdir/no_update.err"
set +e
"$UTIL" -Nnv >"$out" 2>"$err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "sudo -Nnv exited nonzero" >&2
  exit 1
fi
