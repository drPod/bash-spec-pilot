#!/usr/bin/env bash
# --: "The -- is used to delimit the end of the sudo options. Subsequent
# options are passed to the command."  A token after -- that looks like a sudo
# option (-l) must be delivered to the command, not consumed by sudo.
# /bin/echo prints its arguments verbatim, so -l must appear in its output.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

out="$("$UTIL" -n -- /bin/echo -l marker)"
if [[ "$out" == "-l marker" ]]; then
    exit 0
fi
echo "FAIL: '-- /bin/echo -l marker' gave '$out'; -l after -- must be passed to the command" >&2
exit 1
