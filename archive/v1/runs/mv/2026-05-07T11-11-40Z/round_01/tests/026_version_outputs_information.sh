#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out=$("$UTIL" --version)
if [[ "$out" == *"mv"* ]]; then
  exit 0
else
  echo "--version did not output version information" >&2
  exit 1
fi
