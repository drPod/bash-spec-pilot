#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -K /bin/true >"$tmpdir/remove_cmd.out" 2>"$tmpdir/remove_cmd.err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "remove-timestamp with command unexpectedly succeeded" >&2
  exit 1
fi
