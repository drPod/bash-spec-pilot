#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --version: output version information and exit.
out=$("$UTIL" --version)
if [[ -n "$out" ]]; then
  exit 0
fi
echo "--version produced no version information output" >&2
exit 1
