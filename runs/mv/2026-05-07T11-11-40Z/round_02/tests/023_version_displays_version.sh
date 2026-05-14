#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out=$("$UTIL" --version)
if [[ "$out" == *"mv"* ]]; then
  exit 0
else
  echo "--version output did not mention mv" >&2
  exit 1
fi
