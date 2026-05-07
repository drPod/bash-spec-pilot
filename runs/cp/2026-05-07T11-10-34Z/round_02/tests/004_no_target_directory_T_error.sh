#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dstdir="$tmpdir/existing_dir"
printf 'data' > "$src"
mkdir "$dstdir"
set +e
"$UTIL" -T "$src" "$dstdir" >/dev/null 2>&1
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "cp -T unexpectedly succeeded for existing directory destination" >&2
  exit 1
fi
