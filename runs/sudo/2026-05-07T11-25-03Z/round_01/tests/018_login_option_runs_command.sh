#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/login.out"
err="$tmpdir/login.err"
if ! "$UTIL" -n -i /usr/bin/printf 'login-ok\n' >"$out" 2>"$err"; then
  echo "sudo -i command failed" >&2
  exit 1
fi
if ! grep -qx 'login-ok' "$out"; then
  echo "login shell command output missing" >&2
  exit 1
fi
