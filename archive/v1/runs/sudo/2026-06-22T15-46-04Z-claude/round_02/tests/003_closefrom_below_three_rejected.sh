#!/usr/bin/env bash
# Documented error: for -C num, "Values less than three are not permitted."
# This is a value-level constraint independent of policy. -C 2 must be rejected.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n -C 2 true
status=$?
set -e

if [[ $status -ne 0 ]]; then
    exit 0
fi
echo "FAIL: '-C 2 true' exited 0; man page says values less than three are not permitted" >&2
exit 1
