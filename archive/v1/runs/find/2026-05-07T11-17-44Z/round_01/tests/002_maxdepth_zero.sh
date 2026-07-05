#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/sub"
: > "$tmpdir/sub/file"
if ! actual=$("$UTIL" "$tmpdir" -maxdepth 0 -printf '%p'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "$tmpdir" ]]; then
  echo "-maxdepth 0 did not restrict output to the starting point" >&2
  exit 1
fi
