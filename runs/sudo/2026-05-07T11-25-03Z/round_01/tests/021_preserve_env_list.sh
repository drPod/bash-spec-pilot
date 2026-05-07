#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/env.out"
err="$tmpdir/env.err"
if ! SUDO_TEST_PRESERVE_LIST=listed "$UTIL" -n --preserve-env=SUDO_TEST_PRESERVE_LIST /usr/bin/env >"$out" 2>"$err"; then
  echo "sudo --preserve-env=list failed" >&2
  exit 1
fi
if ! grep -qx 'SUDO_TEST_PRESERVE_LIST=listed' "$out"; then
  echo "listed environment variable was not preserved" >&2
  exit 1
fi
