#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

srcdir="$tmpdir/srcdir"
dstdir="$tmpdir/dstdir"
mkdir "$srcdir"
printf 'x\n' > "$srcdir/f.txt"

# Synopsis documents recursive copy via -R/-r/--recursive for directories;
# copying a directory without it is not a supported plain-copy form.
set +e
"$UTIL" "$srcdir" "$dstdir"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "FAIL: copying a directory without --recursive should fail but exited 0" >&2
  exit 1
fi
