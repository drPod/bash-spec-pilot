#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'payload\n' > "$tmpdir/src"
printf 'not a directory\n' > "$tmpdir/notdir"
set +e
"$UTIL" -t "$tmpdir/notdir" "$tmpdir/src" >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "-t accepted a non-directory target" >&2
  exit 1
fi
