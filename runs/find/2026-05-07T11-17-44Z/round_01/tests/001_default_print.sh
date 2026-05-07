#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/dir"
: > "$tmpdir/file"
if ! actual=$("$UTIL" "$tmpdir" -maxdepth 1 -printf '%p\n' | LC_ALL=C sort); then
  echo "find invocation failed" >&2
  exit 1
fi
expected=$(printf '%s\n' "$tmpdir" "$tmpdir/dir" "$tmpdir/file" | LC_ALL=C sort)
if [[ "$actual" != "$expected" ]]; then
  echo "default -print equivalent output differed" >&2
  exit 1
fi
