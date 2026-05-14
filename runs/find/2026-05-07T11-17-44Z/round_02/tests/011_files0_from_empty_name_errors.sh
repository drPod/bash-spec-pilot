#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf '\0' > "$tmpdir/list"
set +e
"$UTIL" -files0-from "$tmpdir/list" -maxdepth 0 -print > "$tmpdir/out" 2> "$tmpdir/err"
status=$?
set -e
if [[ $status -eq 0 ]]; then echo "-files0-from accepted zero-length file name" >&2; exit 1; fi
