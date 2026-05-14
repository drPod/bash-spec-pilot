#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out=$("$UTIL" --help)
if [[ "$out" == *"Usage:"* ]]; then
  exit 0
else
  echo "--help output did not contain Usage" >&2
  exit 1
fi
