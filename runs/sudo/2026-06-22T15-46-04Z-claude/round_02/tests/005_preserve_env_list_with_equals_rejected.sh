#!/usr/bin/env bash
# Documented error "invalid environment variable name": "One or more
# environment variable names specified via the -E option contained an equal
# sign ('='). The arguments to the -E option should be environment variable
# names without an associated value."  --preserve-env=list is the -E form that
# takes arguments; a list element with '=' must be rejected.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n --preserve-env=FOO=bar true
status=$?
set -e

if [[ $status -ne 0 ]]; then
    exit 0
fi
echo "FAIL: '--preserve-env=FOO=bar' exited 0; env var names via -E must not contain '='" >&2
exit 1
