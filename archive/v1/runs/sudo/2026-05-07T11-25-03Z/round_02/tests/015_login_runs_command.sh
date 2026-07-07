#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/login.out"
set +e
"$UTIL" -n -i /usr/bin/printf 'login' >"$out" 2>"$tmpdir/login.err"
set -e
if [[ "$(cat "$out")" != "login" ]]; then
  echo "login option did not run specified command" >&2
  exit 1
fi
