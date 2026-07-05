#!/usr/bin/env bash
# ENVIRONMENT: LOGNAME is set to the login name of the target user when the -i
# option is specified. Target daemon -> LOGNAME=daemon.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n -i -u daemon sh -c 'printf %s "${LOGNAME:-MISSING}"' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -i -u daemon to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "daemon" ]]; then
  echo "expected LOGNAME='daemon' under -i, got '$(cat "$out")'" >&2
  exit 1
fi
