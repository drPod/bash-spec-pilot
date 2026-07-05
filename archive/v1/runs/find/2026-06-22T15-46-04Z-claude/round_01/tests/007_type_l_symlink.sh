#!/usr/bin/env bash
set -euo pipefail
# Documented: "-type c ... l  symbolic link" and default -P "Never follow
# symbolic links" so the link is reported as a link.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/target"
ln -s "$tmpdir/target" "$tmpdir/link"

out=$("$UTIL" "$tmpdir" -type l | sort)
expected="$tmpdir/link"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -type l expected only $expected, got: $out" >&2
    exit 1
fi
