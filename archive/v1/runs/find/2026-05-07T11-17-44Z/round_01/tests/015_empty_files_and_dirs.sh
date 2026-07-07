#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/emptydir"
: > "$tmpdir/emptyfile"
printf x > "$tmpdir/nonempty"
if ! actual=$("$UTIL" "$tmpdir" -mindepth 1 -maxdepth 1 -empty -printf '%f\n' | LC_ALL=C sort); then
  echo "find invocation failed" >&2
  exit 1
fi
expected=$(printf '%s\n' emptydir emptyfile | LC_ALL=C sort)
if [[ "$actual" != "$expected" ]]; then
  echo "-empty did not match exactly the empty file and empty directory" >&2
  exit 1
fi
