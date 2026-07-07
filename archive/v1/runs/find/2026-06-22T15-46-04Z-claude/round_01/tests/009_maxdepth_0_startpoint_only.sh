#!/usr/bin/env bash
set -euo pipefail
# Documented: "Using -maxdepth 0 means only apply the tests and actions to the
# starting-points themselves."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/a"
mkdir "$tmpdir/sub"
: > "$tmpdir/sub/b"

out=$("$UTIL" "$tmpdir" -maxdepth 0 | sort)
expected="$tmpdir"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -maxdepth 0 expected only $tmpdir, got: $out" >&2
    exit 1
fi
