#!/usr/bin/env bash
# --help is the long form of -h; same documented help-to-stdout behavior.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" --help >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected --help to exit 0, got $status" >&2
  exit 1
fi
if ! [[ -s "$out" ]]; then
  echo "expected --help to write a help message to standard output" >&2
  exit 1
fi
