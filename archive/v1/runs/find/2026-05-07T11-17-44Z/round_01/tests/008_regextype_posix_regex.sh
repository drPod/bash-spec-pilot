#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/foo123"
: > "$tmpdir/fooabc"
if ! actual=$("$UTIL" "$tmpdir" -regextype posix-extended -regex '.*/foo[0-9]+' -printf '%f\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "foo123" ]]; then
  echo "-regextype posix-extended regex did not match as expected" >&2
  exit 1
fi
