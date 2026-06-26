#!/usr/bin/env bash
set -euo pipefail
# Synopsis: "cp [OPTION]... SOURCE... DIRECTORY". With multiple SOURCEs the
# final argument must be a DIRECTORY. A regular-file last argument with two
# sources violates the documented form => nonzero exit.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

a="$tmpdir/a.txt"
b="$tmpdir/b.txt"
dest="$tmpdir/dest.txt"
printf 'A' > "$a"
printf 'B' > "$b"
printf 'D' > "$dest"

set +e
"$UTIL" "$a" "$b" "$dest"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "FAIL: two SOURCEs with a non-directory final DEST did not error" >&2
  exit 1
fi
