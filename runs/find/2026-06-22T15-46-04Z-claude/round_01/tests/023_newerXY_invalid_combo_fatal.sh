#!/usr/bin/env bash
set -euo pipefail
# Documented ERROR: for -newerXY, "it is invalid for X to be t" and "If an
# invalid or unsupported combination of XY is specified, a fatal error
# results." expected_to_fail: true.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/ref"

# -newertm uses X=t, which the page declares invalid -> fatal error.
set +e
"$UTIL" "$tmpdir" -newertm "$tmpdir/ref" 2>/dev/null
status=$?
set -e

if [[ $status -eq 0 ]]; then
    echo "FAIL: -newerXY with invalid X=t expected fatal nonzero exit, got 0" >&2
    exit 1
fi
