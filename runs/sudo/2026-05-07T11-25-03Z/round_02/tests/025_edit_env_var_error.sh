#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
target="$tmpdir/edit_target"
set +e
"$UTIL" -n -e FOO=bar "$target" >"$tmpdir/edit_env.out" 2>"$tmpdir/edit_env.err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "environment variable in edit mode unexpectedly succeeded" >&2
  exit 1
fi
