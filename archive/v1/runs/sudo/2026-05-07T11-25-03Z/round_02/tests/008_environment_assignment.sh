#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/env.out"
set +e
"$UTIL" -n FOO_SUDO_TEST=bar /usr/bin/env >"$out" 2>"$tmpdir/env.err"
set -e
if ! grep -qx 'FOO_SUDO_TEST=bar' "$out"; then
  echo "environment assignment was not present in command environment" >&2
  exit 1
fi
