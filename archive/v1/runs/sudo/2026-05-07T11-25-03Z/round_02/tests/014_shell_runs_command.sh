#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/shell.out"
set +e
"$UTIL" -n -s /usr/bin/printf 'shell' >"$out" 2>"$tmpdir/shell.err"
set -e
if [[ "$(cat "$out")" != "shell" ]]; then
  echo "shell option did not run command through shell" >&2
  exit 1
fi
