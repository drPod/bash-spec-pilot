#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/help.out"
err="$tmpdir/help.err"
if ! "$UTIL" --help >"$out" 2>"$err"; then
  echo "sudo --help failed" >&2
  exit 1
fi
if ! grep -qi '^usage:' "$out"; then
  echo "long help output did not contain usage" >&2
  exit 1
fi
