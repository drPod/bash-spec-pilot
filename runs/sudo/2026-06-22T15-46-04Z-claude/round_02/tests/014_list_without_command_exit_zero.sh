#!/usr/bin/env bash
# -l with no command + EXIT VALUE: "If the -l option was specified without a
# command, sudo will exit with a value of 0 if the user is allowed to run sudo
# and they authenticated successfully (as required by the security policy)."
# The oracle runs as root with passwordless sudoers: allowed and authenticated,
# so '-l' alone must exit 0.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n -l >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
    exit 0
fi
echo "FAIL: '-l' (no command) exited $status; an allowed+authenticated user must get exit 0" >&2
exit 1
