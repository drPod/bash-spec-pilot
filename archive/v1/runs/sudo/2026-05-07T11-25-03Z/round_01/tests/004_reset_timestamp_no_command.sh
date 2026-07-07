#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/reset.out"
err="$tmpdir/reset.err"
set +e
"$UTIL" -k >"$out" 2>"$err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "sudo -k exited nonzero" >&2
  exit 1
fi
