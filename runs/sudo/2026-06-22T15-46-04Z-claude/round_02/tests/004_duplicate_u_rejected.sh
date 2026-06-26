#!/usr/bin/env bash
# Documented error: "Options that take a value may only be specified once
# unless otherwise indicated in the description."  -u takes a value and its
# description does not indicate repetition, so two -u options must be rejected.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n -u root -u root true
status=$?
set -e

if [[ $status -ne 0 ]]; then
    exit 0
fi
echo "FAIL: two '-u' options exited 0; value-taking options may only be specified once" >&2
exit 1
