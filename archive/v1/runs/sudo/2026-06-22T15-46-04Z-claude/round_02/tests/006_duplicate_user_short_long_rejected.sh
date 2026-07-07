#!/usr/bin/env bash
# Documented error: "Options that take a value may only be specified once
# unless otherwise indicated in the description."  The short -u and long
# --user name the same value-taking option (-u user, --user=user); specifying
# both must be rejected as a repeated value option.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n -u root --user=root true
status=$?
set -e

if [[ $status -ne 0 ]]; then
    exit 0
fi
echo "FAIL: '-u root --user=root' exited 0; the user option may only be specified once" >&2
exit 1
