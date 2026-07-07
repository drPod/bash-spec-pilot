#!/usr/bin/env bash
set -euo pipefail
# Documented ERROR: for tests like -newer that take a reference file, "If the
# reference file cannot be examined (for example, the stat(2) system call fails
# for it), an error message is issued, and find exits with a nonzero status."
# expected_to_fail: true.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/file"

set +e
"$UTIL" "$tmpdir" -newer "$tmpdir/does_not_exist" 2>/dev/null
status=$?
set -e

if [[ $status -eq 0 ]]; then
    echo "FAIL: -newer with non-examinable reference expected nonzero exit, got 0" >&2
    exit 1
fi
