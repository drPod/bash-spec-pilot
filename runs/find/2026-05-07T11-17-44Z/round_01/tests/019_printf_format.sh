#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf abc > "$tmpdir/abc"
if ! actual=$("$UTIL" "$tmpdir/abc" -maxdepth 0 -printf '[%f:%s]'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "[abc:3]" ]]; then
  echo "-printf did not format basename and size as expected" >&2
  exit 1
fi
