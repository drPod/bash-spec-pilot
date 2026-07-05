#!/usr/bin/env bash
# -l / --list with no command: list the privileges for the invoking user.
# EXIT VALUE: sudo exits 0 if the user is allowed to run sudo and
# authenticated successfully. As root, authentication is satisfied.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

set +e
"$UTIL" -n -l >"$tmpdir/out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -l to exit 0 for permitted user, got $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
