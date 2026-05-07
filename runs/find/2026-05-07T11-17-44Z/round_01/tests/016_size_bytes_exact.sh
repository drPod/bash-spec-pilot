#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf abc > "$tmpdir/three"
printf abcd > "$tmpdir/four"
if ! actual=$("$UTIL" "$tmpdir" -maxdepth 1 -type f -size 3c -printf '%f\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "three" ]]; then
  echo "-size 3c did not match the three-byte file" >&2
  exit 1
fi
