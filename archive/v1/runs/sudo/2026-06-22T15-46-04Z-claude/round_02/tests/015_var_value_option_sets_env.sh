#!/usr/bin/env bash
# VAR=value as an option: "Environment variables to be set for the command may
# also be passed as options to sudo in the form VAR=value".  The sudoers policy
# subjects these to env restrictions "with one important difference. If the
# setenv option is set in sudoers, the command to be run has the SETENV tag set
# or the command matched is ALL, the user may set variables that would
# otherwise be forbidden."  The oracle's passwordless sudoers matches ALL, so a
# VAR=value must reach the command's environment.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

out="$("$UTIL" -n SUDO_TEST_VAR=marker printenv SUDO_TEST_VAR)"
if [[ "$out" == "marker" ]]; then
    exit 0
fi
echo "FAIL: 'SUDO_TEST_VAR=marker printenv SUDO_TEST_VAR' gave '$out'; VAR=value must set the env var" >&2
exit 1
