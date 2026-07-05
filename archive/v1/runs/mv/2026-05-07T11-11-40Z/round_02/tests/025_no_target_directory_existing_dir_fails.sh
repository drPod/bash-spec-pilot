#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'payload' > "$tmpdir/src"
mkdir "$tmpdir/dstdir"
set +e
"$UTIL" -T "$tmpdir/src" "$tmpdir/dstdir" >/dev/null 2>&1
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "-T file to existing directory succeeded" >&2
  exit 1
fi
