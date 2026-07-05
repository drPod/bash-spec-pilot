#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
target="$tmpdir/file.txt"
out="$tmpdir/edit_env.out"
err="$tmpdir/edit_env.err"
set +e
"$UTIL" -n -e SUDO_EDIT_FORBIDDEN=value "$target" >"$out" 2>"$err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "environment assignment in edit mode unexpectedly succeeded" >&2
  exit 1
fi
