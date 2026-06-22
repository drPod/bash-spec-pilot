#!/usr/bin/env bash
# EXIT VALUE: a successful command (exit 0) yields sudo exit 0.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n true
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo to propagate command exit status 0, got $status" >&2
  exit 1
fi
