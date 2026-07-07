#!/usr/bin/env bash
# -h: display a short help message to standard output and exit (zero status).
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -h >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected -h to exit 0, got $status" >&2
  exit 1
fi
if ! [[ -s "$out" ]]; then
  echo "expected -h to write a help message to standard output" >&2
  exit 1
fi
