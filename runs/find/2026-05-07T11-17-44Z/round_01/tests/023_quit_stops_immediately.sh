#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/first" "$tmpdir/second"
if ! actual=$("$UTIL" "$tmpdir/first" "$tmpdir/second" -maxdepth 0 -printf '%p\n' -quit); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "$tmpdir/first" ]]; then
  echo "-quit did not stop after the first starting point" >&2
  exit 1
fi
