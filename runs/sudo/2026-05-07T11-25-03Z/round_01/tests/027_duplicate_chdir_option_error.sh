#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
work="$tmpdir/work"
mkdir "$work"
out="$tmpdir/dup_chdir.out"
err="$tmpdir/dup_chdir.err"
set +e
"$UTIL" -D "$work" -D "$work" /bin/pwd >"$out" 2>"$err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "duplicate -D options unexpectedly succeeded" >&2
  exit 1
fi
