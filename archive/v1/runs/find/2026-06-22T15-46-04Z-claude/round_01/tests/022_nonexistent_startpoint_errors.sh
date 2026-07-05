#!/usr/bin/env bash
set -euo pipefail
# Documented ERROR: "find exits with status 0 if all files are processed
# successfully, greater than 0 if errors occur." A nonexistent starting point
# cannot be processed, so exit status must be nonzero. expected_to_fail: true.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" "$tmpdir/no_such_path" 2>/dev/null
status=$?
set -e

if [[ $status -eq 0 ]]; then
    echo "FAIL: nonexistent starting point expected nonzero exit, got 0" >&2
    exit 1
fi
