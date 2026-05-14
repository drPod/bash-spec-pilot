#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" -n -u root -u root /bin/true >"$tmpdir/dup_user.out" 2>"$tmpdir/dup_user.err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "duplicate user option unexpectedly succeeded" >&2
  exit 1
fi
