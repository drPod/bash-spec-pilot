#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
notdir="$tmpdir/notdir"
printf 's' > "$src"
printf 'x' > "$notdir"
set +e
"$UTIL" -t "$notdir" "$src"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "-t accepted a non-directory target" >&2
  exit 1
fi
