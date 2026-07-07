#!/usr/bin/env bash
# EXIT VALUE: on successful execution, sudo's exit status is the exit status
# of the executed program. Run a command that exits 7; expect sudo to exit 7.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n sh -c 'exit 7'
status=$?
set -e

if [[ $status -ne 7 ]]; then
  echo "expected sudo to propagate command exit status 7, got $status" >&2
  exit 1
fi
