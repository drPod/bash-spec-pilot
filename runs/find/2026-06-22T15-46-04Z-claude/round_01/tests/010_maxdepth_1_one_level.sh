#!/usr/bin/env bash
set -euo pipefail
# Documented: "-maxdepth levels  Descend at most levels ... levels of
# directories below the starting-points." With 1, the start point and its
# immediate children are visited but not grandchildren.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/a"
mkdir "$tmpdir/sub"
: > "$tmpdir/sub/b"

out=$("$UTIL" "$tmpdir" -maxdepth 1 | sort)
expected=$(printf '%s\n%s\n%s\n' \
    "$tmpdir" "$tmpdir/a" "$tmpdir/sub" | sort)
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -maxdepth 1 expected start+children only, got: $out" >&2
    exit 1
fi
