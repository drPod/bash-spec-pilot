#!/usr/bin/env bash
set -euo pipefail
# -t, --target-directory=DIRECTORY : "copy all SOURCE arguments into DIRECTORY".
# Supplying a regular file (not a directory) as the -t argument violates the
# documented contract that the target is a DIRECTORY => nonzero exit.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
notdir="$tmpdir/notdir"
printf 'data' > "$src"
printf 'x' > "$notdir"

set +e
"$UTIL" -t "$notdir" "$src"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "FAIL: -t with a non-directory target did not error" >&2
  exit 1
fi
