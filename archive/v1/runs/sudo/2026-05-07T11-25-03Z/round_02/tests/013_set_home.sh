#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
root_home="$(/usr/bin/getent passwd root | /usr/bin/cut -d: -f6)"
out="$tmpdir/home.out"
set +e
"$UTIL" -n -H /usr/bin/env >"$out" 2>"$tmpdir/home.err"
set -e
if ! grep -qx "HOME=$root_home" "$out"; then
  echo "set-home did not set HOME to target user's home" >&2
  exit 1
fi
