#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/ref"
: > "$tmpdir/old"
: > "$tmpdir/new"
touch -d '2000-01-01 00:00:00 UTC' "$tmpdir/ref" "$tmpdir/old"
touch -d '2001-01-01 00:00:00 UTC' "$tmpdir/new"
if ! actual=$("$UTIL" "$tmpdir" -maxdepth 1 -type f -newer "$tmpdir/ref" -printf '%f\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "new" ]]; then
  echo "-newer did not match only the file newer than the reference" >&2
  exit 1
fi
