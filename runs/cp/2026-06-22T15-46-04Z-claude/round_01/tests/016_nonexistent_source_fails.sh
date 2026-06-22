#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

missing="$tmpdir/does_not_exist.txt"
dst="$tmpdir/dst.txt"

# Copying a nonexistent SOURCE must fail (documented error case).
set +e
"$UTIL" "$missing" "$dst"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "FAIL: copying a nonexistent SOURCE should fail but exited 0" >&2
  exit 1
fi
