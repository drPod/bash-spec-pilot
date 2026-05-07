#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/remove_cmd.out"
err="$tmpdir/remove_cmd.err"
set +e
"$UTIL" -K /bin/true >"$out" 2>"$err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "sudo -K with a command unexpectedly succeeded" >&2
  exit 1
fi
