#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/skip" "$tmpdir/keepdir"
: > "$tmpdir/skip/hidden"
: > "$tmpdir/keepdir/keep"
if ! actual=$("$UTIL" "$tmpdir" -path "$tmpdir/skip" -prune -o -type f -printf '%f\n' | LC_ALL=C sort); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "keep" ]]; then
  echo "-prune did not skip the selected subtree" >&2
  exit 1
fi
