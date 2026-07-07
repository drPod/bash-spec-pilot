#!/usr/bin/env bash
# --preserve-env=list: "This option may be specified multiple times."  This is
# the explicit exception to "Options that take a value may only be specified
# once".  Two --preserve-env=NAME options must therefore not be rejected as a
# duplicate-option error.  (Oracle runs as root; the policy permits preserving
# the environment, so the documented hedge does not gate acceptance here.)
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n --preserve-env=FOO --preserve-env=BAR true
status=$?
set -e

if [[ $status -eq 0 ]]; then
    exit 0
fi
echo "FAIL: two '--preserve-env=' options exited $status; the option may be specified multiple times" >&2
exit 1
