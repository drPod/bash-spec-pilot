#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" --suffix >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "--suffix without argument succeeded" >&2
  exit 1
fi
