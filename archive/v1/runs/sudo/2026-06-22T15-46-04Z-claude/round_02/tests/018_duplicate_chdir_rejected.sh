#!/usr/bin/env bash
# Documented error: "Options that take a value may only be specified once
# unless otherwise indicated in the description."  -D directory takes a value
# and its description does not indicate repetition, so two -D options must be
# rejected.  This duplicate-option rejection is independent of the chdir policy
# hedge, which only governs whether a single valid -D is honored.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n -D /tmp -D /tmp true
status=$?
set -e

if [[ $status -ne 0 ]]; then
    exit 0
fi
echo "FAIL: two '-D' options exited 0; value-taking options may only be specified once" >&2
exit 1
