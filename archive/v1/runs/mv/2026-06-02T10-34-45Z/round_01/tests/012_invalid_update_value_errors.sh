#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
set +e
"$UTIL" --update=bogus "$tmpdir/src" "$tmpdir/dst" >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "invalid --update value was accepted" >&2
  exit 1
fi
