#!/usr/bin/env bash
# -g group: run the command with the primary group set to group. With -g
# daemon, id -gn reports daemon (group present in a base Debian container).
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n -g daemon id -gn >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -g daemon to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(tr -d '[:space:]' <"$out")" != "daemon" ]]; then
  echo "expected primary group 'daemon', got '$(cat "$out")'" >&2
  exit 1
fi
