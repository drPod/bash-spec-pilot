#!/usr/bin/env bash
# --: delimits the end of sudo options; subsequent options are passed to the
# command. After --, a leading-dash token is handed to the command, not sudo.
# Here `printf -- -V` makes printf emit "-V"; if sudo ate -V it would print
# its version instead of running printf.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n -- printf '%s\n' '-V' >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -- printf to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "-V" ]]; then
  echo "expected command to receive '-V' after --, got '$(cat "$out")'" >&2
  exit 1
fi
