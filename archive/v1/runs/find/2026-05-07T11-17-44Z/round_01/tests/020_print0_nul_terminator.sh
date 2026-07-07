#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/a b"
out="$tmpdir/out.bin"
if ! "$UTIL" "$tmpdir/a b" -maxdepth 0 -print0 > "$out"; then
  echo "find invocation failed" >&2
  exit 1
fi
actual=$(od -An -tx1 -v "$out" | tr -d ' \n')
expected=$(printf '%s\0' "$tmpdir/a b" | od -An -tx1 -v | tr -d ' \n')
if [[ "$actual" != "$expected" ]]; then
  echo "-print0 did not emit the path followed by NUL" >&2
  exit 1
fi
