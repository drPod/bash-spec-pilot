#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# SYNOPSIS requires SOURCE to exist to be renamed/moved. A nonexistent SOURCE
# cannot be moved, so mv must fail.
set +e
"$UTIL" "$tmpdir/does_not_exist" "$tmpdir/dst"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
fi
echo "mv on a nonexistent source did not fail" >&2
exit 1
