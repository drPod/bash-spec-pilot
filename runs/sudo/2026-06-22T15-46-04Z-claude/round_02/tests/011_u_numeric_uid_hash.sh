#!/usr/bin/env bash
# -u user: "The user may be either a user name or a numeric user-ID (UID)
# prefixed with the '#' character (e.g., '#0' for UID 0)."  Running a command
# as '-u #0' must execute it with effective UID 0, observable via `id -u`.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

out="$("$UTIL" -n -u '#0' id -u)"
if [[ "$out" == "0" ]]; then
    exit 0
fi
echo "FAIL: '-u #0 id -u' reported '$out'; #0 must select UID 0" >&2
exit 1
