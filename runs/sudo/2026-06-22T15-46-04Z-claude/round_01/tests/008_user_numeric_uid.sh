#!/usr/bin/env bash
# -u user: user may be a numeric UID prefixed with '#'. #0 is root (UID 0).
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n -u '#0' id -u >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -u #0 to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(tr -d '[:space:]' <"$out")" != "0" ]]; then
  echo "expected numeric UID 0 for '#0', got '$(cat "$out")'" >&2
  exit 1
fi
