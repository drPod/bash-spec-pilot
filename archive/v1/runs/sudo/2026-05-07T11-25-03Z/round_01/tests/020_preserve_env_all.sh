#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/env.out"
err="$tmpdir/env.err"
if ! SUDO_TEST_PRESERVE_ALL=kept "$UTIL" -n -E /usr/bin/env >"$out" 2>"$err"; then
  echo "sudo -E env failed" >&2
  exit 1
fi
if ! grep -qx 'SUDO_TEST_PRESERVE_ALL=kept' "$out"; then
  echo "environment variable was not preserved by -E" >&2
  exit 1
fi
