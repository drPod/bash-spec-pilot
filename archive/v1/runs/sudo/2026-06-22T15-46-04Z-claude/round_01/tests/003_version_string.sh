#!/usr/bin/env bash
# -V: print the sudo version string. Output is documented to include version.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -V >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected -V to exit 0, got $status" >&2
  exit 1
fi
if ! grep -qi 'version' "$out"; then
  echo "expected -V output to contain a version string" >&2
  exit 1
fi
