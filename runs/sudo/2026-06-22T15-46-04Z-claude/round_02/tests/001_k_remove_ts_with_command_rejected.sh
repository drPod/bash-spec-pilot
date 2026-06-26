#!/usr/bin/env bash
# Documented error: "It is not possible to use the -K option in conjunction
# with a command or other option."  -K followed by a command must be rejected.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n -K true
status=$?
set -e

if [[ $status -ne 0 ]]; then
    exit 0
fi
echo "FAIL: '-K true' exited 0; man page says -K cannot be used with a command" >&2
exit 1
