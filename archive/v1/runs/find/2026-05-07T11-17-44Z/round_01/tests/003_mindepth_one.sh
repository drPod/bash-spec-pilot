#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/sub"
: > "$tmpdir/file"
if ! actual=$("$UTIL" "$tmpdir" -mindepth 1 -maxdepth 1 -printf '%f\n' | LC_ALL=C sort); then
  echo "find invocation failed" >&2
  exit 1
fi
expected=$(printf '%s\n' file sub | LC_ALL=C sort)
if [[ "$actual" != "$expected" ]]; then
  echo "-mindepth 1 did not skip the starting point" >&2
  exit 1
fi
