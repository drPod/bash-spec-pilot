#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/dir"
: > "$tmpdir/dir/child"
if ! actual=$("$UTIL" "$tmpdir" -mindepth 1 -depth -printf '%P\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
expected=$'dir/child\ndir'
if [[ "$actual" != "$expected" ]]; then
  echo "-depth did not process contents before directory" >&2
  exit 1
fi
