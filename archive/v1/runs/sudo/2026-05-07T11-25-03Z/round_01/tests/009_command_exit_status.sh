#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/cmd.out"
err="$tmpdir/cmd.err"
set +e
"$UTIL" -n /bin/sh -c 'exit 7' >"$out" 2>"$err"
status=$?
set -e
if [[ $status -ne 7 ]]; then
  echo "sudo did not propagate command exit status" >&2
  exit 1
fi
