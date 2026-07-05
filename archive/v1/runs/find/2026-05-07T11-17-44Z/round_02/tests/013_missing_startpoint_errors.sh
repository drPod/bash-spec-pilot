#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" "$tmpdir/missing" -print > "$tmpdir/out" 2> "$tmpdir/err"
status=$?
set -e
if [[ $status -eq 0 ]]; then echo "missing starting point did not cause nonzero exit" >&2; exit 1; fi
