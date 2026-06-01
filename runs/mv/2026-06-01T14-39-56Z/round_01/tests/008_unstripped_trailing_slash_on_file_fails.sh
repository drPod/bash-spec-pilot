#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/file"
dst="$tmpdir/dst"
printf 'payload' > "$src"
set +e
"$UTIL" "$src/" "$dst"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "file source with trailing slash was accepted without stripping" >&2
  exit 1
fi
