#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/version.out"
set +e
"$UTIL" -V >"$out" 2>"$tmpdir/version.err"
set -e
if ! grep -q 'Sudo version' "$out"; then
  echo "version output did not contain Sudo version" >&2
  exit 1
fi
