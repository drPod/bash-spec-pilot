#!/usr/bin/env bash
# VAR=value: environment variables to be set for the command may be passed as
# options to sudo in the form VAR=value. Set MYVAR and read it back.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n MYVAR=set_via_sudo sh -c 'printf %s "$MYVAR"' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo VAR=value to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "set_via_sudo" ]]; then
  echo "expected MYVAR=set_via_sudo in command env, got '$(cat "$out")'" >&2
  exit 1
fi
