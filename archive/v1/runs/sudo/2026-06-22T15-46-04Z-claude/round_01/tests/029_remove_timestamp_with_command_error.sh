#!/usr/bin/env bash
# -K / --remove-timestamp: "It is not possible to use the -K option in
# conjunction with a command or other option." Combining -K with a command is
# a documented error; sudo must exit nonzero.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -K true >"$tmpdir/out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "expected -K with a command to fail, but sudo exited 0" >&2
  exit 1
fi
