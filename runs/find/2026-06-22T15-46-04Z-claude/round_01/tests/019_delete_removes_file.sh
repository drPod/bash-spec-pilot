#!/usr/bin/env bash
set -euo pipefail
# Documented: "-delete  Delete files or directories; true if removal succeeded."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/victim"
: > "$tmpdir/keep"

"$UTIL" "$tmpdir" -type f -name 'victim' -delete
if [[ -e "$tmpdir/victim" ]]; then
    echo "FAIL: -delete did not remove $tmpdir/victim" >&2
    exit 1
fi
