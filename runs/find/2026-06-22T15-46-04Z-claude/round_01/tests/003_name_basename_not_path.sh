#!/usr/bin/env bash
set -euo pipefail
# Documented: "-name a/b will never match anything" because the pattern should
# not include a slash; matching is on the base name only.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/sub"
: > "$tmpdir/sub/file"

out=$("$UTIL" "$tmpdir" -name 'sub/file')
if [[ -n "$out" ]]; then
    echo "FAIL: -name 'sub/file' should match nothing, got: $out" >&2
    exit 1
fi
