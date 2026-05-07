#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
missing="$tmpdir/missing.txt"
dst="$tmpdir/dest.txt"
set +e
"$UTIL" "$missing" "$dst" >/dev/null 2>&1
status=$?
set -e
if [[ "$status" -ne 0 ]]; then exit 0; fi
echo "cp unexpectedly succeeded for nonexistent source" >&2
exit 1
