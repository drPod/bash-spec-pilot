#!/usr/bin/env bash
# -u user: run the command as the named user. id -un under -u daemon prints
# daemon (a user present in a base Debian container).
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n -u daemon id -un >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -u daemon to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(tr -d '[:space:]' <"$out")" != "daemon" ]]; then
  echo "expected target user 'daemon', got '$(cat "$out")'" >&2
  exit 1
fi
