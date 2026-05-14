#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
missing="$tmpdir/no_such_command"
set +e
"$UTIL" -n "$missing" >"$tmpdir/missing.out" 2>"$tmpdir/missing.err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "nonexistent command unexpectedly succeeded" >&2
  exit 1
fi
