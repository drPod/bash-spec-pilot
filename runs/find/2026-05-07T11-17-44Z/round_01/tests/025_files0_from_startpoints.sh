#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/dir"
: > "$tmpdir/file"
list="$tmpdir/starts.list"
printf '%s\0%s\0' "$tmpdir/file" "$tmpdir/dir" > "$list"
if ! actual=$("$UTIL" -files0-from "$list" -maxdepth 0 -printf '%f\n' | LC_ALL=C sort); then
  echo "find invocation failed" >&2
  exit 1
fi
expected=$(printf '%s\n' dir file | LC_ALL=C sort)
if [[ "$actual" != "$expected" ]]; then
  echo "-files0-from did not use the NUL-separated starting points" >&2
  exit 1
fi
