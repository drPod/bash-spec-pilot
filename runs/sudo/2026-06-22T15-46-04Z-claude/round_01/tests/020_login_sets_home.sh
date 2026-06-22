#!/usr/bin/env bash
# -i / --login: HOME is set to the target user's home directory (ENVIRONMENT
# section: HOME set when the -i option is specified). Target root -> /root.
# -i passes the command to the login shell via -c, so $HOME expands there.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

want=$(getent passwd root | cut -d: -f6)
out="$tmpdir/out"
set +e
"$UTIL" -n -i -u root sh -c 'printf %s "$HOME"' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -i to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "$want" ]]; then
  echo "expected HOME='$want' under -i, got '$(cat "$out")'" >&2
  exit 1
fi
