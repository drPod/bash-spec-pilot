#!/usr/bin/env bash
# -u with a user that does not exist: a configuration/permission problem or a
# command that cannot be executed makes sudo exit 1. An unknown target user
# is not resolvable, so sudo must fail (nonzero).
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

bogus="nouser_$$_doesnotexist"
set +e
"$UTIL" -n -u "$bogus" true >"$tmpdir/out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "expected sudo -u <unknown user> to fail, but it exited 0" >&2
  exit 1
fi
