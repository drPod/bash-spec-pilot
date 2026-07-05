#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/version.out"
err="$tmpdir/version.err"
if ! "$UTIL" -V >"$out" 2>"$err"; then
  echo "sudo -V failed" >&2
  exit 1
fi
if ! grep -q 'Sudo version' "$out"; then
  echo "version output missing Sudo version" >&2
  exit 1
fi
