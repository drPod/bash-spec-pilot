#!/usr/bin/env bash
# -i / --login: run the target user's login shell. If a command is specified,
# it is passed to the shell as a simple command using -c. The command runs.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n -i printf login_ran >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -i command to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "login_ran" ]]; then
  echo "expected -i command output 'login_ran', got '$(cat "$out")'" >&2
  exit 1
fi
