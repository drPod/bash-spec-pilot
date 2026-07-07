#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/a"
: > "$tmpdir/b"
if ! actual=$("$UTIL" -O3 "$tmpdir" -maxdepth 1 -name b -printf '%f\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "b" ]]; then
  echo "-O3 optimization did not preserve the matching result" >&2
  exit 1
fi
