#!/usr/bin/env bash
# -E / --preserve-env: preserve the user's existing environment variables.
# An arbitrary parent var should survive into the command env under -E.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

export PRESERVE_PROBE="keep_me_$$"
out="$tmpdir/out"
set +e
"$UTIL" -n -E sh -c 'printf %s "${PRESERVE_PROBE:-MISSING}"' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -E to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "$PRESERVE_PROBE" ]]; then
  echo "expected PRESERVE_PROBE preserved under -E, got '$(cat "$out")'" >&2
  exit 1
fi
