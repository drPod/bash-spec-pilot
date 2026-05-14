#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/nonempty"
: > "$tmpdir/nonempty/child"
set +e
"$UTIL" "$tmpdir/nonempty" -maxdepth 0 -delete > "$tmpdir/out" 2> "$tmpdir/err"
status=$?
set -e
if [[ $status -eq 0 ]]; then echo "-delete succeeded on non-empty directory" >&2; exit 1; fi
