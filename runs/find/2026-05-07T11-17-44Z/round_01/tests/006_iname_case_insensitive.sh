#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/Foo"
: > "$tmpdir/bar"
if ! actual=$("$UTIL" "$tmpdir" -maxdepth 1 -iname 'f??' -printf '%f\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "Foo" ]]; then
  echo "-iname did not match case-insensitively" >&2
  exit 1
fi
