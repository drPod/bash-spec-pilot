#!/usr/bin/env bash
# sudo runs the given command; its standard output reaches the caller.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n printf 'hello_sudo\n' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected command to run, sudo exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "hello_sudo" ]]; then
  echo "expected command stdout 'hello_sudo', got '$(cat "$out")'" >&2
  exit 1
fi
