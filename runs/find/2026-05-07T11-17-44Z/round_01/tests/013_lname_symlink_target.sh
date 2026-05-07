#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/target"
ln -s "$tmpdir/target" "$tmpdir/link"
if ! actual=$("$UTIL" "$tmpdir" -maxdepth 1 -lname '*target' -printf '%f\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "link" ]]; then
  echo "-lname did not match the symlink contents" >&2
  exit 1
fi
