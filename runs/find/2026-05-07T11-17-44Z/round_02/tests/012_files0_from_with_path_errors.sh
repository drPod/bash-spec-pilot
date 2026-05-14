#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/a"
printf '%s\0' "$tmpdir/a" > "$tmpdir/list"
set +e
"$UTIL" "$tmpdir/a" -files0-from "$tmpdir/list" -print > "$tmpdir/out" 2> "$tmpdir/err"
status=$?
set -e
if [[ $status -eq 0 ]]; then echo "-files0-from was allowed with command-line start point" >&2; exit 1; fi
