#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -n /bin/sh -c 'exit 7' >"$tmpdir/status.out" 2>"$tmpdir/status.err"
status=$?
set -e
if [[ $status -ne 7 ]]; then
  echo "sudo did not propagate command exit status" >&2
  exit 1
fi
