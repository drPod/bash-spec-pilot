#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/dup_user.out"
err="$tmpdir/dup_user.err"
set +e
"$UTIL" -u root -u root /bin/true >"$out" 2>"$err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "duplicate -u options unexpectedly succeeded" >&2
  exit 1
fi
