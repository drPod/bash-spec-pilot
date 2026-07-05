#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" >/dev/null 2>&1
status=$?
set -e

if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "expected no operands to fail" >&2
  exit 1
fi
