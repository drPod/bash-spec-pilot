#!/usr/bin/env bash
# EXIT VALUE: "Upon successful execution of a command, the exit status from
# sudo will be the exit status of the program that was executed."  Running a
# command that exits 7 must make sudo exit 7.  (Oracle runs as root with
# passwordless sudoers, so authorization is not the gate here.)
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n /bin/sh -c 'exit 7'
status=$?
set -e

if [[ $status -eq 7 ]]; then
    exit 0
fi
echo "FAIL: command exited 7 but sudo exit status was $status; status must pass through" >&2
exit 1
