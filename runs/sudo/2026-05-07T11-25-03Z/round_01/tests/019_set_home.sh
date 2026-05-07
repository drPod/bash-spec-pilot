#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
home=$(getent passwd root | awk -F: '{print $6}')
out="$tmpdir/env.out"
err="$tmpdir/env.err"
if ! "$UTIL" -n -H /usr/bin/env >"$out" 2>"$err"; then
  echo "sudo -H env failed" >&2
  exit 1
fi
if ! grep -qx "HOME=$home" "$out"; then
  echo "HOME was not set to target user's home" >&2
  exit 1
fi
