#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/env.out"
err="$tmpdir/env.err"
if ! "$UTIL" -n SUDO_TEST_ASSIGNMENT=assigned /usr/bin/env >"$out" 2>"$err"; then
  echo "sudo VAR=value command failed" >&2
  exit 1
fi
if ! grep -qx 'SUDO_TEST_ASSIGNMENT=assigned' "$out"; then
  echo "environment assignment was not passed to command" >&2
  exit 1
fi
