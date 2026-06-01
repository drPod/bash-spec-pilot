#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
a="$tmpdir/a"
b="$tmpdir/b"
notdir="$tmpdir/notdir"
printf 'a' > "$a"
printf 'b' > "$b"
printf 'x' > "$notdir"
set +e
"$UTIL" "$a" "$b" "$notdir"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "multi-source form accepted a non-directory destination" >&2
  exit 1
fi
