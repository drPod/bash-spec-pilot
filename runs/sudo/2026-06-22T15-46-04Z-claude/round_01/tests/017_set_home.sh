#!/usr/bin/env bash
# -H / --set-home: set HOME to the target user's home directory. Target root,
# whose home is /root per the passwd database in a base container.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

want=$(getent passwd root | cut -d: -f6)
out="$tmpdir/out"
set +e
"$UTIL" -n -H -u root sh -c 'printf %s "$HOME"' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -H to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "$want" ]]; then
  echo "expected HOME='$want' under -H, got '$(cat "$out")'" >&2
  exit 1
fi
