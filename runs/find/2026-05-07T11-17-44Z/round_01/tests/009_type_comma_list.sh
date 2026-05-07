#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/dir"
: > "$tmpdir/file"
ln -s "$tmpdir/file" "$tmpdir/link"
if ! actual=$("$UTIL" "$tmpdir" -maxdepth 1 -type f,d,l -printf '%f\n' | LC_ALL=C sort); then
  echo "find invocation failed" >&2
  exit 1
fi
expected=$(printf '%s\n' "$(basename "$tmpdir")" dir file link | LC_ALL=C sort)
if [[ "$actual" != "$expected" ]]; then
  echo "-type comma-separated list did not match files, directories, and symlinks" >&2
  exit 1
fi
