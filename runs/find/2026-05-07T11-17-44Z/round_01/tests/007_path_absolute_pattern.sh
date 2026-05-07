#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/src/misc" "$tmpdir/other"
: > "$tmpdir/src/misc/file"
: > "$tmpdir/other/file"
pattern="$tmpdir/sr*sc/file"
if ! actual=$("$UTIL" "$tmpdir" -path "$pattern" -printf '%p'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "$tmpdir/src/misc/file" ]]; then
  echo "-path did not match the whole absolute path" >&2
  exit 1
fi
