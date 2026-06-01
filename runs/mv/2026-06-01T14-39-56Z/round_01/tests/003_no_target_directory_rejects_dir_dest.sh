#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/item"
dir="$tmpdir/target"
mkdir "$dir"
printf 'payload' > "$src"
set +e
"$UTIL" -T "$src" "$dir"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "-T unexpectedly accepted a directory destination" >&2
  exit 1
fi
