#!/usr/bin/env bash
# ENVIRONMENT: SUDO_USER is set to the login name of the user who invoked
# sudo. Invoked as root in the harness, so SUDO_USER=root.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n -u daemon sh -c 'printf %s "${SUDO_USER:-MISSING}"' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "root" ]]; then
  echo "expected SUDO_USER='root' (invoking user), got '$(cat "$out")'" >&2
  exit 1
fi
