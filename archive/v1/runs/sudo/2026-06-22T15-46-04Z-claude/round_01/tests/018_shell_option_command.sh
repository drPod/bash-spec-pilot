#!/usr/bin/env bash
# -s / --shell: if a command is specified, it is passed to the shell as a
# simple command using -c. Use SHELL=/bin/sh; the command runs and produces
# its output.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
SHELL=/bin/sh "$UTIL" -n -s 'printf shell_ran' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -s to run command via shell, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "shell_ran" ]]; then
  echo "expected -s command output 'shell_ran', got '$(cat "$out")'" >&2
  exit 1
fi
