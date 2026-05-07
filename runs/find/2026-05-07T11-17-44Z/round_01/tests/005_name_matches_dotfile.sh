#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/.foobar"
: > "$tmpdir/bar"
if ! actual=$("$UTIL" "$tmpdir" -maxdepth 1 -name '*foo*' -printf '%f\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != ".foobar" ]]; then
  echo "-name pattern did not match the leading-dot filename" >&2
  exit 1
fi
