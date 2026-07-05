#!/usr/bin/env bash
# ENVIRONMENT: SUDO_COMMAND is set to the command run by sudo, including any
# args. Run a marker command and confirm SUDO_COMMAND names it.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n sh -c 'printf %s "${SUDO_COMMAND:-MISSING}"' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if ! grep -q '/sh' "$out"; then
  echo "expected SUDO_COMMAND to include the run command path, got '$(cat "$out")'" >&2
  exit 1
fi
