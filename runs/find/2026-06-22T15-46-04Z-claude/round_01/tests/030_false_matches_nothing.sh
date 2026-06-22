#!/usr/bin/env bash
set -euo pipefail
# Documented: "-false  Always false." With the whole expression false, the
# default -print is performed on no files, so output is empty.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/a"
: > "$tmpdir/b"

out=$("$UTIL" "$tmpdir" -false)
if [[ -n "$out" ]]; then
    echo "FAIL: -false should print nothing, got: $out" >&2
    exit 1
fi
