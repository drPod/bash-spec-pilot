#!/usr/bin/env bash
set -euo pipefail
# Documented ERROR: "The -delete action will fail to remove a directory unless
# it is empty." and "If the removal failed, an error message is issued and
# find's exit status will be nonzero". expected_to_fail: true.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir "$tmpdir/full"
: > "$tmpdir/full/child"

# Target only the non-empty directory by name; deleting it must fail.
set +e
"$UTIL" "$tmpdir" -depth -type d -name 'full' -delete 2>/dev/null
status=$?
set -e

if [[ $status -eq 0 ]]; then
    echo "FAIL: -delete on non-empty dir expected nonzero exit, got 0" >&2
    exit 1
fi
